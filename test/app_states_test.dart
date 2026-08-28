import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signwriter_easy_app_oficial/l10n/app_localizations.dart';
import 'package:signwriter_easy_app_oficial/utils/friendly_error.dart';
import 'package:signwriter_easy_app_oficial/viewmodels/auth_viewmodel.dart';
import 'package:signwriter_easy_app_oficial/viewmodels/profile_viewmodel.dart';
import 'package:signwriter_easy_app_oficial/views/screens/auth_screen.dart';
import 'package:signwriter_easy_app_oficial/views/screens/profile_screen.dart';
import 'package:signwriter_easy_app_oficial/views/widgets/states/app_empty_state.dart';
import 'package:signwriter_easy_app_oficial/views/widgets/states/app_error_state.dart';
import 'package:signwriter_easy_app_oficial/views/widgets/states/app_loading_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'dummy-key',
    );
  });

  testWidgets('ProfileScreen mostra sessão expirada sem quebrar o provider', (tester) async {
    final vm = ProfileViewModel();

    await tester.pumpWidget(
      ChangeNotifierProvider<ProfileViewModel>.value(
        value: vm,
        child: MaterialApp(
          locale: const Locale('pt', 'BR'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Sua sessão expirou. Entre novamente.'), findsOneWidget);
  });

  testWidgets('AppLoadingState mostra indicador e mensagem', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppLoadingState(message: 'Carregando sinais...')),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Carregando sinais...'), findsOneWidget);
  });

  testWidgets('AppErrorState oferece retry', (tester) async {
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppErrorState(
            message: 'Sem conexão',
            onRetry: () => retries++,
          ),
        ),
      ),
    );
    expect(find.text('Não foi possível carregar'), findsOneWidget);
    await tester.tap(find.text('Tentar novamente'));
    expect(retries, 1);
  });

  testWidgets('AppEmptyState mostra ação', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppEmptyState(
            icon: Icons.search_off,
            title: 'Nenhum resultado',
            message: 'Limpe os filtros',
            actionLabel: 'Limpar',
            onAction: () => tapped = true,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Limpar'));
    expect(tapped, isTrue);
  });

  test('AuthViewModel.resetEmailConfirmation libera edição do email', () {
    final viewModel = AuthViewModel(Supabase.instance.client);

    viewModel.setEmailConfirmationState(
      requiresEmailConfirmation: true,
      pendingVerificationEmail: 'email-antigo@email.com',
    );

    viewModel.resetEmailConfirmation();

    expect(viewModel.requiresEmailConfirmation, isFalse);
    expect(viewModel.pendingVerificationEmail, isNull);
  });

  testWidgets('AuthScreen mantém cadastro por link quando o email precisa ser validado', (tester) async {
    final viewModel = AuthViewModel(Supabase.instance.client);
    viewModel.setEmailConfirmationState(
      requiresEmailConfirmation: true,
      pendingVerificationEmail: 'usuario@email.com',
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>.value(
        value: viewModel,
        child: MaterialApp(
          locale: const Locale('pt', 'BR'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const AuthScreen(),
        ),
      ),
    );

    expect(find.text('Cadastrar'), findsWidgets);
    expect(find.text('Código de verificação'), findsNothing);
  });

  test('friendlyError traduz rede e timeout', () {
    expect(
      friendlyError(Exception('SocketException: network failed')),
      'Verifique sua conexão com a internet.',
    );
    expect(
      friendlyError(Exception('timeout waiting')),
      'A operação demorou mais que o esperado. Tente novamente.',
    );
    expect(
      friendlyError(Exception('something weird')),
      'Não foi possível concluir a operação. Tente novamente.',
    );
  });
}
