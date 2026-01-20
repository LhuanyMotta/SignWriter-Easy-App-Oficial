import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';

/// Tela de Perfil do usuário
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    
    // Usa o AuthViewModel existente
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    _viewModel = ProfileViewModel(authViewModel: authViewModel);
    
    // Inicializa controladores com dados atuais
    final userData = _viewModel.userData ?? {};
    _nameController = TextEditingController(text: userData['name'] as String? ?? '');
    _emailController = TextEditingController(text: userData['email'] as String? ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HomeViewModel _homeViewModel = HomeViewModel();
    
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meu Perfil'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _confirmLogout(context),
            ),
          ],
        ),
        body: Consumer<ProfileViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho do perfil
                  _buildProfileHeader(viewModel),
                  const SizedBox(height: 24),
                  
                  // Formulário de edição de dados
                  _buildProfileForm(),
                  const SizedBox(height: 24),
                  
                  // Seção de configurações
                  const Text(
                    'Configurações',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Switches de configurações
                  _buildSettingsSection(viewModel),
                  const SizedBox(height: 24),
                  
                  // Seleção de idioma
                  _buildLanguageSelector(viewModel),
                  const SizedBox(height: 32),
                  
                  // Botões de ação final
                  _buildActionButtons(viewModel),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 2,
          onTap: (index) {
            _homeViewModel.onBottomNavTapped(index, context);
          },
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favoritos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  // Cabeçalho com foto de perfil e informações básicas
  Widget _buildProfileHeader(ProfileViewModel viewModel) {
    final userData = viewModel.userData ?? {};
    final userName = userData['name'] as String? ?? 'Usuário';
    final createdAt = userData['createdAt'] != null 
      ? DateTime.parse(userData['createdAt'] as String)
      : DateTime.now();
    
    return Column(
      children: [
        // Foto e nivel
        Center(
          child: Column(
            children: [
              // Avatar com opção de edição
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    child: Text(
                      userName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        iconSize: 20,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Alteração de foto será implementada em breve')),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Nível removido: não exibimos mais conquistas no perfil por enquanto
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Data de cadastro
        Center(
          child: Text(
            'Membro desde ${createdAt.day}/${createdAt.month}/${createdAt.year}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  // Formulário para edição de dados pessoais
  Widget _buildProfileForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informações Pessoais',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Campo de nome
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
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
          
          // Campo de email (desabilitado)
          TextFormField(
            controller: _emailController,
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Botão de salvar alterações
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final success = await _viewModel.updateProfile(
                    name: _nameController.text,
                  );
                  
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Perfil atualizado com sucesso!')),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Erro ao atualizar perfil. Tente novamente.')),
                    );
                  }
                }
              },
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('Salvar Alterações'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Seção de configurações gerais do app
  Widget _buildSettingsSection(ProfileViewModel viewModel) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Notificações
            SwitchListTile(
              title: const Text('Notificações'),
              subtitle: const Text('Receba alertas sobre atualizações e novidades'),
              secondary: Icon(
                Icons.notifications,
                color: Theme.of(context).colorScheme.primary,
              ),
              value: viewModel.notificationsEnabled,
              onChanged: (value) => viewModel.toggleNotifications(value),
            ),
            const Divider(),
            
            // Tema escuro
            SwitchListTile(
              title: const Text('Tema Escuro'),
              subtitle: const Text('Utilize o app com cores escuras'),
              secondary: Icon(
                Icons.dark_mode,
                color: Theme.of(context).colorScheme.primary,
              ),
              value: viewModel.darkMode,
              onChanged: (value) => viewModel.toggleDarkMode(value),
            ),
            const Divider(),

            // Acessibilidade
            ExpansionTile(
              leading: Icon(
                Icons.accessibility_new,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Acessibilidade'),
              subtitle: const Text('Personalize a interface para suas necessidades'),
              children: [
                // Tamanho da fonte
                ListTile(
                  title: const Text('Tamanho da Fonte'),
                  subtitle: Slider(
                    value: viewModel.fontSize,
                    min: 0.8,
                    max: 1.5,
                    divisions: 7,
                    label: '${(viewModel.fontSize * 100).round()}%',
                    onChanged: (value) => viewModel.updateFontSize(value),
                  ),
                ),
                // Contraste
                ListTile(
                  title: const Text('Contraste'),
                  subtitle: DropdownButton<double>(
                    value: viewModel.contrastLevel,
                    items: const [
                      DropdownMenuItem(value: 1.0, child: Text('Normal')),
                      DropdownMenuItem(value: 1.5, child: Text('Alto')),
                      DropdownMenuItem(value: 2.0, child: Text('Muito Alto')),
                    ],
                    onChanged: (value) => viewModel.updateContrast(value ?? 1.0),
                  ),
                ),
                // Espaçamento
                ListTile(
                  title: const Text('Espaçamento'),
                  subtitle: Slider(
                    value: viewModel.spacing,
                    min: 1.0,
                    max: 2.0,
                    divisions: 4,
                    label: '${(viewModel.spacing * 100).round()}%',
                    onChanged: (value) => viewModel.updateSpacing(value),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Seletor de idioma do aplicativo
  Widget _buildLanguageSelector(ProfileViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Idioma',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: viewModel.language,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.language),
                border: InputBorder.none,
              ),
              items: viewModel.availableLanguages.map((String language) {
                return DropdownMenuItem<String>(
                  value: language,
                  child: Text(language),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  viewModel.setLanguage(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // Botões de ação para exportar dados e excluir conta
  Widget _buildActionButtons(ProfileViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dados da Conta',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Exportar dados
        ListTile(
          leading: const Icon(Icons.download, color: Colors.blue),
          title: const Text('Exportar Meus Dados'),
          subtitle: const Text('Baixe uma cópia dos seus dados pessoais'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          onTap: () => viewModel.exportUserData(context),
        ),
        const SizedBox(height: 12),
        // Excluir conta
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text('Excluir Minha Conta', style: TextStyle(color: Colors.red)),
          subtitle: const Text('Esta ação é irreversível', style: TextStyle(color: Colors.red)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.red.shade200),
          ),
          onTap: () => _confirmDeleteAccount(context),
        ),
      ],
    );
  }

  // Diálogo de confirmação de logout
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              // Mostra loading
              showDialog(
                context: dialogContext,
                barrierDismissible: false,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              // Faz logout
              await _viewModel.logout(context);
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  // Diálogo de confirmação para exclusão de conta
  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Conta'),
        content: const Text(
          'Tem certeza que deseja excluir sua conta? Esta ação é irreversível e todos os seus dados serão perdidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              // Exibe indicador de progresso
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );
              
              final success = await _viewModel.deleteAccount();
              if (!context.mounted) return;
              
              Navigator.pop(context); // Fecha o diálogo de progresso
              
              if (success) {
                Navigator.pop(context); // Volta para a tela anterior
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Conta excluída com sucesso')),
                );
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
} 