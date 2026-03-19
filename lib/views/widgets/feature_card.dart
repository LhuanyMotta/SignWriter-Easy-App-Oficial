import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Widget que representa um card de funcionalidade na tela inicial
/// 
/// Este widget é responsável por exibir um cartão interativo para cada
/// funcionalidade principal do aplicativo na tela inicial.
class FeatureCard extends StatelessWidget {
  /// Título da funcionalidade
  final String title;
  
  /// Ícone representativo da funcionalidade
  final IconData icon;
  
  /// Cor de destaque do card
  final Color color;
  
  /// Função a ser executada quando o card for tocado
  final Function(BuildContext) onTap;

  /// Construtor
  const FeatureCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;
    final spacing = theme.extension<AppThemeTokens>()?.spacingScale ?? 1.0;
    // Uso de Material para efeito de ink splash quando pressionado
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      elevation: 3, // Sombra sutil para dar profundidade
      child: InkWell(
        onTap: () => onTap(context),
        borderRadius: BorderRadius.circular(20),
        // Ripple effect na cor branca com opacidade reduzida
        splashColor: onPrimary.withOpacity(0.3),
        highlightColor: onPrimary.withOpacity(0.1),
        child: Padding(
          padding: EdgeInsets.all(16.0 * spacing),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone com tamanho adequado
              Icon(
                icon,
                size: 42,
                color: onPrimary,
              ),
              SizedBox(height: 16 * spacing),
              // Texto com estilo definido e alinhamento centralizado
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: onPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 