import 'package:flutter/material.dart';
import 'responsive.dart';

/// Envolve o conteúdo de uma tela pra ele não esticar de ponta a ponta em
/// telas largas (Web/desktop) — fica centralizado com uma largura máxima.
/// Em celular (tela estreita) não muda nada, porque a tela já é menor que
/// o limite.
class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final AlignmentGeometry alignment;

  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = Responsive.maxContentWidth,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    if (!Responsive.isWide(context)) return child;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
