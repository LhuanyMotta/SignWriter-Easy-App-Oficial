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
    this.size = 100.0,
    this.colored = true,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    // Cores principais do app
    final Color primaryColor = const Color(0xFF2D78BB);
    final Color secondaryColor = const Color(0xFF4EB1F0);
    
    // Cor do texto e símbolo baseada no modo (colorido ou branco)
    final Color symbolColor = colored ? primaryColor : Colors.white;
    final Color textColor = colored ? secondaryColor : Colors.white;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Símbolo do SignWriter (uma mão estilizada)
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: colored
                ? [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Palma da mão
                Container(
                  width: size * 0.5,
                  height: size * 0.65,
                  decoration: BoxDecoration(
                    color: symbolColor,
                    borderRadius: BorderRadius.circular(size * 0.25),
                  ),
                ),
                
                // Dedos
                Positioned(
                  top: size * 0.1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => Padding(
                        padding: EdgeInsets.symmetric(horizontal: size * 0.02),
                        child: Container(
                          width: size * 0.08,
                          height: index == 0 || index == 4 
                              ? size * 0.25  // Dedos mais curtos (polegar e mindinho)
                              : size * 0.32, // Dedos mais longos
                          decoration: BoxDecoration(
                            color: symbolColor,
                            borderRadius: BorderRadius.circular(size * 0.04),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Símbolo de escrita (W)
                Positioned(
                  bottom: size * 0.2,
                  child: Text(
                    "W",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Texto "SignWriter Fácil"
        if (showText) ...[
          SizedBox(height: size * 0.15),
          Text(
            "SignWriter",
            style: TextStyle(
              color: textColor,
              fontSize: size * 0.22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          Text(
            "Fácil",
            style: TextStyle(
              color: textColor,
              fontSize: size * 0.18,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ],
    );
  }
} 