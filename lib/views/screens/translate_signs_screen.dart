import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/translate_viewmodel.dart';
import '../../models/sign_model.dart';
import '../../l10n/l10n.dart';
import '../../theme/app_theme.dart';

/// Tela para traduzir texto para a Linguagem Brasileira de Sinais (Libras)
/// usando o sistema de escrita SignWriting
class TranslateSignsScreen extends StatefulWidget {
  const TranslateSignsScreen({super.key});

  @override
  State<TranslateSignsScreen> createState() => _TranslateSignsScreenState();
}

class _TranslateSignsScreenState extends State<TranslateSignsScreen> {
  final TextEditingController _textController = TextEditingController();
  late TranslateViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TranslateViewModel();
    _viewModel.loadRecentTranslations();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_textController.text.trim().isEmpty) {
      _viewModel.clearResults();
    }
  }

  Future<void> _translate() async {
    await _viewModel.translate(_textController.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final tokens = theme.extension<AppThemeTokens>();
    final spacing = tokens?.spacingScale ?? 1.0;
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.translateSignsTitle),
        ),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(16.0 * spacing),
            children: [
              Text(
                l10n.typeText,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8 * spacing),
              Container(
                decoration: BoxDecoration(
                  color: tokens?.surfaceMuted ??
                      theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: tokens?.border ?? theme.colorScheme.outlineVariant,
                  ),
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: 3,
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: l10n.inputHintTextToLibras,
                    contentPadding: const EdgeInsets.all(16),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 16 * spacing),
              SizedBox(
                width: double.infinity,
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _textController,
                  builder: (context, value, _) {
                    return Consumer<TranslateViewModel>(
                      builder: (context, viewModel, _) {
                        return ElevatedButton(
                          onPressed:
                              value.text.trim().isNotEmpty ? _translate : null,
                          style: ElevatedButton.styleFrom(
                            padding:
                                EdgeInsets.symmetric(vertical: 14 * spacing),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: viewModel.isTranslating
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: theme.colorScheme.onPrimary,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.translateToLibras),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 24 * spacing),
              Text(
                l10n.resultTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8 * spacing),
              Container(
                constraints: const BoxConstraints(minHeight: 220),
                width: double.infinity,
                padding: EdgeInsets.all(16 * spacing),
                decoration: BoxDecoration(
                  color: tokens?.surfaceMuted ??
                      theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: tokens?.border ?? theme.colorScheme.outlineVariant,
                  ),
                ),
                child: Consumer<TranslateViewModel>(
                  builder: (context, viewModel, _) {
                    if (viewModel.errorMessage != null) {
                      return Center(
                        child: Text(
                          viewModel.errorMessage!,
                          style: TextStyle(
                            color: tokens?.onSurfaceMuted ??
                                theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }

                    if (viewModel.signs.isEmpty &&
                        viewModel.notFoundWords.isEmpty) {
                      return Center(
                        child: Text(
                          l10n.librasTranslationPlaceholder,
                          style: TextStyle(
                            color: tokens?.onSurfaceMuted ??
                                theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (viewModel.signs.isEmpty &&
                            viewModel.notFoundWords.isNotEmpty) ...[
                          Text(
                            l10n.signNotExists,
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (viewModel.signWritingSequence != null) ...[
                          Text(
                            l10n.signWritingSequence,
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
                            l10n.foundSigns,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          SizedBox(height: 8 * spacing),
                          SizedBox(
                            height: 110,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: viewModel.signs.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                return _buildSignMiniCard(
                                    viewModel.signs[index]);
                              },
                            ),
                          ),
                        ],
                        if (viewModel.notFoundWords.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            l10n.notFoundWords,
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
                      ],
                    );
                  },
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
                      SizedBox(height: 16 * spacing),
                      Text(
                        l10n.recentTranslations,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8 * spacing),
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
                              padding: EdgeInsets.only(right: 8.0 * spacing),
                              child: ActionChip(
                                label: Text(label),
                                onPressed: () {
                                  _textController.text = item.sourceText;
                                  _translate();
                                },
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.1),
                                labelStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
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
    final theme = Theme.of(context);
    final tokens = theme.extension<AppThemeTokens>();
    return Container(
      width: 90,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: tokens?.border ?? theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Expanded(
            child: Image.asset(
              sign.signImagePath,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.sign_language,
                  color: tokens?.onSurfaceMuted ??
                      theme.colorScheme.onSurfaceVariant,
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
