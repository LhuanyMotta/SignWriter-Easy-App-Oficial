import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import 'package:image_picker/image_picker.dart';

/// Tela de Perfil do usuário
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ProfileViewModel _viewModel;
  final HomeViewModel _homeViewModel = HomeViewModel();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileViewModel();
    _tabController = TabController(length: 3, vsync: this);
    
    // Carrega dados do usuário
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
      _viewModel.recoverLostProfileImage();
    });
  }

  void _loadUserData() {
    final userData = _viewModel.userData;
    if (userData != null) {
      _nameController.text = userData['name'] ?? '';
      _emailController.text = userData['email'] ?? '';
      _bioController.text = userData['bio'] ?? '';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Meu Perfil',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF2D78BB),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            tabs: const [
              Tab(text: 'Perfil'),
              Tab(text: 'Configurações'),
              Tab(text: 'Acessibilidade'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProfileTab(),
            _buildSettingsTab(),
            _buildAccessibilityTab(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 2,
          onTap: (index) {
            _homeViewModel.onBottomNavTapped(index, context);
          },
          selectedItemColor: const Color(0xFF2D78BB),
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

  Widget _buildProfileTab() {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.userData == null) {
  return const Center(
    child: CircularProgressIndicator(
      color: Color(0xFF2D78BB),
    ),
  );
}
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho do perfil
              _buildProfileHeader(viewModel),
              const SizedBox(height: 24),
              
              // Formulário de edição
              _buildProfileForm(viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(ProfileViewModel viewModel) {
  final userData = viewModel.userData ?? {};
  final userName = userData['name'] as String? ?? 'Usuário';
  final userEmail = userData['email'] as String? ?? '';
  final userBio = userData['bio'] as String? ?? '';
  final avatarUrl = userData['avatar_url'] as String?;
  if (avatarUrl != null && avatarUrl.isNotEmpty) {
  precacheImage(NetworkImage(avatarUrl), context);
}

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ],
    ),
    child: Column(
      children: [
        Center(
          child: Stack(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D78BB),
                  borderRadius: BorderRadius.circular(55),
                  image: avatarUrl != null && avatarUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(avatarUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: avatarUrl == null || avatarUrl.isEmpty
                    ? Center(
                        child: Text(
                          userName.isNotEmpty
                              ? userName.substring(0, 1).toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),

              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF4EB1F0),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: IconButton(
                    iconSize: 20,
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: () async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Selecionar Foto',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D78BB),
                ),
              ),

              const SizedBox(height: 24),

              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF2D78BB),
                  child: Icon(
                    Icons.photo_library,
                    color: Colors.white,
                  ),
                ),
                title: const Text('Galeria'),
                subtitle: const Text(
                  'Escolher imagem do dispositivo',
                ),
                onTap: () => Navigator.pop(
                  context,
                  ImageSource.gallery,
                ),
              ),

              const SizedBox(height: 8),

              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF4EB1F0),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  ),
                ),
                title: const Text('Câmera'),
                subtitle: const Text(
                  'Tirar foto agora',
                ),
                onTap: () => Navigator.pop(
                  context,
                  ImageSource.camera,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  if (source == null) return;

  final success = await viewModel.uploadProfileImage(
    source: source,
  );

  if (success && mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Foto de perfil atualizada com sucesso!',
        ),
        backgroundColor: Colors.green,
      ),
    );
  } else if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          viewModel.errorMessage ??
              'Erro ao atualizar foto',
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
},
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        Text(
          userName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          userEmail,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),

        if (userBio.isNotEmpty) ...[
          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF2D78BB).withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF2D78BB).withOpacity(0.15),
              ),
            ),
            child: Text(
              userBio,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

  Widget _buildProfileForm(ProfileViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Editar Perfil',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D78BB),
              ),
            ),
            const SizedBox(height: 20),
            
            // Campo de nome
            _buildFormField(
              label: 'Nome',
              controller: _nameController,
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
            
            // Campo de email
            _buildFormField(
              label: 'Email',
              controller: _emailController,
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
            
            // Campo de bio (opcional)
            _buildFormField(
              label: 'Bio (opcional)',
              controller: _bioController,
              icon: Icons.info_outlined,
              maxLines: 3,
              validator: null,
            ),
            const SizedBox(height: 24),
            
            // Botão de salvar alterações
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: viewModel.isLoading ? null : () async {
                  final success = await viewModel.updateProfile(
                    name: _nameController.text,
                    email: _emailController.text,
                    bio: _bioController.text,
                  );
                  
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Perfil atualizado com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(viewModel.errorMessage ?? 'Erro ao atualizar perfil'),
                        backgroundColor: Colors.red,
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
                          Icon(Icons.save, size: 22),
                          SizedBox(width: 10),
                          Text(
                            'Salvar Alterações',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines = 1,
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
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: 'Digite seu $label',
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
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines == 1 ? 18 : 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Configurações',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D78BB),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Personalize as configurações do aplicativo',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              
              // Configurações de Notificações e Tema
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Notificações
                    _buildSettingsItem(
                      icon: Icons.notifications_outlined,
                      title: 'Notificações',
                      subtitle: 'Receba alertas sobre atualizações',
                      trailing: Switch(
                        value: viewModel.notificationsEnabled,
                        onChanged: (value) => viewModel.toggleNotifications(value),
                        activeColor: const Color(0xFF2D78BB),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1),
                    ),
                    
                    // Tema escuro
                    _buildSettingsItem(
                      icon: Icons.dark_mode_outlined,
                      title: 'Tema Escuro',
                      subtitle: 'Utilize o app com cores escuras',
                      trailing: Switch(
                        value: viewModel.darkMode,
                        onChanged: (value) => viewModel.toggleDarkMode(value),
                        activeColor: const Color(0xFF2D78BB),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Idioma
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Idioma',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButton<String>(
                        value: viewModel.language,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2D78BB)),
                        onChanged: (value) {
                          if (value != null) {
                            viewModel.setLanguage(value);
                          }
                        },
                        items: viewModel.availableLanguages.map((String language) {
                          return DropdownMenuItem<String>(
                            value: language,
                            child: Text(
                              language,
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Seção de Dados da Conta
              const Text(
                'Dados da Conta',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D78BB),
                ),
              ),
              const SizedBox(height: 16),
              
              // Exportar Dados
              _buildSettingsCard(
                icon: Icons.download_outlined,
                title: 'Exportar Meus Dados',
                subtitle: 'Baixe uma cópia dos seus dados pessoais',
                color: const Color(0xFF2D78BB),
                onTap: () => _exportUserData(context, viewModel),
              ),
              
              const SizedBox(height: 12),
              
              // Excluir Conta
              _buildSettingsCard(
                icon: Icons.delete_outline,
                title: 'Excluir Minha Conta',
                subtitle: 'Esta ação é irreversível',
                color: Colors.red,
                onTap: () => _confirmDeleteAccount(context, viewModel),
              ),
              
              const SizedBox(height: 24),
              
              // Botão de logout
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sair da conta'),
                        content: const Text('Tem certeza que deseja sair?'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF2D78BB),
                            ),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Sair'),
                          ),
                        ],
                      ),
                    );
                    
                    if (confirmed == true && mounted) {
                      final success = await viewModel.logout();
                      if (success && mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(viewModel.errorMessage ?? 'Erro ao fazer logout'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Sair da Conta',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccessibilityTab() {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Acessibilidade',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D78BB),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ajuste as configurações para melhorar sua experiência',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              
              // Tamanho da Fonte
              _buildAccessibilityCard(
                icon: Icons.text_fields_outlined,
                title: 'Tamanho da Fonte',
                subtitle: '${(viewModel.fontSize * 100).toInt()}%',
                child: Slider(
                  value: viewModel.fontSize,
                  min: 0.8,
                  max: 2.0,
                  divisions: 12,
                  onChanged: (value) => viewModel.updateFontSize(value),
                  activeColor: const Color(0xFF2D78BB),
                  inactiveColor: Colors.grey.shade300,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Contraste
              _buildAccessibilityCard(
                icon: Icons.contrast_outlined,
                title: 'Contraste',
                subtitle: '${(viewModel.contrastLevel * 100).toInt()}%',
                child: Slider(
                  value: viewModel.contrastLevel,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  onChanged: (value) => viewModel.updateContrast(value),
                  activeColor: const Color(0xFF2D78BB),
                  inactiveColor: Colors.grey.shade300,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Espaçamento
              _buildAccessibilityCard(
                icon: Icons.space_dashboard_outlined,
                title: 'Espaçamento',
                subtitle: '${(viewModel.spacing * 100).toInt()}%',
                child: Slider(
                  value: viewModel.spacing,
                  min: 0.8,
                  max: 2.0,
                  divisions: 12,
                  onChanged: (value) => viewModel.updateSpacing(value),
                  activeColor: const Color(0xFF2D78BB),
                  inactiveColor: Colors.grey.shade300,
                ),
              ),
              
              const SizedBox(height: 32),

              // Botão para redefinir configurações
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    viewModel.updateFontSize(1.0);
                    viewModel.updateContrast(1.0);
                    viewModel.updateSpacing(1.0);
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
                      Icon(Icons.restart_alt, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Redefinir para Padrão',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2D78BB), size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        trailing,
      ],
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccessibilityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2D78BB), size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // Método para exportar dados do usuário
  Future<void> _exportUserData(BuildContext context, ProfileViewModel viewModel) async {
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF2D78BB)),
              SizedBox(height: 16),
              Text('Preparando dados para exportação...'),
            ],
          ),
        ),
      );

      // Exportar dados
      final jsonData = await viewModel.exportUserData();
      
      // Criar arquivo temporário
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/meus_dados_signwriter.json');
      await file.writeAsString(jsonData);
      
      // Fechar loading
      if (mounted) Navigator.pop(context);
      
      // Compartilhar arquivo
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Meus dados do SignWriter Fácil',
        subject: 'Exportação de dados - SignWriter Fácil',
      );
      
    } catch (e) {
      if (mounted) Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Diálogo de confirmação para exclusão de conta
  void _confirmDeleteAccount(BuildContext context, ProfileViewModel viewModel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Excluir Conta'),
        content: const Text(
          'Tem certeza que deseja excluir sua conta? Esta ação é irreversível e todos os seus dados serão perdidos permanentemente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2D78BB),
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              
              // Mostrar loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF2D78BB)),
                      SizedBox(height: 16),
                      Text('Excluindo conta...'),
                    ],
                  ),
                ),
              );

              final success = await viewModel.deleteAccount();
              
              if (!mounted) return;
              
              Navigator.pop(context); // Fechar loading
              
              if (success) {
                // Redirecionar para tela inicial
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Conta excluída com sucesso'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(viewModel.errorMessage ?? 'Erro ao excluir conta'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Excluir Conta'),
          ),
        ],
      ),
    );
  }
}