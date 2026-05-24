import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/profile_viewmodel.dart';
import 'screens/home_screen.dart';

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
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text(
              'Acessibilidade',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: const Color(0xFF2D78BB),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Configurações de Acessibilidade',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ajuste a experiência visual do aplicativo.',
                style: TextStyle(
                  fontSize: 14,
                  color: _subtitleColor(context),
                ),
              ),
              const SizedBox(height: 24),
              _buildSettingCard(
                context,
                icon: Icons.format_size,
                title: 'Tamanho da Fonte',
                subtitle: '${(viewModel.fontSize * 100).round()}%',
                child: Slider(
                  value: viewModel.fontSize,
                  min: 0.8,
                  max: 2.0,
                  divisions: 12,
                  label: '${(viewModel.fontSize * 100).round()}%',
                  activeColor: const Color(0xFF2D78BB),
                  onChanged: viewModel.updateFontSize,
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingCard(
                context,
                icon: Icons.contrast,
                title: 'Contraste',
                subtitle: '${(viewModel.contrastLevel * 100).round()}%',
                child: Slider(
                  value: viewModel.contrastLevel,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  label: '${(viewModel.contrastLevel * 100).round()}%',
                  activeColor: const Color(0xFF2D78BB),
                  onChanged: viewModel.updateContrast,
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingCard(
                context,
                icon: Icons.space_bar,
                title: 'Espaçamento',
                subtitle: '${(viewModel.spacing * 100).round()}%',
                child: Slider(
                  value: viewModel.spacing,
                  min: 0.8,
                  max: 2.0,
                  divisions: 12,
                  label: '${(viewModel.spacing * 100).round()}%',
                  activeColor: const Color(0xFF2D78BB),
                  onChanged: viewModel.updateSpacing,
                ),
              ),
              const SizedBox(height: 16),

_buildSettingCard(
  context,
  icon: Icons.brightness_6,
  title: 'Tema',
  subtitle: viewModel.themeMode.name,
  child: Row(
    children: [
      Expanded(
        child: _optionButton(
          context,
          title: 'Claro',
          selected: viewModel.themeMode == AppThemeMode.light,
          onTap: () => viewModel.setThemeMode(AppThemeMode.light),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _optionButton(
          context,
          title: 'Escuro',
          selected: viewModel.themeMode == AppThemeMode.dark,
          onTap: () => viewModel.setThemeMode(AppThemeMode.dark),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _optionButton(
          context,
          title: 'Sistema',
          selected: viewModel.themeMode == AppThemeMode.system,
          onTap: () => viewModel.setThemeMode(AppThemeMode.system),
        ),
      ),
    ],
  ),
),

const SizedBox(height: 16),

_buildSettingCard(
  context,
  icon: Icons.language,
  title: 'Idioma',
  subtitle: viewModel.language,
  child: DropdownButtonFormField<String>(
    value: viewModel.language,
    decoration: InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    ),
    items: viewModel.availableLanguages.map((language) {
      return DropdownMenuItem(
        value: language,
        child: Text(language),
      );
    }).toList(),
    onChanged: (value) {
      if (value != null) {
        viewModel.setLanguage(value);
      }
    },
  ),
),
              const SizedBox(height: 24),

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
      child: const Text(
        'Salvar e continuar',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),

  const SizedBox(height: 12),

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
      child: const Text(
        'Pular por enquanto',
      ),
    ),
  ),

  const SizedBox(height: 24),
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
    return Container(
      padding: const EdgeInsets.all(18),
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
              const SizedBox(width: 14),
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
          const SizedBox(height: 16),
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
      padding: const EdgeInsets.symmetric(vertical: 12),
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
}
}
