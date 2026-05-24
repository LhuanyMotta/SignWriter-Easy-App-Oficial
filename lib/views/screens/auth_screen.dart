import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'home_screen.dart';
import '../widgets/app_logo.dart';
import '../accessibility_settings_view.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late AuthViewModel _viewModel;
  late TabController _tabController;
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
  }

  @override
  void dispose() {
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const AppLogo(
                              size: 80,
                              colored: true,
                              showText: false,
                            ),
                const SizedBox(height: 20),
                Text(
                  'SignWriter Fácil',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D78BB),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Conecte-se para começar',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 32),
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
                    tabs: const [
                      Tab(text: 'Entrar'),
                      Tab(text: 'Cadastrar'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
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
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _loginFormKey,
        child: Column(
          children: [
            _buildTextField(
              controller: _loginEmailController,
              label: 'Email',
              hintText: 'Digite seu email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira seu email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Por favor, insira um email válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _loginPasswordController,
              label: 'Senha',
              hintText: 'Digite sua senha',
              icon: Icons.lock_outlined,
              isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira sua senha';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Recuperação de senha será implementada em breve'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Text(
                  'Esqueci minha senha',
                  style: TextStyle(
                    color: const Color(0xFF2D78BB),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
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
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.login, size: 22),
                              SizedBox(width: 10),
                              Text(
                                'Entrar',
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
            const SizedBox(height: 20),
            
            _buildDivider(),
            const SizedBox(height: 20),
            
            _buildSocialLoginButtons(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _signupFormKey,
        child: Column(
          children: [
            _buildTextField(
              controller: _signupNameController,
              label: 'Nome completo',
              hintText: 'Digite seu nome completo',
              icon: Icons.person_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira seu nome';
                }
                if (value.length < 2) {
                  return 'O nome deve ter pelo menos 2 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _signupEmailController,
              label: 'Email',
              hintText: 'Digite seu email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira seu email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Por favor, insira um email válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _signupPasswordController,
              label: 'Senha',
              hintText: 'Digite sua senha',
              icon: Icons.lock_outlined,
              isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira uma senha';
                }
                if (value.length < 6) {
                  return 'A senha deve ter pelo menos 6 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _confirmPasswordController,
              label: 'Confirmar senha',
              hintText: 'Confirme sua senha',
              icon: Icons.lock_outlined,
              isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, confirme sua senha';
                }
                if (value != _signupPasswordController.text) {
                  return 'As senhas não coincidem';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            
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
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_add, size: 22),
                              SizedBox(width: 10),
                              Text(
                                'Cadastrar',
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
            const SizedBox(height: 20),
            
            _buildDivider(),
            const SizedBox(height: 20),
            
            _buildSocialLoginButtons(),
            const SizedBox(height: 32),
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
        const SizedBox(height: 6),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ou',
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
              if (!success && _viewModel.error != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
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
            child: const Row(
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
                SizedBox(width: 12),
                Text(
                  'Continuar com Google',
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
        const SizedBox(height: 12),
        
        // Botão Apple com fundo AZUL sólido
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () async {
              final success = await _viewModel.signInWithApple();
              if (!success && _viewModel.error != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
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
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.apple, size: 24, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Continuar com Apple',
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
    );
  }

  void _handleLogin(AuthViewModel viewModel, BuildContext context) async {
    if (_loginFormKey.currentState!.validate()) {
      final success = await viewModel.signInWithEmail(
        email: _loginEmailController.text,
        password: _loginPasswordController.text,
      );
      
      if (success && mounted) {
        // Navega para HomeScreen
        await _navigateAfterAuth();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.error ?? 'Erro no login'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _handleSignup(AuthViewModel viewModel, BuildContext context) async {
    if (_signupFormKey.currentState!.validate()) {
      final success = await viewModel.signUpWithEmail(
        name: _signupNameController.text,
        email: _signupEmailController.text,
        password: _signupPasswordController.text,
      );
      
      if (success && mounted) {
        // Navega para HomeScreen
        await _navigateAfterAuth();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.error ?? 'Erro no cadastro'),
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
}