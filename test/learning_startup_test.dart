import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:signwriter_easy_app_oficial/services/authorization_service.dart';
import 'package:signwriter_easy_app_oficial/viewmodels/learn_practice_viewmodel.dart';
import 'package:signwriter_easy_app_oficial/views/screens/learn_practice_screen.dart';

class TestAuthorization extends AuthorizationService {
  TestAuthorization(this.result)
      : super(supabase: Supabase.instance.client);
  final Future<bool> result;
  @override
  Future<void> clearLocalAuthorUiOverride() async {}
  @override
  Future<bool> hasEditorialRole() => result;
}

class TestViewModel extends LearnPracticeViewModel {
  TestViewModel() : super();
  bool? requestedDrafts;
  final loaded = Completer<void>();
  @override
  Future<void> initialize(Locale locale, {bool includeDrafts = false}) async {
    requestedDrafts = includeDrafts;
    await loaded.future;
  }
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(url: 'https://example.supabase.co', anonKey: 'test');
  });
  tearDownAll(() async => Supabase.instance.dispose());
  testWidgets('carrega desde o primeiro frame e só mostra vazio após concluir', (tester) async {
    final role = Completer<bool>();
    final vm = TestViewModel();
    await tester.pumpWidget(ChangeNotifierProvider<LearnPracticeViewModel>.value(
      value: vm,
      child: MaterialApp(home: LearnPracticeScreen(authorization: TestAuthorization(role.future))),
    ));
    expect(find.text('Carregando lições...'), findsOneWidget);
    expect(find.text('Nenhuma lição disponível'), findsNothing);
    role.complete(false);
    await tester.pump();
    expect(find.text('Carregando lições...'), findsOneWidget);
    vm.loaded.complete();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 9));
    expect(find.text('Nenhuma lição disponível'), findsWidgets);
  });

  testWidgets('falha de permissão continua carregando sem liberar rascunhos', (tester) async {
    final role = Completer<bool>();
    final vm = TestViewModel();
    await tester.pumpWidget(ChangeNotifierProvider<LearnPracticeViewModel>.value(
      value: vm,
      child: MaterialApp(home: LearnPracticeScreen(authorization: TestAuthorization(role.future))),
    ));
    role.completeError(Exception('sem conexão'));
    await tester.pump();
    expect(vm.requestedDrafts, isFalse);
    expect(find.text('Carregando lições...'), findsOneWidget);
    vm.loaded.complete();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 9));
    expect(tester.takeException(), isNull);
  });
}
