import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/translate_viewmodel.dart';
import '../../models/sign_model.dart';

/// Tela para traduzir texto para a Linguagem Brasileira de Sinais (Libras)
/// usando o sistema de escrita SignWriting
class TranslateSignsScreen extends StatefulWidget {
  const TranslateSignsScreen({super.key});

  @override
  State<TranslateSignsScreen> createState() => _TranslateSignsScreenState();
}

class _TranslateSignsScreenState extends State<TranslateSignsScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  
  // Controlador para as abas
  late TabController _tabController;
  late TranslateViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Inicializar o controlador de abas
    _tabController = TabController(length: 2, vsync: this);
    _viewModel = TranslateViewModel();
    _viewModel.loadRecentTranslations();
    _textController.addListener(_onTextChanged);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          // Limpa o resultado quando muda de aba
          _textController.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  Future<void> _translate() async {
    await _viewModel.translate(_textController.text);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Traduzir Sinais'),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Texto → Libras'),
              Tab(text: 'Libras → Texto'),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _tabController.index == 0 ? 'Digite o texto' : 'Grave ou desenhe o sinal',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _textController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: _tabController.index == 0
                            ? 'Digite o texto para traduzir para Libras'
                            : 'Este recurso será implementado em breve',
                        contentPadding: const EdgeInsets.all(16),
                        border: InputBorder.none,
                      ),
                      enabled: _tabController.index == 0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.mic),
                            onPressed: _tabController.index == 0
                                ? () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Reconhecimento de voz em breve')),
                                    );
                                  }
                                : null,
                            color: _tabController.index == 0
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                          ),
                          if (_tabController.index == 1)
                            IconButton(
                              icon: const Icon(Icons.camera_alt),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Captura de sinais em breve')),
                                );
                              },
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Consumer<TranslateViewModel>(
                  builder: (context, viewModel, _) {
                    return ElevatedButton(
                      onPressed: _tabController.index == 0 && _textController.text.trim().isNotEmpty
                          ? _translate
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: viewModel.isTranslating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(_tabController.index == 0 ? 'Traduzir para Libras' : 'Traduzir para Texto'),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Resultado',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Consumer<TranslateViewModel>(
                    builder: (context, viewModel, _) {
                      if (viewModel.errorMessage != null) {
                        return Center(
                          child: Text(
                            viewModel.errorMessage!,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        );
                      }

                      if (_tabController.index == 1) {
                        return Center(
                          child: Text(
                            'A tradução para texto aparecerá aqui',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        );
                      }

                      if (viewModel.signs.isEmpty && viewModel.notFoundWords.isEmpty) {
                        return Center(
                          child: Text(
                            'A tradução para Libras aparecerá aqui',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (viewModel.signs.isEmpty && viewModel.notFoundWords.isNotEmpty) ...[
                            Text(
                              'Este sinal ainda não existe.',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (viewModel.signWritingSequence != null) ...[
                            Text(
                              'Sequência SignWriting',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              viewModel.signWritingSequence!,
                              style: const TextStyle(fontStyle: FontStyle.italic),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (viewModel.signs.isNotEmpty) ...[
                            Text(
                              'Sinais encontrados',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 110,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: viewModel.signs.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  return _buildSignMiniCard(viewModel.signs[index]);
                                },
                              ),
                            ),
                          ],
                          if (viewModel.notFoundWords.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Palavras não encontradas',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: viewModel.notFoundWords
                                  .map((word) => Chip(label: Text(word)))
                                  .toList(),
                            ),
                          ],
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.save_alt),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Tradução salva no histórico')),
                                  );
                                },
                                tooltip: 'Salvar',
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Consumer<TranslateViewModel>(
                builder: (context, viewModel, _) {
                  if (viewModel.recentTranslations.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Traduções Recentes',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: viewModel.recentTranslations.length,
                          itemBuilder: (context, index) {
                            final item = viewModel.recentTranslations[index];
                            final label = item.sourceText.length > 15
                                ? '${item.sourceText.substring(0, 15)}...'
                                : item.sourceText;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ActionChip(
                                label: Text(label),
                                onPressed: () {
                                  _textController.text = item.sourceText;
                                  _translate();
                                },
                                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignMiniCard(SignModel sign) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Expanded(
            child: Image.asset(
              sign.signImagePath,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.sign_language,
                  color: Colors.grey.shade400,
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sign.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
} 