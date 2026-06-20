import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import 'package:provider/provider.dart';

import '../../models/sign_model.dart';
import '../../models/translation_model.dart';
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
  final TextEditingController _confirmController = TextEditingController();

  late TabController _tabController;
  late TranslateViewModel _viewModel;

  static const _primary = Color(0xFF2D78BB);
  static const _secondary = Color(0xFF4EB1F0);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get backgroundColor =>
      isDark ? const Color(0xFF08111F) : const Color(0xFFF5F7FB);

  Color get cardColor => isDark ? const Color(0xFF121C2B) : Colors.white;

  Color get inputColor =>
      isDark ? const Color(0xFF1A2636) : Colors.grey.shade100;

  Color get textColor => isDark ? Colors.white : const Color(0xFF1E1E1E);

  Color get subtitleColor => isDark ? Colors.white70 : Colors.black54;

  Color get borderColor => isDark ? Colors.white12 : Colors.grey.shade300;

  @override
  void initState() {
    super.initState();

    _viewModel = TranslateViewModel();
    _viewModel.loadRecentTranslations();

    _tabController = TabController(length: 2, vsync: this);

    _textController.addListener(() => setState(() {}));
    _confirmController.addListener(() => setState(() {}));

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _textController.clear();
        _confirmController.clear();
        _viewModel.clear();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _confirmController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    FocusScope.of(context).unfocus();
    await _viewModel.translate(_textController.text);
  }

  Future<void> _toggleListening() async {
    if (_viewModel.isListening) {
      await _viewModel.stopListening();
      return;
    }

    await _viewModel.startListening(
      onResult: (text) {
        _textController.text = text;
        _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length),
        );
      },
    );
  }

  Future<void> _confirmSign() async {
    FocusScope.of(context).unfocus();
    await _viewModel.confirmRecognizedSign(_confirmController.text);
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
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: context.l10n.tabTextToLibras),
              Tab(text: context.l10n.tabLibrasToText),
            ],
          ),
        ),
        body: Consumer<TranslateViewModel>(
          builder: (context, viewModel, child) {
            return TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildTextToLibrasTab(viewModel),
                _buildLibrasToTextTab(viewModel),
              ],
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ABA TEXTO → LIBRAS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTextToLibrasTab(TranslateViewModel viewModel) {
    return Padding(
      padding: AppSpacing.all(context, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.typeText,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.value(context, 8)),
          _buildTextInputBox(),
          if (viewModel.isListening) ...[
            SizedBox(height: AppSpacing.value(context, 8)),
            _buildListeningIndicator(),
          ],
          SizedBox(height: AppSpacing.value(context, 16)),
          _buildTranslateButton(viewModel),
          if (viewModel.errorMessage != null) ...[
            SizedBox(height: AppSpacing.value(context, 12)),
            _buildErrorBanner(viewModel.errorMessage!),
          ],
          SizedBox(height: AppSpacing.value(context, 24)),
          Text(
            context.l10n.resultTitle,
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
  }

  Widget _buildTextInputBox() {
    return Container(
      decoration: BoxDecoration(
        color: inputColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          TextField(
            controller: _textController,
            maxLines: 4,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: context.l10n.inputHintTextToLibras,
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
                if (_textController.text.isNotEmpty)
                  IconButton(
                    tooltip: 'Limpar',
                    icon: const Icon(Icons.clear_rounded),
                    color: subtitleColor,
                    onPressed: () => _textController.clear(),
                  ),
                AnimatedBuilder(
                  animation: const AlwaysStoppedAnimation(0),
                  builder: (context, _) {
                    final listening = _viewModel.isListening;
                    return IconButton(
                      tooltip: listening ? 'Parar gravação' : 'Ditar por voz',
                      icon: Icon(listening ? Icons.mic_rounded : Icons.mic_none_rounded),
                      color: listening ? Colors.red : _primary,
                      onPressed: _toggleListening,
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
    final canTranslate = _textController.text.trim().isNotEmpty;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: canTranslate && !viewModel.isTranslating ? _translate : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: isDark ? Colors.white12 : Colors.grey.shade300,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: viewModel.isTranslating
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                context.l10n.translateToLibras,
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
        border: Border.all(color: borderColor),
      ),
      child: _buildResultContent(viewModel),
    );
  }

  Widget _buildResultContent(TranslateViewModel viewModel) {
    if (viewModel.lastTranslation == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.translate_rounded, color: subtitleColor, size: 48),
            SizedBox(height: AppSpacing.value(context, 12)),
            Text(
              context.l10n.librasTranslationPlaceholder,
              textAlign: TextAlign.center,
              style: TextStyle(color: subtitleColor, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (viewModel.signs.isEmpty) {
      return Center(
        child: Text(
          context.l10n.translateNoSignFound,
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
          Container(
            padding: AppSpacing.symmetric(context, horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.orange.shade700, size: 16),
                SizedBox(width: AppSpacing.value(context, 8)),
                Expanded(
                  child: Text(
                    'Não encontrados: ${viewModel.notFoundWords.join(', ')}',
                    style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
                  ),
                ),
              ],
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
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
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
                  return Icon(Icons.sign_language, color: subtitleColor, size: 42);
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
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
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
            child: GestureDetector(
              onLongPress: () => _showHistoryActions(translation),
              child: ActionChip(
                avatar: translation.isFavorite
                    ? const Icon(Icons.star_rounded, size: 16, color: Colors.amber)
                    : null,
                label: Text(text),
                onPressed: () {
                  _textController.text = translation.sourceText;
                  _translate();
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showHistoryActions(TranslationModel translation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  translation.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: Colors.amber,
                ),
                title: Text(
                  translation.isFavorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
                  style: TextStyle(color: textColor),
                ),
                onTap: () {
                  _viewModel.toggleFavorite(translation);
                  Navigator.pop(sheetContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                title: const Text('Excluir do histórico', style: TextStyle(color: Colors.red)),
                onTap: () {
                  _viewModel.deleteTranslation(translation);
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListeningIndicator() {
    return Container(
      padding: AppSpacing.symmetric(context, horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(Colors.red.shade400),
            ),
          ),
          SizedBox(width: AppSpacing.value(context, 10)),
          Text(
            'Ouvindo... fale agora',
            style: TextStyle(color: Colors.red.shade400, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => _viewModel.stopListening(),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Text('Parar', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: AppSpacing.symmetric(context, horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 18),
          SizedBox(width: AppSpacing.value(context, 8)),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ABA LIBRAS → TEXTO
  // ═══════════════════════════════════════════════════════════════
  Widget _buildLibrasToTextTab(TranslateViewModel viewModel) {
    return SingleChildScrollView(
      padding: AppSpacing.all(context, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Capture ou envie uma imagem do sinal',
            style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: AppSpacing.value(context, 8)),
          Text(
            'Tire uma foto do sinal feito em SignWriting ou em Libras. Depois, confirme o nome do sinal para localizá-lo no dicionário.',
            style: TextStyle(color: subtitleColor, fontSize: 13, height: 1.5),
          ),
          SizedBox(height: AppSpacing.value(context, 16)),
          _buildImageCaptureBox(viewModel),
          SizedBox(height: AppSpacing.value(context, 16)),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: viewModel.pickImageFromCamera,
                  icon: const Icon(Icons.camera_alt_rounded, size: 18),
                  label: const Text('Câmera'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primary,
                    side: BorderSide(color: _primary.withValues(alpha: 0.4)),
                    padding: AppSpacing.symmetric(context, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.value(context, 10)),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: viewModel.pickImageFromGallery,
                  icon: const Icon(Icons.photo_library_rounded, size: 18),
                  label: const Text('Galeria'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primary,
                    side: BorderSide(color: _primary.withValues(alpha: 0.4)),
                    padding: AppSpacing.symmetric(context, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          if (viewModel.capturedImage != null) ...[
            SizedBox(height: AppSpacing.value(context, 24)),
            Text(
              'Confirme o nome do sinal',
              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: AppSpacing.value(context, 8)),
            Text(
              'O reconhecimento automático de imagem ainda está em desenvolvimento. Digite o nome do sinal para localizá-lo no dicionário.',
              style: TextStyle(color: subtitleColor, fontSize: 12, height: 1.5),
            ),
            SizedBox(height: AppSpacing.value(context, 10)),
            _buildConfirmInputBox(viewModel),
            SizedBox(height: AppSpacing.value(context, 16)),
            _buildConfirmButton(viewModel),
          ],
          if (viewModel.errorMessage != null) ...[
            SizedBox(height: AppSpacing.value(context, 12)),
            _buildErrorBanner(viewModel.errorMessage!),
          ],
          if (viewModel.signs.isNotEmpty && viewModel.recognizedText != null) ...[
            SizedBox(height: AppSpacing.value(context, 24)),
            Text(
              context.l10n.resultTitle,
              style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.value(context, 12)),
            _buildRecognizedSignCard(viewModel),
          ],
        ],
      ),
    );
  }

  Widget _buildImageCaptureBox(TranslateViewModel viewModel) {
    return Container(
      width: double.infinity,
      height: AppSpacing.value(context, 220),
      decoration: BoxDecoration(
        color: inputColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: viewModel.capturedImage == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image_outlined, color: subtitleColor, size: 48),
                  SizedBox(height: AppSpacing.value(context, 10)),
                  Text(
                    'Nenhuma imagem selecionada',
                    style: TextStyle(color: subtitleColor, fontSize: 14),
                  ),
                ],
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                Image.file(viewModel.capturedImage!, fit: BoxFit.cover),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                      onPressed: () {
                        viewModel.clearCapturedImage();
                        _confirmController.clear();
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildConfirmInputBox(TranslateViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: inputColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: TextField(
        controller: _confirmController,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: 'Ex.: Olá, Obrigado, Família...',
          hintStyle: TextStyle(color: subtitleColor),
          contentPadding: AppSpacing.all(context, 16),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search_rounded, color: subtitleColor),
        ),
        onSubmitted: (_) => _confirmSign(),
      ),
    );
  }

  Widget _buildConfirmButton(TranslateViewModel viewModel) {
    final canConfirm = _confirmController.text.trim().isNotEmpty;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: canConfirm && !viewModel.isTranslating ? _confirmSign : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: isDark ? Colors.white12 : Colors.grey.shade300,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: viewModel.isTranslating
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : const Text('Buscar no dicionário', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildRecognizedSignCard(TranslateViewModel viewModel) {
    final sign = viewModel.signs.first;
    return Container(
      width: double.infinity,
      padding: AppSpacing.all(context, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primary, _secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: AppSpacing.value(context, 64),
            height: AppSpacing.value(context, 64),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              sign.signImagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.sign_language, color: _primary, size: 32);
              },
            ),
          ),
          SizedBox(width: AppSpacing.value(context, 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sign.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (sign.description != null) ...[
                  SizedBox(height: AppSpacing.value(context, 4)),
                  Text(
                    sign.description!,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
