import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/sign_model.dart';
import '../../viewmodels/translate_viewmodel.dart';
import '../../theme/app_spacing.dart';

class TranslateSignsScreen extends StatefulWidget {
  const TranslateSignsScreen({super.key});

  @override
  State<TranslateSignsScreen> createState() => _TranslateSignsScreenState();
}

class _TranslateSignsScreenState extends State<TranslateSignsScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();

  late TabController _tabController;
  late TranslateViewModel _viewModel;

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get backgroundColor =>
      isDark ? const Color(0xFF08111F) : const Color(0xFFF5F7FB);

  Color get cardColor =>
      isDark ? const Color(0xFF121C2B) : Colors.white;

  Color get inputColor =>
      isDark ? const Color(0xFF1A2636) : Colors.grey.shade100;

  Color get textColor =>
      isDark ? Colors.white : const Color(0xFF1E1E1E);

  Color get subtitleColor =>
      isDark ? Colors.white70 : Colors.black54;

  @override
  void initState() {
    super.initState();

    _viewModel = TranslateViewModel();
    _viewModel.loadRecentTranslations();

    _tabController = TabController(length: 2, vsync: this);

    _textController.addListener(() => setState(() {}));

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _textController.clear();
        _viewModel.clear();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    FocusScope.of(context).unfocus();
    await _viewModel.translate(_textController.text);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text(
            'Traduzir Sinais',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF2D78BB),
          foregroundColor: Colors.white,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'Texto → Libras'),
              Tab(text: 'Libras → Texto'),
            ],
          ),
        ),
        body: Consumer<TranslateViewModel>(
          builder: (context, viewModel, child) {
            return Padding(
              padding: AppSpacing.all(context, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputTitle(),
                  SizedBox(height: AppSpacing.value(context, 8)),
                  _buildInputBox(viewModel),
                  SizedBox(height: AppSpacing.value(context, 16)),
                  _buildTranslateButton(viewModel),
                  SizedBox(height: AppSpacing.value(context, 24)),
                  Text(
                    'Resultado',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.value(context, 8)),
                  Expanded(child: _buildResultBox(viewModel)),
                  if (viewModel.recentTranslations.isNotEmpty) ...[
                    SizedBox(height: AppSpacing.value(context, 12)),
                    _buildRecentTranslations(viewModel),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputTitle() {
    return Text(
      _tabController.index == 0
          ? 'Digite o texto'
          : 'Capturar Libras para texto',
      style: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildInputBox(TranslateViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: inputColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: _textController,
            maxLines: 4,
            enabled: _tabController.index == 0,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: _tabController.index == 0
                  ? 'Digite o texto para traduzir'
                  : 'Recurso de imagem/câmera será implementado em breve',
              hintStyle: TextStyle(color: subtitleColor),
              contentPadding: AppSpacing.all(context, 16),
              border: InputBorder.none,
            ),
          ),
          Padding(
            padding: AppSpacing.only(context, right: 8, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Áudio',
                  icon: const Icon(Icons.mic),
                  color: const Color(0xFF2D78BB),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reconhecimento por áudio será implementado em breve.'),
                      ),
                    );
                  },
                ),
                if (_tabController.index == 1)
                  IconButton(
                    tooltip: 'Câmera',
                    icon: const Icon(Icons.camera_alt),
                    color: const Color(0xFF2D78BB),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Captura pela câmera será implementada em breve.'),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslateButton(TranslateViewModel viewModel) {
    final canTranslate =
        _tabController.index == 0 && _textController.text.trim().isNotEmpty;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed:
            canTranslate && !viewModel.isTranslating ? _translate : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2D78BB),
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              isDark ? Colors.white12 : Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: viewModel.isTranslating
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                _tabController.index == 0
                    ? 'Traduzir para Libras'
                    : 'Traduzir para Texto',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildResultBox(TranslateViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.all(context, 16),
      decoration: BoxDecoration(
        color: inputColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade300,
        ),
      ),
      child: _buildResultContent(viewModel),
    );
  }

  Widget _buildResultContent(TranslateViewModel viewModel) {
    if (viewModel.errorMessage != null) {
      return Center(
        child: Text(
          viewModel.errorMessage!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_tabController.index == 1) {
      return Center(
        child: Text(
          'A tradução de Libras para texto será implementada em breve.',
          textAlign: TextAlign.center,
          style: TextStyle(color: subtitleColor, fontSize: 16),
        ),
      );
    }

    if (viewModel.lastTranslation == null) {
      return Center(
        child: Text(
          'A tradução para Libras aparecerá aqui.',
          textAlign: TextAlign.center,
          style: TextStyle(color: subtitleColor, fontSize: 16),
        ),
      );
    }

    if (viewModel.signs.isEmpty) {
      return Center(
        child: Text(
          'Nenhum sinal encontrado para esse texto.',
          textAlign: TextAlign.center,
          style: TextStyle(color: subtitleColor, fontSize: 16),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GridView.builder(
            itemCount: viewModel.signs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.78,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              return _buildSignResultCard(viewModel.signs[index]);
            },
          ),
        ),
        if (viewModel.notFoundWords.isNotEmpty) ...[
          SizedBox(height: AppSpacing.value(context, 10)),
          Text(
            'Não encontrados: ${viewModel.notFoundWords.join(', ')}',
            style: TextStyle(
              color: subtitleColor,
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSignResultCard(SignModel sign) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: AppSpacing.all(context, 8),
              child: Image.network(
                sign.signImagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.sign_language,
                    color: subtitleColor,
                    size: 42,
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
            child: Text(
              sign.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTranslations(TranslateViewModel viewModel) {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.recentTranslations.length,
        itemBuilder: (context, index) {
          final translation = viewModel.recentTranslations[index];
          final text = translation.sourceText.length > 18
              ? '${translation.sourceText.substring(0, 18)}...'
              : translation.sourceText;

          return Padding(
            padding: AppSpacing.only(context, right: 8),
            child: ActionChip(
              label: Text(text),
              onPressed: () {
                _textController.text = translation.sourceText;
                _translate();
              },
            ),
          );
        },
      ),
    );
  }
}
