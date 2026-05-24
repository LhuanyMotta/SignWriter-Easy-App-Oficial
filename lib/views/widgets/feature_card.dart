import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';

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
    // Uso de Material para efeito de ink splash quando pressionado
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      elevation: 3, // Sombra sutil para dar profundidade
      child: InkWell(
        onTap: () => onTap(context),
        borderRadius: BorderRadius.circular(20),
        // Ripple effect na cor branca com opacidade reduzida
        splashColor: Colors.white.withOpacity(0.3),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Padding(
          padding: AppSpacing.all(context, 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone com tamanho adequado
              Icon(
                icon,
                size: 42,
                color: Colors.white,
              ),
              SizedBox(height: AppSpacing.value(context, 16)),
              // Texto com estilo definido e alinhamento centralizado
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
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
