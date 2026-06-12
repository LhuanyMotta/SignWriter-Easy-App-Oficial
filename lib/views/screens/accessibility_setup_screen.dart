import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/app_settings_viewmodel.dart';

/// Tela de configuração inicial de acessibilidade (primeiro acesso).
///
/// Versão simplificada:
/// - Nome do app centralizado no topo.
/// - Ação "Pular configuração" no topo.
/// - Conteúdo fixo, sem rolagem.
/// - Botão único "Salvar e continuar" no rodapé.
class AccessibilitySetupScreen extends StatelessWidget {
  const AccessibilitySetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        // Nome do app centralizado conforme solicitado.
        title: const Text('SignWriter Fácil'),
        // Ação de pular no topo para não competir com o CTA principal de baixo.
        actions: [
          TextButton(
            onPressed: () => _finish(context, settings),
            child: Text(context.l10n.accessibilitySkip),
          ),
        ],
      ),
      body: SafeArea(
        // Sem SingleChildScrollView para impedir rolagem e manter fluxo direto.
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Ajuste rápido de acessibilidade',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Você pode mudar tudo depois no Perfil.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 10),

              // Área principal com os controles, distribuída para caber na tela.
              Expanded(
                child: Consumer<AppSettingsViewModel>(
                  builder: (context, model, _) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _CompactSlider(
                          icon: Icons.format_size,
                          label: 'Tamanho da fonte',
                          valueText: '${(model.fontScale * 100).round()}%',
                          value: model.fontScale,
                          min: 0.8,
                          max: 2.0,
                          divisions: 12,
                          onChanged: model.updateFontScale,
                        ),
                        _CompactSlider(
                          icon: Icons.contrast,
                          label: 'Contraste',
                          valueText: model.contrastLevel >= 1.75
                              ? 'Muito alto'
                              : model.contrastLevel >= 1.35
                                  ? 'Alto'
                                  : 'Normal',
                          value: model.contrastLevel,
                          min: 1.0,
                          max: 2.0,
                          divisions: 10,
                          onChanged: model.updateContrastLevel,
                        ),
                        _CompactSlider(
                          icon: Icons.space_bar,
                          label: 'Espaçamento',
                          valueText: '${(model.spacingScale * 100).round()}%',
                          value: model.spacingScale,
                          min: 0.8,
                          max: 2.0,
                          divisions: 12,
                          onChanged: model.updateSpacingScale,
                        ),

                        // Tema em chips com ícones.
                        _CompactSection(
                          icon: Icons.brightness_6,
                          title: 'Tema',
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _ThemeChip(
                                label: 'Claro',
                                icon: Icons.light_mode,
                                selected: model.themeMode == ThemeMode.light,
                                onTap: () => model.setThemeMode(ThemeMode.light),
                              ),
                              _ThemeChip(
                                label: 'Escuro',
                                icon: Icons.dark_mode,
                                selected: model.themeMode == ThemeMode.dark,
                                onTap: () => model.setThemeMode(ThemeMode.dark),
                              ),
                              _ThemeChip(
                                label: 'Sistema',
                                icon: Icons.brightness_auto,
                                selected: model.themeMode == ThemeMode.system,
                                onTap: () => model.setThemeMode(ThemeMode.system),
                              ),
                            ],
                          ),
                        ),

                        // Idioma em chips para manter seleção rápida.
                        _CompactSection(
                          icon: Icons.language,
                          title: 'Idioma',
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _LanguageChip(
                                label: 'Português',
                                selected: model.locale.languageCode == 'pt',
                                onTap: () => model.setLocale(const Locale('pt')),
                              ),
                              _LanguageChip(
                                label: 'English',
                                selected: model.locale.languageCode == 'en',
                                onTap: () => model.setLocale(const Locale('en')),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // CTA principal no rodapé.
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _finish(context, settings),
                  child: const Text('Salvar e continuar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Marca onboarding como concluído e segue para autenticação.
  Future<void> _finish(BuildContext context, AppSettingsViewModel settings) async {
    await settings.markOnboardingDone();
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/auth');
  }
}

/// Bloco compacto para sliders da tela inicial.
class _CompactSlider extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valueText;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _CompactSlider({
    required this.icon,
    required this.label,
    required this.valueText,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _CompactSection(
      icon: icon,
      title: label,
      trailing: Text(
        valueText,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }
}

/// Seção compacta reutilizável para manter a tela consistente e curta.
class _CompactSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailing;

  const _CompactSection({
    required this.icon,
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

/// Chip de idioma para seleção rápida na primeira execução.
class _LanguageChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: colors.primary,
      labelStyle: TextStyle(
        color: selected ? colors.onPrimary : null,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => onTap(),
    );
  }
}

/// Chip de tema com ícone visual.
class _ThemeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 16,
        color: selected ? colors.onPrimary : null,
      ),
      label: Text(label),
      selected: selected,
      selectedColor: colors.primary,
      labelStyle: TextStyle(
        color: selected ? colors.onPrimary : null,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => onTap(),
    );
  }
}
