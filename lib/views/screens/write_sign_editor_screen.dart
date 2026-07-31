import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/signmaker_result.dart';
import '../../models/written_sign_model.dart';
import '../../services/signmaker_bridge_service.dart';
import '../../theme/responsive_content.dart';
import 'signmaker_editor_screen.dart';

const List<String> _editorCategories = [
  'Alfabeto',
  'Números',
  'Cumprimentos',
  'Família',
  'Tempo',
  'Alimentos',
  'Cores',
  'Animais',
  'Verbos',
  'Outros',
];

class WriteSignEditorScreen extends StatefulWidget {
  final WrittenSignModel? initialSign;

  const WriteSignEditorScreen({
    super.key,
    this.initialSign,
  });

  @override
  State<WriteSignEditorScreen> createState() => _WriteSignEditorScreenState();
}

class _WriteSignEditorScreenState extends State<WriteSignEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bridge = SignMakerBridgeService();

  late final TextEditingController _titleController;
  late final TextEditingController _glossController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tagsController;
  late String _selectedCategory;

  String _fsw = '';
  String _swu = '';
  String? _previewPngBase64;

  bool get _isEditing => widget.initialSign != null;

  @override
  void initState() {
    super.initState();
    final sign = widget.initialSign;
    _titleController = TextEditingController(text: sign?.title ?? '');
    _glossController = TextEditingController(text: sign?.glossPt ?? '');
    _descriptionController =
        TextEditingController(text: sign?.description ?? '');
    _tagsController = TextEditingController(text: sign?.tags.join(', ') ?? '');
    _selectedCategory = sign?.category ?? _editorCategories.last;

    final initialFsw = sign?.fsw ?? '';
    if (_bridge.isValidFsw(initialFsw)) {
      _fsw = initialFsw;
      _swu = sign?.swu ?? '';
      _previewPngBase64 = sign?.previewPngBase64;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _glossController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _openSignMaker() async {
    final result = await openSignMakerEditor(
      context,
      initialFsw: _bridge.isValidFsw(_fsw) ? _fsw : null,
      initialSwu: _swu.isNotEmpty ? _swu : null,
    );
    if (!mounted || result == null) return;

    setState(() {
      _fsw = result.fsw;
      _swu = result.swu;
      _previewPngBase64 = result.previewPngBase64;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (!_bridge.isValidFsw(_fsw)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Abra o editor SignWriting e monte um sinal válido antes de salvar.',
          ),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final existing = widget.initialSign;
    final result = WrittenSignModel(
      // Create: id vazio — o banco gera UUID. Edit: preserva UUID existente.
      id: existing?.id ?? '',
      userId: existing?.userId ?? '',
      title: _titleController.text.trim(),
      glossPt: _glossController.text.trim(),
      description: _emptyToNull(_descriptionController.text),
      category: _selectedCategory,
      tags: _parseTags(_tagsController.text),
      fsw: _fsw,
      swu: _swu,
      layoutJson: existing?.layoutJson ?? '[]',
      previewPngBase64: _previewPngBase64,
      status: existing?.status ?? WrittenSignModel.statusDraft,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      publishedAt: existing?.publishedAt,
    );

    Navigator.of(context).pop(result);
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  List<String> _parseTags(String raw) {
    return raw
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final hasSign = _bridge.isValidFsw(_fsw);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? context.l10n.editorEditSign
              : context.l10n.editorNewSign,
        ),
      ),
      body: ResponsiveContent(
        maxWidth: 720,
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPreviewCard(context, hasSign),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do sinal',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o nome do sinal.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _glossController,
                  decoration: const InputDecoration(
                    labelText: 'Gloss em português',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o gloss em português.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: context.l10n.editorCategoryLabel,
                    border: const OutlineInputBorder(),
                  ),
                  items: _editorCategories
                      .map(
                        (category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedCategory = value);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tagsController,
                  decoration: InputDecoration(
                    labelText: 'Tags',
                    hintText: context.l10n.editorTagsHint,
                    border: const OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                Text(
                  'Escrita SignWriting',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Use o SignMaker oficial (Sutton SignWriting) para montar o sinal. '
                  'O aplicativo guarda FSW como fonte principal.',
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _openSignMaker,
                    icon: Icon(hasSign ? Icons.edit : Icons.open_in_new),
                    label: Text(
                      hasSign
                          ? 'Editar sinal no SignMaker'
                          : 'Abrir editor SignWriting',
                    ),
                  ),
                ),
                if (hasSign) ...[
                  const SizedBox(height: 8),
                  SelectableText(
                    'FSW: $_fsw',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(context.l10n.editorSaveSign),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context, bool hasSign) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prévia do sinal',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _titleController.text.trim().isEmpty
                ? 'O sinal montado no SignMaker aparecerá abaixo.'
                : _titleController.text.trim(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildPreviewContent(hasSign),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewContent(bool hasSign) {
    if (!hasSign) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Nenhum sinal SignWriting definido ainda.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    final Uint8List? pngBytes =
        SignMakerResult.decodePngBase64(_previewPngBase64);
    if (pngBytes != null && pngBytes.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Image.memory(
          pngBytes,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => _previewUnavailable(),
        ),
      );
    }

    return _previewUnavailable();
  }

  Widget _previewUnavailable() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sign_language, size: 48, color: Colors.grey.shade500),
            const SizedBox(height: 8),
            Text(
              'Sinal definido (FSW).\nPrévia indisponível neste dispositivo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
