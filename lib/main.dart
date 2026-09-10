import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:signwriter_easy_app_oficial/views/screens/auth_screen.dart';
import 'package:signwriter_easy_app_oficial/viewmodels/auth_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:signwriter_easy_app_oficial/viewmodels/profile_viewmodel.dart';
import 'package:signwriter_easy_app_oficial/viewmodels/dictionary_viewmodel.dart';
import 'package:signwriter_easy_app_oficial/viewmodels/learn_practice_viewmodel.dart';
import 'package:signwriter_easy_app_oficial/viewmodels/translate_viewmodel.dart';
import 'package:signwriter_easy_app_oficial/views/screens/home_screen.dart';
import 'package:signwriter_easy_app_oficial/views/screens/reset_password_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:signwriter_easy_app_oficial/theme/app_theme.dart';
import 'package:signwriter_easy_app_oficial/routes/app_routes.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  debugPrint('INICIANDO SIGNWRITER FÁCIL');
  
  try {
    debugPrint('Carregando configurações do arquivo .env...');
    await dotenv.load(fileName: '.env');
    
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseKey = dotenv.env['SUPABASE_KEY'];
    
    debugPrint('Variáveis carregadas:');
    debugPrint('SUPABASE_URL: ${supabaseUrl != null}');
    debugPrint('SUPABASE_KEY: ${supabaseKey != null}');
    
    if (supabaseUrl == null || supabaseUrl.isEmpty) {
      throw Exception('❌ SUPABASE_URL não encontrada ou vazia no arquivo .env');
    }
    
    if (supabaseKey == null || supabaseKey.isEmpty) {
      throw Exception('❌ SUPABASE_KEY não encontrada ou vazia no arquivo .env');
    }
    
    debugPrint('Supabase URL carregada');
    debugPrint('Supabase Key carregada');
    
    debugPrint('Inicializando conexão com Supabase...');
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
    
    debugPrint('Supabase inicializado com sucesso!');
    
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthViewModel(Supabase.instance.client),
          ),
          ChangeNotifierProvider(
            create: (_) => ProfileViewModel(),
          ),
          ChangeNotifierProvider(
            create: (_) => DictionaryViewModel(),
          ),
          ChangeNotifierProvider(
            create: (_) => LearnPracticeViewModel(),
          ),
          ChangeNotifierProvider(
            create: (_) => TranslateViewModel(),
          ),
        ],
        child: const MyApp(),
      ),
    );
    
  } catch (e) {
    debugPrint('Erro crítico na inicialização: $e');
    
    debugPrint('Verifique o arquivo .env e execute flutter pub get.');
    
    runApp(
      ErrorApp(
        errorMessage: '''
Erro ao inicializar o aplicativo:

$e

Verifique:
1. Arquivo .env na raiz do projeto
2. Conteúdo correto das variáveis
3. Dependências instaladas (flutter pub get)
''',
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ProfileViewModel,
        (ThemeMode, Locale, double, double, double)>(
      selector: (_, vm) => (
        vm.flutterThemeMode,
        vm.locale,
        vm.contrastLevel,
        vm.spacing,
        vm.fontSize,
      ),
      builder: (context, data, child) {
        final (themeMode, locale, contrastLevel, spacing, fontSize) = data;

        return MaterialApp(
          title: 'SignWriter Fácil',
          debugShowCheckedModeBanner: false,
          routes: AppRoutes.routes,
          themeMode: themeMode,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(
            contrastLevel: contrastLevel,
            spacingScale: spacing,
          ),
          darkTheme: AppTheme.dark(
            contrastLevel: contrastLevel,
            spacingScale: spacing,
          ),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(fontSize),
              ),
              child: child!,
            );
          },
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late final StreamSubscription<AuthState> _authSubscription;
  bool _isPasswordRecovery = _hasPasswordRecoveryMarker();

  static bool _hasPasswordRecoveryMarker() {
    if (Uri.base.path == '/reset-password') return true;
    if (Uri.base.queryParameters['type'] == 'recovery') return true;

    final fragment = Uri.base.fragment;
    if (fragment.isEmpty) return false;

    try {
      return Uri.splitQueryString(fragment)['type'] == 'recovery';
    } catch (_) {
      return fragment.contains('type=recovery');
    }
  }

  @override
  void initState() {
    super.initState();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (state) {
        if (state.event == AuthChangeEvent.passwordRecovery && mounted) {
          setState(() => _isPasswordRecovery = true);
        }
      },
    );
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isPasswordRecovery) return const ResetPasswordScreen();
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      return const HomeScreen();
    }

    return const AuthScreen();
  }
}

class ErrorApp extends StatelessWidget {
  final String errorMessage;
  
  const ErrorApp({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.error_outline, color: Colors.red, size: 32),
                    SizedBox(width: 12),
                    Text(
                      'Erro de Configuração',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Não foi possível inicializar o aplicativo:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade100),
                            ),
                            child: SelectableText(
                              errorMessage,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 14,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          const Text(
                            '📋 Passos para resolver:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          const _StepItem(
                            number: 1,
                            text: 'Verifique se o arquivo ".env" está na raiz do projeto',
                          ),
                          const _StepItem(
                            number: 2,
                            text: 'Abra o arquivo .env e confirme que tem:',
                            subText: 'SUPABASE_URL=sua_url\nSUPABASE_KEY=sua_key',
                          ),
                          const _StepItem(
                            number: 3,
                            text: 'Execute no terminal: flutter clean',
                          ),
                          const _StepItem(
                            number: 4,
                            text: 'Depois: flutter pub get',
                          ),
                          const _StepItem(
                            number: 5,
                            text: 'Reinicie o aplicativo',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D78BB),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      main();
                    },
                    child: const Text(
                      'Tentar Novamente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final int number;
  final String text;
  final String? subText;
  
  const _StepItem({
    required this.number,
    required this.text,
    this.subText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF2D78BB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
                
                if (subText != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: SelectableText(
                      subText!,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}