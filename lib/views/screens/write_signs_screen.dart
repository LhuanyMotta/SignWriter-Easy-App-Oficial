import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/write_signs_viewmodel.dart';
import '../../theme/app_theme.dart';

class WriteSignsScreen extends StatefulWidget {
  const WriteSignsScreen({super.key});

  @override
  State<WriteSignsScreen> createState() => _WriteSignsScreenState();
}

class _WriteSignsScreenState extends State<WriteSignsScreen> {
  late WriteSignsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = WriteSignsViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Escrever Sinais'),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.edit_document,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Escrever Sinais',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Esta área será reestruturada em breve para criação e edição de sinais em SignWriting.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context)
                              .extension<AppThemeTokens>()
                              ?.onSurfaceMuted ??
                          Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
