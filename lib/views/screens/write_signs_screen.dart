import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/written_sign_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/responsive_content.dart';
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
            body: ResponsiveContent(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchField(),
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
            _SignPreview(
              fsw: sign.fsw,
              previewPngBytes: sign.previewPngBytes,
            ),
            const SizedBox(height: 12),
            Text('Categoria: ${sign.category}'),
            const SizedBox(height: 4),
            Text('Atualizado em: ${_formatDate(sign.updatedAt)}'),
            if (sign.hasSignWriting) ...[
              const SizedBox(height: 4),
              Text(
                'FSW definido',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
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
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
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

  bool _ensureAuthenticated() {
    if (_viewModel.isAuthenticated) return true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Faça login para gerenciar seus sinais.'),
        action: SnackBarAction(
          label: 'Entrar',
          onPressed: () {
            Navigator.of(context).pushNamed(AppRoutes.auth);
          },
        ),
      ),
    );
    return false;
  }

  Future<void> _openEditor({WrittenSignModel? sign}) async {
    if (!_ensureAuthenticated()) return;

    final isCreate = sign == null;
    final result = await Navigator.of(context).push<WrittenSignModel>(
      MaterialPageRoute(
        builder: (_) => WriteSignEditorScreen(initialSign: sign),
      ),
    );

    if (result == null || !mounted) return;

    final success = await _viewModel.saveSign(result, isCreate: isCreate);
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
    if (!_ensureAuthenticated()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DeleteSignConfirmDialog(signTitle: sign.title),
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
}

class _DeleteSignConfirmDialog extends StatefulWidget {
  final String signTitle;

  const _DeleteSignConfirmDialog({required this.signTitle});

  @override
  State<_DeleteSignConfirmDialog> createState() =>
      _DeleteSignConfirmDialogState();
}

class _DeleteSignConfirmDialogState extends State<_DeleteSignConfirmDialog> {
  static const int _seconds = 10;
  int _remaining = _seconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remaining <= 1) {
        timer.cancel();
        setState(() => _remaining = 0);
        return;
      }
      setState(() => _remaining -= 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    final canConfirm = _remaining <= 0;

    return AlertDialog(
      title: Text(
        'Excluir sinal',
        style: TextStyle(color: error, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Deseja remover "${widget.signTitle}"?'),
          const SizedBox(height: 12),
          Text(
            'Esta ação é permanente e não tem volta.',
            style: TextStyle(
              color: error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              canConfirm
                  ? 'Pode confirmar a exclusão.'
                  : 'Aguarde $_remaining s para confirmar...',
              style: TextStyle(
                color: error,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: canConfirm ? () => Navigator.of(context).pop(true) : null,
          style: FilledButton.styleFrom(
            backgroundColor: error,
            foregroundColor: Theme.of(context).colorScheme.onError,
            disabledBackgroundColor: error.withValues(alpha: 0.35),
            disabledForegroundColor:
                Theme.of(context).colorScheme.onError.withValues(alpha: 0.7),
          ),
          child: Text(canConfirm ? 'Excluir' : 'Excluir ($_remaining)'),
        ),
      ],
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
  final String fsw;
  final Uint8List? previewPngBytes;

  const _SignPreview({
    required this.fsw,
    this.previewPngBytes,
  });

  @override
  Widget build(BuildContext context) {
    final hasFsw = fsw.trim().isNotEmpty && !fsw.startsWith('SW-MVP:');
    final png = previewPngBytes;

    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: !hasFsw
          ? Center(
              child: Icon(
                Icons.sign_language_outlined,
                size: 36,
                color: Colors.grey.shade400,
              ),
            )
          : (png != null && png.isNotEmpty)
              ? Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.memory(
                    png,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        'FSW',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    'FSW',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
    );
  }
}
