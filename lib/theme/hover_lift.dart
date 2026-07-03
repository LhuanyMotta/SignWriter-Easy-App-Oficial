import 'package:flutter/material.dart';

/// Dá um efeito de "levantar" ao passar o mouse — só faz sentido na Web/
/// desktop, onde existe cursor de mouse. Em touch (celular) não tem hover,
/// então o widget simplesmente não reage e fica igual ao original.
class HoverLift extends StatefulWidget {
  final Widget child;
  final double liftPx;
  final double scale;

  const HoverLift({
    super.key,
    required this.child,
    this.liftPx = 6,
    this.scale = 1.02,
  });

  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        offset: _hovering ? Offset(0, -widget.liftPx / 100) : Offset.zero,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          scale: _hovering ? widget.scale : 1.0,
          child: widget.child,
        ),
      ),
    );
  }
}
