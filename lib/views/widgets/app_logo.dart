import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';

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
    final highlightColor = colored ? const Color(0xFF2D78BB) : Colors.white;
    final iconBackground = colored ? const Color(0xFF2D78BB) : Colors.white.withValues(alpha: 0.08);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size * 1.3,
          height: size * 1.3,
          padding: EdgeInsets.all(size * 0.18),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(size * 0.28),
            border: Border.all(
              color: colored ? Colors.transparent : Colors.white.withValues(alpha: 0.35),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: colored ? 0.12 : 0.18),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/signwriter_logo.png',
            fit: BoxFit.contain,
          ),
        ),
        if (showText) ...[
          SizedBox(height: AppSpacing.value(context, 8)),
          Text(
            'SignWriter Fácil',
            style: TextStyle(
              fontSize: size * 0.24,
              fontWeight: FontWeight.bold,
              color: highlightColor,
            ),
          ),
        ],
      ],
    );
  }
} 
