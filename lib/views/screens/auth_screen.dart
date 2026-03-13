import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../l10n/l10n.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../widgets/app_logo.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = _spacing(1);
    final theme = Theme.of(context);
    final tokens = theme.extension<AppThemeTokens>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
              // Cabeçalho fixo (não rolável)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0 * spacing, vertical: 16.0 * spacing),
                child: Column(
                  children: [
                    SizedBox(height: 20 * spacing),
                    const AppLogo(
                      size: 80,
                      colored: true,
                      showText: false,
                    ),
                    SizedBox(height: 16 * spacing),
                    Text(
                      l10n.appTitle,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 8 * spacing),
                    Text(
                      l10n.authSubtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    SizedBox(height: 32 * spacing),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: tokens?.surfaceMuted ?? theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: theme.colorScheme.onPrimary,
                        unselectedLabelColor: tokens?.onSurfaceMuted ?? theme.colorScheme.onSurfaceVariant,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        tabs: [
                          Tab(text: l10n.loginTab),
                          Tab(text: l10n.signupTab),
                        ],
                      ),
                    ),
                    SizedBox(height: 24 * spacing),
                  ],
                ),
              ),
              
              // Área rolável dos formulários
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.0 * spacing),
                    child: _buildLoginTab(l10n),
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.0 * spacing),
                    child: _buildSignupTab(l10n),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  } 

  Widget _buildLoginTab(AppLocalizations l10n) {
    final spacing = _spacing(1);
    final theme = Theme.of(context);
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _emailController,
            label: l10n.emailLabel,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.enterEmailError;
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return l10n.invalidEmailError;
              }
              return null;
            },
          ),
          SizedBox(height: 16 * spacing),
          
          _buildTextField(
            controller: _passwordController,
            label: l10n.passwordLabel,
            icon: Icons.lock_outlined,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.enterPasswordError;
              }
              if (value.length < 6) {
                return l10n.passwordLengthError;
              }
              return null;
            },
          ),
          SizedBox(height: 8 * spacing),
          
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.passwordRecoverySoon)),
                );
              },
              child: Text(
                l10n.forgotPassword,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          SizedBox(height: 16 * spacing),
          
          Consumer<AuthViewModel>(
            builder: (context, viewModel, child) {
              return Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: viewModel.isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: viewModel.isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                              ),
                            )
                          : Text(
                              l10n.loginButton,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  if (viewModel.errorMessage != null) ...[
                    SizedBox(height: 12 * spacing),
                    _buildAuthError(viewModel.errorMessage!),
                  ],
                ],
              );
            },
          ),
          SizedBox(height: 16 * spacing),
          
          _buildDivider(),
          SizedBox(height: 16 * spacing),
          
          _buildSocialLoginButtons(),
        ],
      ),
    );
  }

  Widget _buildSignupTab(AppLocalizations l10n) {
    final spacing = _spacing(1);
    final theme = Theme.of(context);
    return Form(
      key: _signupFormKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: l10n.fullNameLabel,
            icon: Icons.person_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.enterNameError;
              }
              if (value.length < 2) {
                return l10n.nameLengthError;
              }
              return null;
            },
          ),
          SizedBox(height: 16 * spacing),
          
          _buildTextField(
            controller: _emailController,
            label: l10n.emailLabel,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.enterEmailError;
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return l10n.invalidEmailError;
              }
              return null;
            },
          ),
          SizedBox(height: 16 * spacing),
          
          _buildTextField(
            controller: _passwordController,
            label: l10n.passwordLabel,
            icon: Icons.lock_outlined,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.enterPasswordError;
              }
              if (value.length < 6) {
                return l10n.passwordLengthError;
              }
              return null;
            },
          ),
          SizedBox(height: 16 * spacing),
          
          _buildTextField(
            controller: _confirmPasswordController,
            label: l10n.confirmPasswordLabel,
            icon: Icons.lock_outlined,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.confirmPasswordError;
              }
              if (value != _passwordController.text) {
                return l10n.passwordMismatchError;
              }
              return null;
            },
          ),
          SizedBox(height: 24 * spacing),
          
          Consumer<AuthViewModel>(
            builder: (context, viewModel, child) {
              return Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: viewModel.isLoading ? null : _handleSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: viewModel.isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                              ),
                            )
                          : Text(
                              l10n.signupButton,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  if (viewModel.errorMessage != null) ...[
                    SizedBox(height: 12 * spacing),
                    _buildAuthError(viewModel.errorMessage!),
                  ],
                ],
              );
            },
          ),
          SizedBox(height: 16 * spacing),
          
          _buildDivider(),
          SizedBox(height: 16 * spacing),
          
          _buildSocialLoginButtons(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppThemeTokens>();
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: tokens?.border ?? theme.colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: tokens?.border ?? theme.colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error.withOpacity(0.7)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
        filled: true,
        fillColor: tokens?.surfaceMuted ?? theme.colorScheme.surfaceContainerLowest,
        contentPadding: EdgeInsets.symmetric(horizontal: 16 * _spacing(1), vertical: 16 * _spacing(1)),
      ),
    );
  }

  Widget _buildDivider() {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppThemeTokens>();
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: tokens?.border ?? theme.colorScheme.outlineVariant,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * _spacing(1)),
          child: Text(
            context.l10n.orLabel,
            style: TextStyle(
              color: tokens?.onSurfaceMuted ?? theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: tokens?.border ?? theme.colorScheme.outlineVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final tokens = theme.extension<AppThemeTokens>();
    return Column(
      children: [
        Consumer<AuthViewModel>(
          builder: (context, viewModel, child) {
            return SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: viewModel.isLoading ? null : _handleGoogleLogin,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: tokens?.border ?? theme.colorScheme.outlineVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  foregroundColor: theme.colorScheme.onSurface,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'G',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.continueWithGoogle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Consumer<AuthViewModel>(
          builder: (context, viewModel, child) {
            return SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: viewModel.isLoading ? null : _handleAppleLogin,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: tokens?.border ?? theme.colorScheme.outlineVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  foregroundColor: theme.colorScheme.onSurface,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.apple, size: 24, color: theme.colorScheme.onSurface),
                    const SizedBox(width: 12),
                    Text(
                      l10n.continueWithApple,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAuthError(String message) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.error.withOpacity(0.35)),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: theme.colorScheme.onErrorContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  double _spacing(double base) {
    final scale = Theme.of(context).extension<AppThemeTokens>()?.spacingScale ?? 1.0;
    return base * scale;
  }

  void _handleLogin() async {
    final viewModel = context.read<AuthViewModel>();
    if (_loginFormKey.currentState!.validate()) {
      final success = await viewModel.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  void _handleSignup() async {
    final viewModel = context.read<AuthViewModel>();
    if (_signupFormKey.currentState!.validate()) {
      final success = await viewModel.signUpWithEmail(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  void _handleGoogleLogin() async {
    final viewModel = context.read<AuthViewModel>();
    final success = await viewModel.signInWithGoogle();
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _handleAppleLogin() async {
    final viewModel = context.read<AuthViewModel>();
    final success = await viewModel.signInWithApple();
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
}