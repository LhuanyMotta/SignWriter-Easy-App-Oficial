import 'dart:convert';

import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import 'package:provider/provider.dart';

import '../../models/written_sign_model.dart';
import '../../viewmodels/write_signs_viewmodel.dart';
import 'write_sign_editor_screen.dart';

class WriteSignsScreen extends StatefulWidget {
  const WriteSignsScreen({super.key});

  @override
  State<WriteSignsScreen> createState() => _WriteSignsScreenState();
}

class _WriteSignsScreenState extends State<WriteSignsScreen> {
  late WriteSignsViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = WriteSignsViewModel();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<WriteSignsViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Escrever Sinais'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: viewModel.isLoading
                      ? null
                      : () {
                          viewModel.loadSigns();
                        },
                ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meus sinais',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crie e salve seus sinais para editar quando quiser.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryRow(viewModel),
                    const SizedBox(height: 16),
                    _buildSearchField(),
                    const SizedBox(height: 12),
                    _buildStatusFilters(viewModel),
                    const SizedBox(height: 12),
                    if (viewModel.statusMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          viewModel.statusMessage,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    Expanded(
                      child: viewModel.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _buildSignsList(viewModel),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _openEditor(),
              icon: const Icon(Icons.add),
              label: const Text('Novo sinal'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(WriteSignsViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Sinais',
            value: viewModel.draftSigns.length.toString(),
            icon: Icons.edit_note,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Publicados',
            value: viewModel.publishedSigns.length.toString(),
            icon: Icons.public,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Buscar por nome, gloss, categoria ou tag',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _searchController.clear,
              ),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildStatusFilters(WriteSignsViewModel viewModel) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildStatusChip(viewModel, 'all', 'Todos'),
        _buildStatusChip(viewModel, WrittenSignModel.statusDraft, 'Sinais'),
      ],
    );
  }

  Widget _buildStatusChip(
    WriteSignsViewModel viewModel,
    String value,
    String label,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: viewModel.selectedStatus == value,
      onSelected: (_) => viewModel.updateStatusFilter(value),
    );
  }

  Widget _buildSignsList(WriteSignsViewModel viewModel) {
    final signs = viewModel.signs;
    if (signs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.gesture_outlined, size: 56),
            const SizedBox(height: 16),
            Text(
              'Nenhum sinal encontrado.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Use o botão "Novo sinal" para criar seu primeiro sinal.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.loadSigns,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: signs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildSignCard(signs[index]),
      ),
    );
  }

  Widget _buildSignCard(WrittenSignModel sign) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sign.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gloss: ${sign.glossPt}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                _StatusBadge(
                  label: 'Sinal',
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SignPreview(layoutJson: sign.layoutJson),
            const SizedBox(height: 12),
            Text('Categoria: ${sign.category}'),
            const SizedBox(height: 4),
            Text('Atualizado em: ${_formatDate(sign.updatedAt)}'),
            const SizedBox(height: 4),
            Text('Símbolos: ${_countSymbols(sign.layoutJson)}'),
            if (sign.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: sign.tags
                    .map((tag) => Chip(label: Text(tag)))
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _openEditor(sign: sign),
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar'),
                ),
                TextButton.icon(
                  onPressed: () => _confirmDelete(sign),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Excluir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onSearchChanged() {
    setState(() {});
    _viewModel.updateSearchQuery(_searchController.text);
  }

  Future<void> _openEditor({WrittenSignModel? sign}) async {
    final result = await Navigator.of(context).push<WrittenSignModel>(
      MaterialPageRoute(
        builder: (_) => WriteSignEditorScreen(initialSign: sign),
      ),
    );

    if (result == null || !mounted) return;

    final success = await _viewModel.saveSign(result);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Sinal salvo com sucesso.' : _viewModel.statusMessage,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(WrittenSignModel sign) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir sinal'),
        content: Text('Deseja remover "${sign.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await _viewModel.deleteSign(sign.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Sinal excluído com sucesso.' : _viewModel.statusMessage,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  int _countSymbols(String layoutJson) {
    try {
      final decoded = json.decode(layoutJson);
      if (decoded is Map<String, dynamic> && decoded['symbols'] is List) {
        return (decoded['symbols'] as List).length;
      }
      if (decoded is List) return decoded.length;
    } catch (_) {
      return 0;
    }
    return 0;
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(label),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SignPreview extends StatelessWidget {
  final String layoutJson;

  const _SignPreview({required this.layoutJson});

  @override
  Widget build(BuildContext context) {
    final symbols = _parseSymbols(layoutJson);
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: symbols.isEmpty
          ? const Center(child: Icon(Icons.gesture_outlined, size: 36))
          : LayoutBuilder(
              builder: (context, constraints) {
                final maxLeft = (constraints.maxWidth - 40).clamp(0.0, double.infinity);
                final maxTop = (constraints.maxHeight - 40).clamp(0.0, double.infinity);
                return Stack(
                  children: symbols.map((symbol) {
                    final left = maxLeft * symbol.x;
                    final top = maxTop * symbol.y;
                    return Positioned(
                      left: left,
                      top: top,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.diagonal3Values(symbol.mirrored ? -1 : 1, 1, 1),
                        child: RotatedBox(
                          quarterTurns: symbol.rotationQuarterTurns,
                          child: Icon(
                            _iconForSymbol(symbol.symbolId),
                            size: 28,
                            color: const Color(0xFF2D78BB),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }

  static List<_PreviewSymbol> _parseSymbols(String rawLayout) {
    try {
      final decoded = json.decode(rawLayout);
      final rawSymbols = decoded is Map<String, dynamic> ? decoded['symbols'] : decoded;
      if (rawSymbols is! List) return const [];
      return rawSymbols.whereType<Map>().map((item) {
        final map = Map<String, dynamic>.from(item);
        return _PreviewSymbol(
          symbolId: (map['symbolId'] ?? '').toString(),
          x: ((map['x'] as num?) ?? 0.5).toDouble().clamp(0.0, 1.0),
          y: ((map['y'] as num?) ?? 0.5).toDouble().clamp(0.0, 1.0),
          rotationQuarterTurns: ((map['rotationQuarterTurns'] as num?) ?? 0).toInt() % 4,
          mirrored: (map['mirrored'] ?? false) == true,
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  static IconData _iconForSymbol(String symbolId) {
    switch (symbolId) {
      case 'hand-open':
        return Icons.back_hand_outlined;
      case 'hand-point':
        return Icons.touch_app_outlined;
      case 'hand-fist':
        return Icons.front_hand_outlined;
      case 'move-up':
        return Icons.arrow_upward;
      case 'move-down':
        return Icons.arrow_downward;
      case 'move-repeat':
        return Icons.sync;
      case 'face-neutral':
        return Icons.sentiment_neutral;
      case 'face-happy':
        return Icons.sentiment_satisfied_alt;
      case 'face-focus':
        return Icons.visibility_outlined;
      case 'body-center':
        return Icons.accessibility_new;
      case 'body-lean':
        return Icons.directions_run;
      case 'body-head':
        return Icons.emoji_people;
      case 'mark-contact':
        return Icons.radio_button_checked;
      case 'mark-line':
        return Icons.horizontal_rule;
      case 'mark-cross':
        return Icons.close;
      default:
        return Icons.help_outline;
    }
  }
}

class _PreviewSymbol {
  final String symbolId;
  final double x;
  final double y;
  final int rotationQuarterTurns;
  final bool mirrored;

  const _PreviewSymbol({
    required this.symbolId,
    required this.x,
    required this.y,
    required this.rotationQuarterTurns,
    required this.mirrored,
  });
}
