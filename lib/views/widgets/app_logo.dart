import 'package:flutter/material.dart';

/// Widget para exibir a logo do aplicativo SignWriter Fácil
class AppLogo extends StatelessWidget {
  /// Tamanho da logo
  final double size;
  
  /// Se deve usar a versão colorida (azul) ou branca
  final bool colored;
  
  /// Se deve mostrar o texto do nome do app junto com o símbolo
  final bool showText;
  
  /// Construtor
  const AppLogo({
    super.key,
    this.size = 100,
    this.colored = true,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/signwriter_logo.png',
          width: size,
          height: size,
        ),
        if (showText) ...[
          const SizedBox(height: 8),
          Text(
            'SignWriter Fácil',
            style: TextStyle(
              fontSize: size * 0.24,
              fontWeight: FontWeight.bold,
              color: colored ? const Color(0xFF2D78BB) : Colors.white,
            ),
          ),
        ],
      ],
    );
  }
} 