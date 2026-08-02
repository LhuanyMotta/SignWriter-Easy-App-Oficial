import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/export_data.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../accessibility_settings_view.dart';
import '../../theme/app_radius.dart';
import '../../theme/adaptive_nav_scaffold.dart';
import '../../theme/responsive_content.dart';
import '../../l10n/l10n.dart';
import '../../routes/app_routes.dart';
import '../widgets/states/app_error_state.dart';
import '../widgets/states/app_loading_state.dart';
import '../widgets/states/app_status_banner.dart';

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
    _viewModel = Provider.of<ProfileViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _viewModel.loadInitialData();
      await _viewModel.recoverLostProfileImage();
    });
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _card => Theme.of(context).cardColor;
  Color get _text => _isDark ? Colors.white : const Color(0xFF1E1E1E);
  Color get _sub => _isDark ? Colors.grey.shade400 : Colors.grey.shade600;
  Color get _primary => Theme.of(context).colorScheme.primary;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: AdaptiveNavScaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(title: Text(context.l10n.bottomProfile)),
        body: ResponsiveContent(
          maxWidth: 720,
          child: Consumer<ProfileViewModel>(
            builder: (context, vm, _) {
              if (vm.isLoading && vm.userData == null) {
                return const AppLoadingState(message: 'Carregando perfil...');
              }
              if (vm.userData == null) {
                return AppErrorState(
                  message: vm.errorMessage ??
                      'Não foi possível carregar o perfil.',
                  onRetry: vm.loadInitialData,
                );
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                children: [
                  if (vm.errorMessage != null) ...[
                    AppStatusBanner(
                      title: vm.errorMessage!,
                      tone: AppStatusBannerTone.warning,
                      icon: Icons.warning_amber_rounded,
                      onAction: vm.loadInitialData,
                      actionTooltip: 'Tentar novamente',
                    ),
                    const SizedBox(height: 12),
                  ],
                  _heroCard(vm),
                  const SizedBox(height: 20),
                  _bioCard(vm),
                  const SizedBox(height: 20),
                  _label(context.l10n.settingsTitle),
                  const SizedBox(height: 10),
                  _settingsCard(vm),
                  const SizedBox(height: 20),
                  _label(context.l10n.accountDataTitle),
                  const SizedBox(height: 10),
                  _accountCard(vm),
                  const SizedBox(height: 24),
                  _logoutBtn(vm),
                ],
              );
            },
          ),
        ),
        currentIndex: 1,
        homeLabel: context.l10n.bottomHome,
        profileLabel: context.l10n.bottomProfile,
        onTabSelected: (i) => _homeViewModel.onBottomNavTapped(i, context),
      ),
    );
  }

  // ── Hero card ────────────────────────────────────────────────────────────

  Widget _heroCard(ProfileViewModel vm) {
    final data = vm.userData ?? {};
    final name = (data['name'] as String? ?? 'Usuário').trim();
    final email = data['email'] as String? ?? '';
    final avatarUrl = data['avatar_url'] as String?;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primary, _primary.withValues(alpha: 0.78)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar com botão de câmera
          GestureDetector(
            onTap: () => _showAvatarSheet(vm, hasAvatar),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5), width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    backgroundImage:
                        hasAvatar ? NetworkImage(avatarUrl!) : null,
                    child: !hasAvatar
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                        )
                      ],
                    ),
                    child: Icon(Icons.camera_alt, size: 14, color: _primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  style:
                      TextStyle(color: Colors.white.withValues(alpha: 0.80), fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () => _showEditSheet(vm),
                  icon: const Icon(Icons.edit_outlined, size: 14, color: Colors.white),
                  label: const Text('Editar perfil',
                      style: TextStyle(color: Colors.white, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bio card ────────────────────────────────────────────────────────────

  Widget _bioCard(ProfileViewModel vm) {
    final bio = (vm.userData?['bio'] as String? ?? '').trim();
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
            color: _isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sobre mim',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14, color: _text)),
                TextButton.icon(
                  onPressed: () => _showEditSheet(vm),
                  icon: Icon(Icons.edit_outlined, size: 14, color: _primary),
                  label: Text('Editar',
                      style: TextStyle(color: _primary, fontSize: 13)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: bio.isNotEmpty
                ? Text(bio, style: TextStyle(color: _sub, height: 1.5))
                : GestureDetector(
                    onTap: () => _showEditSheet(vm),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _isDark ? Colors.white12 : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.add, size: 15, color: _primary),
                          const SizedBox(width: 8),
                          Text('Adicionar uma bio',
                              style: TextStyle(color: _primary, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Settings ────────────────────────────────────────────────────────────

  Widget _settingsCard(ProfileViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
            color: _isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _tile(
            icon: Icons.accessibility_new_rounded,
            title: context.l10n.accessibilityTitle,
            subtitle: context.l10n.accessibilitySubtitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const AccessibilitySettingsView()),
            ),
          ),
          _divider(),
          SwitchListTile(
            secondary: Icon(Icons.notifications_outlined, color: _primary),
            title: Text(context.l10n.notificationsTitle,
                style: TextStyle(color: _text, fontWeight: FontWeight.w600)),
            subtitle: Text(context.l10n.notificationsSubtitle,
                style: TextStyle(color: _sub)),
            value: vm.notificationsEnabled,
            activeColor: _primary,
            onChanged: vm.toggleNotifications,
          ),
        ],
      ),
    );
  }

  // ── Account ─────────────────────────────────────────────────────────────

  Widget _accountCard(ProfileViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
            color: _isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _tile(
            icon: Icons.download_outlined,
            title: context.l10n.exportDataTitle,
            subtitle: context.l10n.exportDataSubtitle,
            onTap: () => _doExport(vm),
          ),
          _divider(),
          _tile(
            icon: Icons.delete_outline,
            title: context.l10n.deleteAccountTitle,
            subtitle: context.l10n.deleteAccountSubtitle,
            color: Colors.red,
            onTap: () => _confirmDelete(vm),
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? _primary;
    return ListTile(
      leading: Icon(icon, color: c),
      title: Text(title,
          style: TextStyle(
              color: color == Colors.red ? Colors.red : _text,
              fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(color: _sub)),
      trailing: Icon(Icons.chevron_right, color: _sub),
      onTap: onTap,
    );
  }

  Widget _divider() => Divider(
        height: 1,
        color: _isDark ? Colors.white10 : Colors.grey.shade200,
        indent: 16,
        endIndent: 16,
      );

  Widget _label(String text) => Text(text,
      style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: _sub));

  // ── Logout ──────────────────────────────────────────────────────────────

  Widget _logoutBtn(ProfileViewModel vm) {
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
                    child: Text(context.l10n.cancel)),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text(context.l10n.profileSignOutButton),
                ),
              ],
            ),
          );
          if (confirmed == true && mounted) {
            final ok = await vm.logout();
            if (!mounted) return;
            if (ok) {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(AppRoutes.auth, (_) => false);
            } else {
              _snack(
                vm.errorMessage ?? 'Não foi possível sair. Tente novamente.',
                false,
              );
            }
          }
        },
        icon: const Icon(Icons.logout),
        label: Text(context.l10n.profileSignOutConfirm),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  // ── Sheets ───────────────────────────────────────────────────────────────

  Future<void> _showAvatarSheet(ProfileViewModel vm, bool hasAvatar) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              Text('Foto de Perfil',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: _text)),
              const SizedBox(height: 12),
              ListTile(
                leading: CircleAvatar(
                    backgroundColor: _primary,
                    child: const Icon(Icons.photo_library, color: Colors.white)),
                title: Text(context.l10n.profileGallery,
                    style: TextStyle(
                        color: _text, fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(context, 'gallery'),
              ),
              ListTile(
                leading: CircleAvatar(
                    backgroundColor: _primary.withValues(alpha: 0.7),
                    child: const Icon(Icons.camera_alt, color: Colors.white)),
                title: Text(context.l10n.profileCamera,
                    style: TextStyle(
                        color: _text, fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(context, 'camera'),
              ),
              if (hasAvatar) ...[
                Divider(color: _isDark ? Colors.white12 : Colors.grey.shade200),
                ListTile(
                  leading: const CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(Icons.delete_outline, color: Colors.white)),
                  title: const Text('Remover foto',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.w600)),
                  onTap: () => Navigator.pop(context, 'remove'),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    if (action == null || !mounted) return;

    if (action == 'remove') {
      final ok = await vm.removeProfileImage();
      if (!mounted) return;
      _snack(ok ? 'Foto removida!' : vm.errorMessage ?? 'Erro ao remover.', ok);
      return;
    }

    final source =
        action == 'gallery' ? ImageSource.gallery : ImageSource.camera;
    final ok = await vm.uploadProfileImage(source: source);
    if (!mounted) return;
    _snack(ok ? 'Foto atualizada!' : vm.errorMessage ?? context.l10n.profileErrorUpdatePhoto, ok);
  }

  Future<void> _showEditSheet(ProfileViewModel vm) async {
    final data = vm.userData ?? {};
    final nameCtrl = TextEditingController(text: data['name'] as String? ?? '');
    final bioCtrl = TextEditingController(text: data['bio'] as String? ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, MediaQuery.of(sheetCtx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            Text('Editar Perfil',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _text)),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Nome',
                prefixIcon: Icon(Icons.person_outline, color: _primary),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bioCtrl,
              decoration: InputDecoration(
                labelText: 'Bio',
                hintText: 'Fale um pouco sobre você...',
                prefixIcon: Icon(Icons.edit_note, color: _primary),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              maxLength: 160,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Pega o email direto do auth — fonte confiável e imutável
                  final authEmail =
                      Supabase.instance.client.auth.currentUser?.email ?? '';
                  final ok = await vm.updateProfile(
                    name: nameCtrl.text.trim(),
                    email: authEmail,
                    bio: bioCtrl.text.trim(),
                  );
                  if (!mounted) return;
                  Navigator.pop(sheetCtx);
                  _snack(
                    ok
                        ? 'Perfil atualizado!'
                        : (vm.errorMessage ??
                            'Não foi possível salvar. Tente novamente.'),
                    ok,
                  );
                },
                child: const Text('Salvar alterações'),
              ),
            ),
          ],
        ),
      ),
    );

    nameCtrl.dispose();
    bioCtrl.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  void _snack(String msg, bool ok) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: ok ? Colors.green : Colors.red,
    ));
  }

  Future<void> _doExport(ProfileViewModel vm) async {
    try {
      final data = await vm.exportUserData();
      await shareExportedUserData(data,
          shareText: 'Meus dados do SignWriter Fácil',
          shareSubject: 'Exportação - SignWriter Fácil');
    } catch (e) {
      if (!mounted) return;
      _snack('Erro ao exportar: $e', false);
    }
  }

  void _confirmDelete(ProfileViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.profileDeleteTitle),
        content: const Text(
            'Esta ação é irreversível. Todos os seus dados serão apagados.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel)),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final ok = await vm.deleteAccount();
              if (!mounted) return;
              if (ok) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(AppRoutes.auth, (_) => false);
              } else {
                _snack(vm.errorMessage ?? context.l10n.profileErrorDeleteAccount, false);
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