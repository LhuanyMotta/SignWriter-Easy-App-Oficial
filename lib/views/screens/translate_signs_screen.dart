import 'package:flutter/material.dart';

/// Tela para traduzir texto para a Linguagem Brasileira de Sinais (Libras)
/// usando o sistema de escrita SignWriting
class TranslateSignsScreen extends StatefulWidget {
  const TranslateSignsScreen({super.key});

  @override
  State<TranslateSignsScreen> createState() => _TranslateSignsScreenState();
}

class _TranslateSignsScreenState extends State<TranslateSignsScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  String _translatedText = '';
  bool _isTranslating = false;
  
  // Controlador para as abas
  late TabController _tabController;
  
  // Lista de traduções recentes (seria persistida)
  final List<String> _recentTranslations = [];

  @override
  void initState() {
    super.initState();
    // Inicializar o controlador de abas
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          // Limpa o resultado quando muda de aba
          _translatedText = '';
          _textController.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Simula o processo de tradução
  Future<void> _translate() async {
    if (_textController.text.isEmpty) return;
    
    setState(() {
      _isTranslating = true;
    });

    // Simulação do tempo de processamento da tradução
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Em uma implementação real, isso chamaria uma API de tradução
    setState(() {
      _translatedText = _textController.text;
      _isTranslating = false;
      
      // Adiciona à lista de traduções recentes
      if (!_recentTranslations.contains(_translatedText)) {
        _recentTranslations.insert(0, _translatedText);
        // Limita a 5 traduções recentes
        if (_recentTranslations.length > 5) {
          _recentTranslations.removeLast();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            // Input Section
            Text(
              _tabController.index == 0 ? 'Digite o texto' : 'Grave ou desenhe o sinal',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            
            // Input Field
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
                    enabled: _tabController.index == 0, // Apenas ativa para texto → Libras
                  ),
                  
                  // Botões de ação (gravar, câmera, etc)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Botão de microfone para entrada de voz
                        IconButton(
                          icon: const Icon(Icons.mic),
                          onPressed: _tabController.index == 0 ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Reconhecimento de voz em breve')),
                            );
                          } : null,
                          color: _tabController.index == 0 ? Theme.of(context).colorScheme.primary : Colors.grey,
                        ),
                        // Botão de câmera (apenas para Libras → Texto)
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
            
            // Botão de tradução
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _tabController.index == 0 && _textController.text.isNotEmpty 
                    ? _translate 
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isTranslating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(_tabController.index == 0 ? 'Traduzir para Libras' : 'Traduzir para Texto'),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Resultado da tradução
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
                child: _translatedText.isEmpty
                    ? Center(
                        child: Text(
                          _tabController.index == 0
                              ? 'A tradução para Libras aparecerá aqui'
                              : 'A tradução para texto aparecerá aqui',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Aqui viria a representação visual em SignWriting
                                  if (_tabController.index == 0)
                                    _buildDummySignWriting(),
                                  
                                  // Para demonstração, exibimos o texto
                                  if (_tabController.index == 1)
                                    Text(
                                      _translatedText,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          // Barra de ações para o resultado
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.content_copy),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Texto copiado')),
                                  );
                                },
                                tooltip: 'Copiar',
                              ),
                              IconButton(
                                icon: const Icon(Icons.share),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Compartilhar em breve')),
                                  );
                                },
                                tooltip: 'Compartilhar',
                              ),
                              IconButton(
                                icon: const Icon(Icons.save_alt),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Tradução salva')),
                                  );
                                },
                                tooltip: 'Salvar',
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
            
            // Seção de traduções recentes
            if (_recentTranslations.isNotEmpty) ...[
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
                  itemCount: _recentTranslations.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        label: Text(
                          _recentTranslations[index].length > 15
                              ? '${_recentTranslations[index].substring(0, 15)}...'
                              : _recentTranslations[index],
                        ),
                        onPressed: () {
                          _textController.text = _recentTranslations[index];
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
          ],
        ),
      ),
    );
  }
  
  // Método para criar uma representação visual fictícia de SignWriting
  Widget _buildDummySignWriting() {
    // Esta é apenas uma representação visual para demonstração
    // Em uma implementação real, isso seria gerado a partir da API de tradução
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < _translatedText.length.clamp(1, 4); i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Center(
                    child: Icon(
                      i % 3 == 0 ? Icons.front_hand : 
                      i % 2 == 0 ? Icons.sign_language : Icons.back_hand,
                      color: Theme.of(context).colorScheme.primary,
                      size: 30,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Tradução em SignWriting para: "$_translatedText"',
          style: const TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 