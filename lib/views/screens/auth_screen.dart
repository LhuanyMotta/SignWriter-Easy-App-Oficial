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
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
  child: Stack(
    children: [
      Column(
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
                        color: const Color(0xFF2D78BB),
                      ),
                ),
                SizedBox(height: AppSpacing.value(context, 8)),
                Text(
                  context.l10n.authSubtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                SizedBox(height: AppSpacing.value(context, 32)),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                            controller: _tabController,
                            dividerColor: Colors.transparent,
                            indicator: BoxDecoration(
                              color: const Color(0xFF2D78BB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[600],
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    tabs: [
                      Tab(text: context.l10n.loginTab),
                      Tab(text: context.l10n.signupTab),
                    ],
                  ),
                ),
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
    ],
  ),
),
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
                    color: const Color(0xFF2D78BB),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.value(context, 24)),
            
            Consumer<AuthViewModel>(
              builder: (context, viewModel, child) {
                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading ? null : () => _handleLogin(viewModel, context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D78BB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: viewModel.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading ? null : () => _handleSignup(viewModel, context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D78BB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: viewModel.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: AppSpacing.value(context, 6)),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
  color: Color(0xFF333333),
),
          decoration: InputDecoration(hintStyle: const TextStyle(
  color: Color(0xFF666666),
),
            hintText: hintText,
            prefixIcon: Icon(icon, color: const Color(0xFF2D78BB)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2D78BB), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red[300]!),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red[400]!, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: AppSpacing.symmetric(context, horizontal: 16, vertical: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey[300],
          ),
        ),
        Padding(
          padding: AppSpacing.symmetric(context, horizontal: 16),
          child: Text(
            context.l10n.orLabel,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey[300],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        // Botão Google com fundo AZUL sólido e G branco
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
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D78BB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone do Google - apenas o G branco
                Text(
                  'G',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: AppSpacing.value(context, 12)),
                Text(
                  context.l10n.continueWithGoogle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: AppSpacing.value(context, 12)),
        
        if (!kIsWeb) ...[
          // Botão Apple com fundo AZUL sólido
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
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D78BB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.apple, size: 24, color: Colors.white),
                  SizedBox(width: AppSpacing.value(context, 12)),
                  Text(
                    context.l10n.continueWithApple,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
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