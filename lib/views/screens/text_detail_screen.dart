import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/texts_viewmodel.dart';
import '../../models/text_document_model.dart';
import '../widgets/sign_sequence_widget.dart';
import '../../theme/app_spacing.dart';

/// Tela de detalhes de um texto
class TextDetailScreen extends StatefulWidget {
  final String documentId;

  const TextDetailScreen({super.key, required this.documentId});

  @override
  State<TextDetailScreen> createState() => _TextDetailScreenState();
}

class _TextDetailScreenState extends State<TextDetailScreen> {
  late TextsViewModel _viewModel;
  TextDocumentModel? _document;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _viewModel = TextsViewModel();
    _load();
  }

  Future<void> _load() async {
    final doc = await _viewModel.loadDocumentById(widget.documentId);
    setState(() {
      _document = doc;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_document?.title ?? 'Texto'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _document == null ? null : () => _confirmDelete(context),
            ),
          ],
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _document == null
                  ? const Center(child: Text('Texto não encontrado'))
                  : FutureBuilder(
                      future: _viewModel.loadSignsForDocument(_document!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final signs = snapshot.data ?? [];
                        return Padding(
                          padding: AppSpacing.all(context, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _document!.title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              SizedBox(height: AppSpacing.value(context, 16)),
                              SignSequenceWidget(signs: signs, height: 130),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir texto'),
        content: const Text('Deseja excluir este texto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (_document == null) return;
              await _viewModel.deleteDocument(_document!.id);
              if (!mounted) return;
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
