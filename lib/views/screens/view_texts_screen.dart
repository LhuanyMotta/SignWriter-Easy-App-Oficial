import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/texts_viewmodel.dart';
import '../widgets/sign_sequence_widget.dart';
import 'text_detail_screen.dart';
import '../../theme/app_spacing.dart';

/// Tela para listar textos salvos
class ViewTextsScreen extends StatefulWidget {
  const ViewTextsScreen({super.key});

  @override
  State<ViewTextsScreen> createState() => _ViewTextsScreenState();
}

class _ViewTextsScreenState extends State<ViewTextsScreen> {
  late TextsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TextsViewModel();
    _viewModel.loadDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meus Textos'),
        ),
        body: SafeArea(
          child: Consumer<TextsViewModel>(
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
              if (viewModel.documents.isEmpty) {
                return const Center(child: Text('Nenhum texto encontrado'));
              }
              return ListView.builder(
                padding: AppSpacing.all(context, 16),
                itemCount: viewModel.documents.length,
                itemBuilder: (context, index) {
                  final doc = viewModel.documents[index];
                  final preview = viewModel.previews[doc.id] ?? [];
                  return Card(
                    child: ListTile(
                      title: Text(doc.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: AppSpacing.value(context, 8)),
                          SignSequenceWidget(signs: preview, height: 90),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TextDetailScreen(documentId: doc.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
