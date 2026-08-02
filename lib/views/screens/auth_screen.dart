import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'home_screen.dart';
import '../widgets/app_logo.dart';
import '../accessibility_settings_view.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../theme/responsive.dart';
import '../../l10n/l10n.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late AuthViewModel _viewModel;
  late TabController _tabController;
  late StreamSubscription<AuthState> _authStateSubscription;
  bool _hasNavigatedAfterAuth = false;
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();
  
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  
  final TextEditingController _signupNameController = TextEditingController();
  final TextEditingController _signupEmailController = TextEditingController();
  final TextEditingController _signupPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = AuthViewModel(Supabase.instance.client);
    _tabController = TabController(length: 2, vsync: this);
    _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) async {
        if (data.event == AuthChangeEvent.signedIn && mounted) {
          if (!_hasNavigatedAfterAuth) {
            _hasNavigatedAfterAuth = true;
            await _navigateAfterAuth();
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isWide(context);
    final scheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: scheme.surface,
        body: isWide ? _buildWideLayout(context) : _buildFormBody(context),
      ),
    );
  }

  AppThemeTokens _tokens(BuildContext context) {
    return Theme.of(context).extension<AppThemeTokens>() ??
        const AppThemeTokens(
          spacingScale: 1,
          contrastLevel: 1,
          surface: Colors.white,
          surfaceMuted: Color(0xFFF8FAFC),
          onSurfaceMuted: Color(0xFF4B5563),
          border: Color(0xFFD1D5DB),
        );
  }

  /// Layout de Web/desktop: painel de marca à esquerda (ocupando o espaço
  /// extra que sobra numa tela larga) + o formulário de sempre à direita,
  /// numa largura fixa de "card", como a maioria dos apps SaaS faz.
  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2D78BB), Color(0xFF1B4E7A)],
              ),
            ),
            child: Stack(
              children: [
                // Formas decorativas — só pra dar textura ao painel,
                // sem competir com o conteúdo.
                Positioned(
                  top: -60,
                  right: -60,
                  child: _DecorativeCircle(size: 220, opacity: 0.10),
                ),
                Positioned(
                  bottom: -80,
                  left: -40,
                  child: _DecorativeCircle(size: 260, opacity: 0.08),
                ),
                Positioned(
                  bottom: 120,
                  right: 40,
                  child: _DecorativeCircle(size: 90, opacity: 0.12),
                ),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppLogo(size: 64, colored: false, showText: false),
                          const SizedBox(height: 32),
                          Text(
                            context.l10n.appTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            context.l10n.authSubtitle,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 18,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 40),
                          const _AuthFeatureBullet(text: 'Tradução de texto para Libras'),
                          const SizedBox(height: 16),
                          const _AuthFeatureBullet(text: 'Dicionário completo de sinais'),
                          const SizedBox(height: 16),
                          const _AuthFeatureBullet(text: 'Aprenda no seu próprio ritmo'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Builder(
            builder: (context) {
              final scheme = Theme.of(context).colorScheme;
              final tokens = _tokens(context);
              final isDark = scheme.brightness == Brightness.dark;
              return Container(
                color: tokens.surfaceMuted,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: isDark
                              ? Border.all(color: tokens.border.withValues(alpha: 0.5))
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: _buildFormCard(context),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFormBody(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = _tokens(context);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: AppSpacing.symmetric(context, horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                SizedBox(height: AppSpacing.value(context, 40)),
                const AppLogo(
                  size: 80,
                  colored: true,
                  showText: false,
                ),
                SizedBox(height: AppSpacing.value(context, 20)),
                Text(
                  context.l10n.appTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                ),
                SizedBox(height: AppSpacing.value(context, 8)),
                Text(
                  context.l10n.authSubtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: tokens.onSurfaceMuted,
                      ),
                ),
                SizedBox(height: AppSpacing.value(context, 32)),
                _buildTabBarChrome(context),
                SizedBox(height: AppSpacing.value(context, 24)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLoginTab(),
                _buildSignupTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Mesmo conteúdo de formulário do mobile, mas sem o SafeArea/Stack
  /// externo — usado dentro do card centralizado da tela larga.
  Widget _buildFormCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.l10n.appTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
        ),
        const SizedBox(height: 24),
        _buildTabBarChrome(context),
        const SizedBox(height: 24),
        // Numa tela larga não tem Expanded/TabBarView com altura infinita
        // disponível (estamos dentro de um SingleChildScrollView), então
        // cada aba precisa se dimensionar pelo próprio conteúdo.
        AnimatedBuilder(
          animation: _tabController,
          builder: (context, _) {
            return _tabController.index == 0 ? _buildLoginTab() : _buildSignupTab();
          },
        ),
      ],
    );
  }

  Widget _buildTabBarChrome(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = _tokens(context);

    return Container(
      decoration: BoxDecoration(
        color: tokens.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: scheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: scheme.onPrimary,
        unselectedLabelColor: tokens.onSurfaceMuted,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        tabs: [
          Tab(text: context.l10n.loginTab),
          Tab(text: context.l10n.signupTab),
        ],
      ),
    );
  }

  Widget _buildLoginTab() {
    return SingleChildScrollView(
      padding: AppSpacing.symmetric(context, horizontal: 24.0),
      child: Form(
        key: _loginFormKey,
        child: Column(
          children: [
            _buildTextField(
              controller: _loginEmailController,
              label: context.l10n.emailLabel,
              hintText: context.l10n.emailLabel,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.l10n.enterEmailError;
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return context.l10n.invalidEmailError;
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.value(context, 16)),
            
            _buildTextField(
              controller: _loginPasswordController,
              label: context.l10n.passwordLabel,
              hintText: context.l10n.passwordLabel,
              icon: Icons.lock_outlined,
              isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.l10n.enterPasswordError;
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.value(context, 8)),
            
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.passwordRecoverySoon),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Text(
                  context.l10n.forgotPassword,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.value(context, 24)),
            
            Consumer<AuthViewModel>(
              builder: (context, viewModel, child) {
                final scheme = Theme.of(context).colorScheme;
                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading ? null : () => _handleLogin(viewModel, context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: viewModel.isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(scheme.onPrimary),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.login, size: 22),
                              SizedBox(width: AppSpacing.value(context, 10)),
                              Text(
                                context.l10n.loginButton,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
            SizedBox(height: AppSpacing.value(context, 20)),
            
            _buildDivider(),
            SizedBox(height: AppSpacing.value(context, 20)),
            
            _buildSocialLoginButtons(),
            SizedBox(height: AppSpacing.value(context, 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupTab() {
    return SingleChildScrollView(
      padding: AppSpacing.symmetric(context, horizontal: 24.0),
      child: Form(
        key: _signupFormKey,
        child: Column(
          children: [
            _buildTextField(
              controller: _signupNameController,
              label: context.l10n.fullNameLabel,
              hintText: context.l10n.fullNameLabel,
              icon: Icons.person_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.l10n.enterNameError;
                }
                if (value.length < 2) {
                  return context.l10n.nameLengthError;
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.value(context, 16)),
            
            _buildTextField(
              controller: _signupEmailController,
              label: context.l10n.emailLabel,
              hintText: context.l10n.emailLabel,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.l10n.enterEmailError;
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return context.l10n.invalidEmailError;
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.value(context, 16)),
            
            _buildTextField(
              controller: _signupPasswordController,
              label: context.l10n.passwordLabel,
              hintText: context.l10n.passwordLabel,
              icon: Icons.lock_outlined,
              isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.l10n.enterPasswordError;
                }
                if (value.length < 6) {
                  return context.l10n.passwordLengthError;
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.value(context, 16)),
            
            _buildTextField(
              controller: _confirmPasswordController,
              label: context.l10n.confirmPasswordLabel,
              hintText: context.l10n.confirmPasswordLabel,
              icon: Icons.lock_outlined,
              isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.l10n.confirmPasswordError;
                }
                if (value != _signupPasswordController.text) {
                  return context.l10n.passwordMismatchError;
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.value(context, 32)),
            
            Consumer<AuthViewModel>(
              builder: (context, viewModel, child) {
                final scheme = Theme.of(context).colorScheme;
                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading ? null : () => _handleSignup(viewModel, context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: viewModel.isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(scheme.onPrimary),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_add, size: 22),
                              SizedBox(width: AppSpacing.value(context, 10)),
                              Text(
                                context.l10n.signupButton,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
            SizedBox(height: AppSpacing.value(context, 20)),
            
            _buildDivider(),
            SizedBox(height: AppSpacing.value(context, 20)),
            
            _buildSocialLoginButtons(),
            SizedBox(height: AppSpacing.value(context, 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = _tokens(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: tokens.onSurfaceMuted,
          ),
        ),
        SizedBox(height: AppSpacing.value(context, 6)),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(color: scheme.onSurface),
          cursorColor: scheme.primary,
          decoration: InputDecoration(
            hintStyle: TextStyle(color: tokens.onSurfaceMuted.withValues(alpha: 0.75)),
            hintText: hintText,
            prefixIcon: Icon(icon, color: scheme.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: tokens.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: tokens.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: scheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: scheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: scheme.error, width: 2),
            ),
            filled: true,
            fillColor: tokens.surfaceMuted,
            contentPadding: AppSpacing.symmetric(context, horizontal: 16, vertical: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    final tokens = _tokens(context);

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: tokens.border,
          ),
        ),
        Padding(
          padding: AppSpacing.symmetric(context, horizontal: 16),
          child: Text(
            context.l10n.orLabel,
            style: TextStyle(
              color: tokens.onSurfaceMuted,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: tokens.border,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () async {
              final success = await _viewModel.signInWithGoogle();
              if (!mounted) return;
              final messenger = ScaffoldMessenger.of(context);

              if (success) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.authOAuthContinueInBrowser),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 4),
                  ),
                );
                return;
              }

              if (_viewModel.error != null) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(_viewModel.error!),
                    backgroundColor: scheme.error,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'G',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: scheme.onPrimary,
                  ),
                ),
                SizedBox(width: AppSpacing.value(context, 12)),
                Text(
                  context.l10n.continueWithGoogle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: scheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: AppSpacing.value(context, 12)),
        
        if (!kIsWeb) ...[
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () async {
                final success = await _viewModel.signInWithApple();
                if (!mounted) return;
                final messenger = ScaffoldMessenger.of(context);

                if (success) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.authOAuthContinueInBrowser),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                  return;
                }

                if (_viewModel.error != null) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(_viewModel.error!),
                      backgroundColor: scheme.error,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.apple, size: 24, color: scheme.onPrimary),
                  SizedBox(width: AppSpacing.value(context, 12)),
                  Text(
                    context.l10n.continueWithApple,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: scheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _handleLogin(AuthViewModel viewModel, BuildContext context) async {
    if (_loginFormKey.currentState!.validate()) {
      final messenger = ScaffoldMessenger.of(context);
      final success = await viewModel.signInWithEmail(
        email: _loginEmailController.text,
        password: _loginPasswordController.text,
      );
      
      if (success) {
        if (!mounted) return;
        await _navigateAfterAuth();
      } else {
        if (!mounted) return;
        final msg = _localizedAuthError(viewModel.errorType, context);
        messenger.showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _handleSignup(AuthViewModel viewModel, BuildContext context) async {
    if (_signupFormKey.currentState!.validate()) {
      final messenger = ScaffoldMessenger.of(context);
      final success = await viewModel.signUpWithEmail(
        name: _signupNameController.text,
        email: _signupEmailController.text,
        password: _signupPasswordController.text,
      );
      
      if (success) {
        if (!mounted) return;
        await _navigateAfterAuth();
      } else {
        if (!mounted) return;
        final msg = _localizedAuthError(viewModel.errorType, context, isSignup: true);
        messenger.showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  Future<void> _navigateAfterAuth() async {
  final prefs = await SharedPreferences.getInstance();
  final hasSeenAccessibility =
      prefs.getBool('has_seen_accessibility') ?? false;

  if (!mounted) return;

  if (hasSeenAccessibility) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  } else {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const AccessibilitySettingsView(
          isFirstAccess: true,
        ),
      ),
    );
  }
}

  String _localizedAuthError(AuthErrorType? type, BuildContext context, {bool isSignup = false}) {
    final l = context.l10n;
    switch (type) {
      case AuthErrorType.invalidCredentials:
        return l.authErrorInvalidCredentials;
      case AuthErrorType.emailExists:
        return l.authErrorEmailExists;
      case AuthErrorType.weakPassword:
        return l.authErrorWeakPassword;
      case AuthErrorType.emailSignupsDisabled:
        return l.authErrorEmailSignupsDisabled;
      case AuthErrorType.emailLoginsDisabled:
        return l.authErrorEmailLoginsDisabled;
      case AuthErrorType.emailNotConfirmed:
        return l.authErrorEmailNotConfirmed;
      case AuthErrorType.oauthNotEnabled:
        return l.authErrorOAuthNotEnabled;
      case AuthErrorType.createAccount:
        return l.authErrorCreateAccount;
      case AuthErrorType.unknown:
      case null:
        return isSignup ? l.authErrorSignup : l.authErrorLogin;
    }
  }
}

class _DecorativeCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _DecorativeCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _AuthFeatureBullet extends StatelessWidget {
  final String text;

  const _AuthFeatureBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}