import 'package:flutter/material.dart';

class AppLoadingState extends StatelessWidget {
  final String message;

  const AppLoadingState({
    super.key,
    this.message = 'Carregando...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}
