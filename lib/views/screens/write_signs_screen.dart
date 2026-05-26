import 'dart:convert';

import 'package:flutter/material.dart';
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
                      'Crie sinais autorais, salve rascunhos locais e acompanhe o que já está publicado.',
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
            label: 'Rascunhos',
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
        _buildStatusChip(viewModel, WrittenSignModel.statusDraft, 'Rascunhos'),
        _buildStatusChip(
          viewModel,
          WrittenSignModel.statusPublished,
          'Publicados',
        ),
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
              'Use o botão "Novo sinal" para criar seu primeiro rascunho.',
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
                  label: sign.isPublished ? 'Publicado' : 'Rascunho',
                  color: sign.isPublished ? Colors.green : Colors.orange,
                ),
              ],
            ),
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
            if (sign.fsw.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  sign.fsw,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
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
                if (!sign.isPublished)
                  ElevatedButton.icon(
                    onPressed: () => _publishSign(sign),
                    icon: const Icon(Icons.publish),
                    label: const Text('Publicar'),
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
          success
              ? (result.isPublished
                  ? 'Sinal publicado com sucesso.'
                  : 'Rascunho salvo com sucesso.')
              : _viewModel.statusMessage,
        ),
      ),
    );
  }

  Future<void> _publishSign(WrittenSignModel sign) async {
    final success = await _viewModel.publishSign(sign);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Sinal publicado com sucesso.' : _viewModel.statusMessage,
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
