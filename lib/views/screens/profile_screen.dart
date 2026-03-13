import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/app_settings_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../l10n/l10n.dart';
import '../../theme/app_theme.dart';

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
    final appSettings = Provider.of<AppSettingsViewModel>(context, listen: false);
    _viewModel = ProfileViewModel(
      authViewModel: authViewModel,
      appSettingsViewModel: appSettings,
    );
    
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
    final l10n = context.l10n;
    final homeViewModel = HomeViewModel();
    final theme = Theme.of(context);
    final tokens = theme.extension<AppThemeTokens>();
    
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.profileTitle),
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
                  Text(
                    l10n.settingsTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
            homeViewModel.onBottomNavTapped(index, context);
          },
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: tokens?.onSurfaceMuted ?? theme.colorScheme.onSurfaceVariant,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: l10n.bottomHome,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite),
              label: l10n.bottomFavorites,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: l10n.bottomProfile,
            ),
          ],
        ),
      ),
    );
  }

  // Cabeçalho com foto de perfil e informações básicas
  Widget _buildProfileHeader(ProfileViewModel viewModel) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final tokens = theme.extension<AppThemeTokens>();
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
                    backgroundColor: tokens?.surfaceMuted ?? theme.colorScheme.surfaceContainerHighest,
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
                        icon: Icon(Icons.camera_alt, color: theme.colorScheme.onPrimary),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.photoChangeSoon)),
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
            l10n.memberSince('${createdAt.day}/${createdAt.month}/${createdAt.year}'),
            style: TextStyle(
              fontSize: 14,
              color: tokens?.onSurfaceMuted ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  // Formulário para edição de dados pessoais
  Widget _buildProfileForm() {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final tokens = theme.extension<AppThemeTokens>();
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.personalInfoTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Campo de nome
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.nameLabel,
              prefixIcon: const Icon(Icons.person),
              border: const OutlineInputBorder(),
            ),
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
          const SizedBox(height: 16),
          
          // Campo de email (desabilitado)
          TextFormField(
            controller: _emailController,
            enabled: false,
            decoration: InputDecoration(
              labelText: l10n.emailLabel,
              prefixIcon: const Icon(Icons.email),
              border: const OutlineInputBorder(),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: tokens?.border ?? theme.colorScheme.outlineVariant,
                ),
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
                      SnackBar(content: Text(l10n.profileUpdatedSuccess)),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.profileUpdatedError)),
                    );
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(l10n.saveChanges),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Seção de configurações gerais do app
  Widget _buildSettingsSection(ProfileViewModel viewModel) {
    final l10n = context.l10n;
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
              title: Text(l10n.notificationsTitle),
              subtitle: Text(l10n.notificationsSubtitle),
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
              title: Text(l10n.darkThemeTitle),
              subtitle: Text(l10n.darkThemeSubtitle),
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
              title: Text(l10n.accessibilityTitle),
              subtitle: Text(l10n.accessibilitySubtitle),
              children: [
                // Tamanho da fonte
                ListTile(
                  title: Text(l10n.fontSizeTitle),
                  subtitle: Slider(
                    value: viewModel.fontSize,
                    min: 0.8,
                    max: 2.0,
                    divisions: 12,
                    label: '${(viewModel.fontSize * 100).round()}%',
                    onChanged: (value) => viewModel.updateFontSize(value),
                  ),
                ),
                // Contraste
                ListTile(
                  title: Text(l10n.contrastTitle),
                  subtitle: Slider(
                    value: viewModel.contrastLevel,
                    min: 1.0,
                    max: 2.0,
                    divisions: 10,
                    label: viewModel.contrastLevel >= 1.75
                        ? l10n.contrastVeryHigh
                        : viewModel.contrastLevel >= 1.35
                            ? l10n.contrastHigh
                            : l10n.contrastNormal,
                    onChanged: (value) => viewModel.updateContrast(value),
                  ),
                ),
                // Espaçamento
                ListTile(
                  title: Text(l10n.spacingTitle),
                  subtitle: Slider(
                    value: viewModel.spacing,
                    min: 0.8,
                    max: 2.0,
                    divisions: 6,
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
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.languageTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
              initialValue: viewModel.language,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.language),
                border: InputBorder.none,
              ),
              items: viewModel.availableLanguages.map((String language) {
                final label = language == 'en'
                    ? l10n.languageEnglish
                    : l10n.languagePortuguese;
                return DropdownMenuItem<String>(
                  value: language,
                  child: Text(label),
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
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final tokens = theme.extension<AppThemeTokens>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.accountDataTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Exportar dados
        ListTile(
          leading: Icon(Icons.download, color: theme.colorScheme.primary),
          title: Text(l10n.exportDataTitle),
          subtitle: Text(l10n.exportDataSubtitle),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: tokens?.border ?? theme.colorScheme.outlineVariant),
          ),
          onTap: () => viewModel.exportUserData(context),
        ),
        const SizedBox(height: 12),
        // Excluir conta
        ListTile(
          leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
          title: Text(l10n.deleteAccountTitle, style: TextStyle(color: theme.colorScheme.error)),
          subtitle: Text(l10n.deleteAccountSubtitle, style: TextStyle(color: theme.colorScheme.error)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.error.withOpacity(0.4)),
          ),
          onTap: () => _confirmDeleteAccount(context),
        ),
      ],
    );
  }

  // Diálogo de confirmação de logout
  void _confirmLogout(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logoutTitle),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
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
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }

  // Diálogo de confirmação para exclusão de conta
  void _confirmDeleteAccount(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccountDialogTitle),
        content: Text(l10n.deleteAccountDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
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
                  SnackBar(content: Text(l10n.accountDeletedSuccess)),
                );
              }
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
} 