import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';

class AccessibilitySettingsView extends StatelessWidget {
  const AccessibilitySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Configurações de Acessibilidade'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSettingCard(
                context,
                icon: Icons.format_size,
                title: 'Tamanho da Fonte',
                subtitle: 'Ajuste o tamanho do texto',
                child: Slider(
                  value: viewModel.fontSize,
                  min: 0.8,
                  max: 2.0,
                  divisions: 12,
                  label: '${(viewModel.fontSize * 100).round()}%',
                  onChanged: (value) => viewModel.updateFontSize(value),
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingCard(
                context,
                icon: Icons.contrast,
                title: 'Contraste',
                subtitle: 'Ajuste o contraste das cores',
                child: Slider(
                  value: viewModel.contrastLevel,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  label: '${(viewModel.contrastLevel * 100).round()}%',
                  onChanged: (value) => viewModel.updateContrast(value),
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingCard(
                context,
                icon: Icons.space_bar,
                title: 'Espaçamento',
                subtitle: 'Ajuste o espaçamento entre elementos',
                child: Slider(
                  value: viewModel.spacing,
                  min: 0.8,
                  max: 2.0,
                  divisions: 12,
                  label: '${(viewModel.spacing * 100).round()}%',
                  onChanged: (value) => viewModel.updateSpacing(value),
                ),
              ),
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
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
} 