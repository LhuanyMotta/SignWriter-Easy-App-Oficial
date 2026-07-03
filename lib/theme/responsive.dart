import 'package:flutter/material.dart';

/// Ponto central pra decidir quando o layout deve mudar pra um formato de
/// Web/desktop (telas largas) em vez do layout original de celular.
///
/// Uso:
///   if (Responsive.isWide(context)) { ... layout largo ... }
///   else { ... layout de celular (original) ... }
class Responsive {
  Responsive._();

  /// Abaixo disso, mantém o layout de celular de sempre.
  static const double wideBreakpoint = 900;

  static bool isWide(BuildContext context) =>
      MediaQuery.of(context).size.width >= wideBreakpoint;

  /// Largura máxima de conteúdo dentro de telas largas, pra texto e cards
  /// não ficarem esticados ao infinito num monitor grande.
  static const double maxContentWidth = 1100;
}
