import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/profile_viewmodel.dart';
import 'screens/home_screen.dart';
import '../theme/app_spacing.dart';
import '../l10n/l10n.dart';

class AccessibilitySettingsView extends StatelessWidget {
  final bool isFirstAccess;

  const AccessibilitySettingsView({
    super.key,
    this.isFirstAccess = false,
  });

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
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        final l10n = context.l10n;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              l10n.accessibilityTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: const Color(0xFF2D78BB),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: ListView(
            padding: EdgeInsets.all(16 * viewModel.spacing),
            children: [
              Text(
                l10n.accessibilityTitle,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: AppSpacing.value(context, 8)),
              Text(
                l10n.accessibilitySubtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: _subtitleColor(context),
                ),
              ),
              SizedBox(height: AppSpacing.value(context, 24)),
              _buildSettingCard(
                context,
                icon: Icons.format_size,
                title: l10n.fontSizeTitle,
                subtitle: '${(viewModel.fontSize * 100).round()}%',
                child: Slider(
                  value: viewModel.fontSize,
                  min: 0.8,
                  max: 1.5,
                  divisions: 7,
                  label: '${(viewModel.fontSize * 100).round()}%',
                  activeColor: const Color(0xFF2D78BB),
                  onChanged: viewModel.updateFontSize,
                ),
              ),
              SizedBox(height: AppSpacing.value(context, 16)),
              _buildSettingCard(
                context,
                icon: Icons.contrast,
                title: l10n.contrastTitle,
                subtitle: '${(viewModel.contrastLevel * 100).round()}%',
                child: Slider(
                  value: viewModel.contrastLevel,
                  min: 0.8,
                  max: 1.5,
                  divisions: 7,
                  label: '${(viewModel.contrastLevel * 100).round()}%',
                  activeColor: const Color(0xFF2D78BB),
                  onChanged: viewModel.updateContrast,
                ),
              ),
              SizedBox(height: AppSpacing.value(context, 16)),
              _buildSettingCard(
                context,
                icon: Icons.space_bar,
                title: l10n.spacingTitle,
                subtitle: '${(viewModel.spacing * 100).round()}%',
                child: Slider(
                  value: viewModel.spacing,
                  min: 0.8,
                  max: 1.5,
                  divisions: 7,
                  label: '${(viewModel.spacing * 100).round()}%',
                  activeColor: const Color(0xFF2D78BB),
                  onChanged: viewModel.updateSpacing,
                ),
              ),
              SizedBox(height: AppSpacing.value(context, 16)),
              _buildSettingCard(
                context,
                icon: Icons.brightness_6,
                title: l10n.themeTitle,
                subtitle: _themeModeLabel(viewModel.themeMode),
                child: Row(
                  children: [
                    Expanded(
                      child: _optionButton(
                        context,
                        title: l10n.themeLight,
                        selected: viewModel.themeMode == AppThemeMode.light,
                        onTap: () => viewModel.setThemeMode(AppThemeMode.light),
                      ),
                    ),
                    SizedBox(width: AppSpacing.value(context, 8)),
                    Expanded(
                      child: _optionButton(
                        context,
                        title: l10n.themeDark,
                        selected: viewModel.themeMode == AppThemeMode.dark,
                        onTap: () => viewModel.setThemeMode(AppThemeMode.dark),
                      ),
                    ),
                    SizedBox(width: AppSpacing.value(context, 8)),
                    Expanded(
                      child: _optionButton(
                        context,
                        title: l10n.themeSystem,
                        selected: viewModel.themeMode == AppThemeMode.system,
                        onTap: () => viewModel.setThemeMode(AppThemeMode.system),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.value(context, 16)),
              _buildSettingCard(
                context,
                icon: Icons.language,
                title: l10n.languageTitle,
                subtitle: viewModel.language == 'English'
                    ? l10n.languageEnglish
                    : l10n.languagePortuguese,
                child: DropdownButtonFormField<String>(
                  value: viewModel.language,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: AppSpacing.symmetric(
                      context,
                      horizontal: 12,
                    ),
                  ),
                  items: viewModel.availableLanguages.map((language) {
                    final label = language == 'English'
                        ? l10n.languageEnglish
                        : l10n.languagePortuguese;

                    return DropdownMenuItem(
                      value: language,
                      child: Text(label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      viewModel.setLanguage(value);
                    }
                  },
                ),
              ),
              SizedBox(height: AppSpacing.value(context, 24)),
              if (isFirstAccess) ...[
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();

                      await prefs.setBool(
                        'has_seen_accessibility',
                        true,
                      );

                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomeScreen(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D78BB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      l10n.save,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.value(context, 12)),
                Center(
                  child: TextButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();

                      await prefs.setBool(
                        'has_seen_accessibility',
                        true,
                      );

                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomeScreen(),
                          ),
                        );
                      }
                    },
                    child: Text(
                      l10n.cancel,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.value(context, 24)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final spacing = context.read<ProfileViewModel>().spacing;

    return Container(
      padding: EdgeInsets.all(18 * spacing),
      decoration: BoxDecoration(
        color: _cardColor(context),
        borderRadius: BorderRadius.circular(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 30, color: const Color(0xFF2D78BB)),
              SizedBox(width: AppSpacing.value(context, 14)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _textColor(context),
                  ),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: _subtitleColor(context),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * spacing),
          child,
        ],
      ),
    );
  }

  Widget _optionButton(
    BuildContext context, {
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: AppSpacing.symmetric(context, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2D78BB) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2D78BB)),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF2D78BB),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
    String _themeModeLabel(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.light:
      return 'Claro';
    case AppThemeMode.dark:
      return 'Escuro';
    case AppThemeMode.system:
      return 'Sistema';
  }
}
}
String _themeModeLabel(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.light:
      return 'Claro';

    case AppThemeMode.dark:
      return 'Escuro';

    case AppThemeMode.system:
      return 'Sistema';
  }
}
}
