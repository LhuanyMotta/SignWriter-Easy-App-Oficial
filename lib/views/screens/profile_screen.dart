import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../accessibility_settings_view.dart';
import '../../theme/app_spacing.dart';
import '../../l10n/l10n.dart';
import '../../routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileViewModel _viewModel;
  final HomeViewModel _homeViewModel = HomeViewModel();

  @override
void initState() {
  super.initState();

  _viewModel = Provider.of<ProfileViewModel>(
    context,
    listen: false,
  );

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await _viewModel.loadInitialData();
    await _viewModel.recoverLostProfileImage();
  });
}

  Color _cardColor(BuildContext context) => Theme.of(context).cardColor;

  Color _textColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : const Color(0xFF333333);

  Color _subtitleColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade400
          : Colors.grey.shade600;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            context.l10n.bottomProfile,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF2D78BB),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Consumer<ProfileViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.userData == null) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2D78BB)),
              );
            }

            return ListView(
              padding: AppSpacing.all(context, 16),
              children: [
                _buildUserCard(context, viewModel),
                SizedBox(height: AppSpacing.value(context, 18)),
                _sectionTitle(context, context.l10n.settingsTitle),
                SizedBox(height: AppSpacing.value(context, 10)),
                _buildSettingsCard(context, viewModel),
                SizedBox(height: AppSpacing.value(context, 18)),
                _sectionTitle(context, context.l10n.accountDataTitle),
                SizedBox(height: AppSpacing.value(context, 10)),
                _buildAccountCard(context, viewModel),
                SizedBox(height: AppSpacing.value(context, 20)),
                _buildLogoutButton(context, viewModel),
              ],
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 2,
          onTap: (index) => _homeViewModel.onBottomNavTapped(index, context),
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: context.l10n.bottomHome),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: context.l10n.bottomFavorites),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: context.l10n.bottomProfile),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, ProfileViewModel viewModel) {
    final userData = viewModel.userData ?? {};
    final name = userData['name'] as String? ?? 'Usuário';
    final email = userData['email'] as String? ?? '';
    final bio = userData['bio'] as String? ?? '';
    final avatarUrl = userData['avatar_url'] as String?;

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      precacheImage(NetworkImage(avatarUrl), context);
    }

    return Container(
      padding: AppSpacing.all(context, 18),
      decoration: BoxDecoration(
        color: _cardColor(context),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.25 : 0.08,
            ),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: const Color(0xFF2D78BB),
                backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null || avatarUrl.isEmpty
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: () => _showImageSourceSheet(context, viewModel),
                  child: Container(
                    padding: AppSpacing.all(context, 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4EB1F0),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: AppSpacing.value(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _textColor(context),
                  ),
                ),
                SizedBox(height: AppSpacing.value(context, 4)),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14,
                    color: _subtitleColor(context),
                  ),
                ),
                if (bio.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.value(context, 8)),
                  Text(
                    bio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: _subtitleColor(context),
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

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, ProfileViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _settingsTile(
            context,
            icon: Icons.accessibility_new,
            title: context.l10n.accessibilityTitle,
            subtitle: context.l10n.accessibilitySubtitle,
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AccessibilitySettingsView(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined, color: Color(0xFF2D78BB)),
            title: Text(
              context.l10n.notificationsTitle,
              style: TextStyle(
                color: _textColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              context.l10n.notificationsSubtitle,
              style: TextStyle(color: _subtitleColor(context)),
            ),
            value: viewModel.notificationsEnabled,
            activeColor: const Color(0xFF2D78BB),
            onChanged: viewModel.toggleNotifications,
          ),
          const Divider(height: 1),
          
        ],
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, ProfileViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _settingsTile(
            context,
            icon: Icons.download_outlined,
            title: context.l10n.exportDataTitle,
            subtitle: context.l10n.exportDataSubtitle,
            color: const Color(0xFF2D78BB),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _exportUserData(context, viewModel),
          ),
          const Divider(height: 1),
          _settingsTile(
            context,
            icon: Icons.delete_outline,
            title: context.l10n.deleteAccountTitle,
            subtitle: context.l10n.deleteAccountSubtitle,
            color: Colors.red,
            trailing: const Icon(Icons.chevron_right, color: Colors.red),
            onTap: () => _confirmDeleteAccount(context, viewModel),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
    Color color = const Color(0xFF2D78BB),
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: color == Colors.red ? Colors.red : _textColor(context),
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: _subtitleColor(context)),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context, ProfileViewModel viewModel) {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(context.l10n.profileSignOutTitle),
              content: Text(context.l10n.profileSignOutContent),
              actions: [
                TextButton(  
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(context.l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text(context.l10n.profileSignOutButton),
                ),
              ],
            ),
          );

          if (confirmed == true && mounted) {
            final success = await viewModel.logout();
            if (success && mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.auth,
                        (route) => false,
                      );
            }
          }
        },
        icon: const Icon(Icons.logout),
        label: Text(context.l10n.profileSignOutConfirm),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Future<void> _showImageSourceSheet(
    BuildContext context,
    ProfileViewModel viewModel,
  ) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: _cardColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: AppSpacing.all(context, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Selecionar Foto',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _textColor(context),
                  ),
                ),
                SizedBox(height: AppSpacing.value(context, 16)),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF2D78BB),
                    child: Icon(Icons.photo_library, color: Colors.white),
                  ),
                  title: Text(context.l10n.profileGallery, style: TextStyle(color: _textColor(context))),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF4EB1F0),
                    child: Icon(Icons.camera_alt, color: Colors.white),
                  ),
                  title: Text(context.l10n.profileCamera, style: TextStyle(color: _textColor(context))),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    final success = await viewModel.uploadProfileImage(source: source);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Foto de perfil atualizada com sucesso!'
              : viewModel.errorMessage ?? context.l10n.profileErrorUpdatePhoto,
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _exportUserData(
    BuildContext context,
    ProfileViewModel viewModel,
  ) async {
    try {
      final jsonData = await viewModel.exportUserData();
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/meus_dados_signwriter.json');
      await file.writeAsString(jsonData);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Meus dados do SignWriter Fácil',
        subject: 'Exportação de dados - SignWriter Fácil',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao exportar dados: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmDeleteAccount(BuildContext context, ProfileViewModel viewModel) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.profileDeleteTitle),
        content: const Text(
          'Tem certeza que deseja excluir sua conta? Esta ação é irreversível.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await viewModel.deleteAccount();
              if (!mounted) return;
              if (success) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.auth,
                    (route) => false,
                  );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(viewModel.errorMessage ?? context.l10n.profileErrorDeleteAccount),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(context.l10n.profileDeleteButton),
          ),
        ],
      ),
    );
  }
}
