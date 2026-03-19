import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/sign_detail_viewmodel.dart';

/// Tela de detalhes do sinal
class SignDetailScreen extends StatefulWidget {
  final String signId;

  const SignDetailScreen({super.key, required this.signId});

  @override
  State<SignDetailScreen> createState() => _SignDetailScreenState();
}

class _SignDetailScreenState extends State<SignDetailScreen> {
  late final SignDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SignDetailViewModel();
    _viewModel.loadSign(widget.signId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: Consumer<SignDetailViewModel>(
            builder: (context, viewModel, _) {
              return Text(viewModel.sign?.name ?? 'Detalhes');
            },
          ),
          actions: [
            Consumer<SignDetailViewModel>(
              builder: (context, viewModel, _) {
                final sign = viewModel.sign;
                if (sign == null) return const SizedBox.shrink();
                return IconButton(
                  icon: Icon(
                    sign.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: sign.isFavorite ? Colors.red : Colors.white,
                  ),
                  tooltip: 'Favoritar',
                  onPressed: viewModel.toggleFavorite,
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Consumer<SignDetailViewModel>(
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

              final sign = viewModel.sign;
              if (sign == null) {
                return const Center(child: Text('Sinal não encontrado'));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagem do sinal
                    Container(
                      width: double.infinity,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          sign.signImagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.sign_language,
                              size: 72,
                              color: Colors.grey.shade400,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      sign.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (sign.description != null && sign.description!.isNotEmpty)
                      Text(
                        sign.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(
                          label: Text(sign.category),
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (sign.tags.isNotEmpty)
                          ...sign.tags.map(
                            (tag) => Chip(
                              label: Text(tag),
                              backgroundColor: Colors.grey.shade100,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.text_snippet),
                        label: const Text('Usar em texto (em breve)'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
