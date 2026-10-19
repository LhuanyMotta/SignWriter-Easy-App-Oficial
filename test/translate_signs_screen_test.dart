import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signwriter_easy_app_oficial/l10n/app_localizations.dart';
import 'package:signwriter_easy_app_oficial/views/screens/translate_signs_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'dummy-key',
    );
  });

  tearDown(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.resetViewInsets();
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  Future<void> pumpTranslateScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt', 'BR'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const TranslateSignsScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('não causa overflow em tela pequena', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;

    await pumpTranslateScreen(tester);

    final error = tester.takeException();
    expect(error, isNull);
  });

  testWidgets('permite rolar o formulário com o teclado aberto',
      (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);

    await pumpTranslateScreen(tester);
    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Traduzir para Libras'));
    await tester.pumpAndSettle();

    expect(find.text('Traduzir para Libras'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
