import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/create_text_viewmodel.dart';
import '../../models/sign_model.dart';
import '../widgets/sign_sequence_widget.dart';
import 'text_detail_screen.dart';
import '../../theme/app_spacing.dart';

/// Tela para criar textos em sinais
class CreateTextScreen extends StatefulWidget {
  const CreateTextScreen({super.key});

  @override
  State<CreateTextScreen> createState() => _CreateTextScreenState();
}

class _CreateTextScreenState extends State<CreateTextScreen> {
  final TextEditingController _titleController = TextEditingController();
  late CreateTextViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CreateTextViewModel();
    _viewModel.loadAvailableSigns();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Criar Texto'),
        ),
        body: SafeArea(
          child: Padding(
            padding: AppSpacing.all(context, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: AppSpacing.value(context, 16)),
                Text(
                  'Composição',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: AppSpacing.value(context, 8)),
                Consumer<CreateTextViewModel>(
                  builder: (context, viewModel, _) {
                    final selected = _mapSelectedSigns(viewModel);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SignSequenceWidget(signs: selected),
                        SizedBox(height: AppSpacing.value(context, 8)),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: List.generate(
                            viewModel.selectedSignIds.length,
                            (index) => InputChip(
                              label: Text('Sinal ${index + 1}'),
                              onDeleted: () => viewModel.removeSignAt(index),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: AppSpacing.value(context, 16)),
                Row(
                  children: [
                    Expanded(
                      child: Consumer<CreateTextViewModel>(
                        builder: (context, viewModel, _) {
                          return ElevatedButton.icon(
                            onPressed: viewModel.isLoading ? null : _saveDocument,
                            icon: const Icon(Icons.save),
                            label: const Text('Salvar'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.value(context, 16)),
                Text(
                  'Adicionar sinais',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: AppSpacing.value(context, 8)),
                Expanded(
                  child: Consumer<CreateTextViewModel>(
                    builder: (context, viewModel, _) {
                      if (viewModel.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (viewModel.errorMessage != null) {
                        return Center(
                          child: Text(
                            viewModel.errorMessage!,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        );
                      }
                      if (viewModel.availableSigns.isEmpty) {
                        return const Center(child: Text('Nenhum sinal disponível'));
                      }
                      return ListView.builder(
                        itemCount: viewModel.availableSigns.length,
                        itemBuilder: (context, index) {
                          final sign = viewModel.availableSigns[index];
                          return _buildSignListItem(sign, viewModel);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<SignModel> _mapSelectedSigns(CreateTextViewModel viewModel) {
    final map = {for (final sign in viewModel.availableSigns) sign.id: sign};
    return viewModel.selectedSignIds.map((id) => map[id]).whereType<SignModel>().toList();
  }

  Widget _buildSignListItem(SignModel sign, CreateTextViewModel viewModel) {
    return Card(
      child: ListTile(
        leading: Image.asset(
          sign.signImagePath,
          width: 40,
          height: 40,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.sign_language),
        ),
        title: Text(sign.name),
        subtitle: Text(sign.category),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => viewModel.addSign(sign),
        ),
      ),
    );
  }

  Future<void> _saveDocument() async {
    final id = await _viewModel.saveDocument(_titleController.text);
    if (!mounted) return;

    if (id == null) {
      final error = _viewModel.errorMessage ?? 'Erro ao salvar';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Texto salvo com sucesso')),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TextDetailScreen(documentId: id),
      ),
    );
  }
}
