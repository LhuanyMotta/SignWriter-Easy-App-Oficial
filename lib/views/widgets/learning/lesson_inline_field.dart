import 'package:flutter/material.dart';

/// Campo de texto sem “cara de formulário”, para edição WYSIWYG na lição.
class LessonInlineField extends StatefulWidget {
  final String value;
  final String hint;
  final TextStyle style;
  final int minLines;
  final Color? cursorColor;
  final bool showUnderline;
  final TextAlign textAlign;
  final ValueChanged<String> onChanged;

  const LessonInlineField({
    super.key,
    required this.value,
    required this.hint,
    required this.style,
    required this.onChanged,
    this.minLines = 1,
    this.cursorColor,
    this.showUnderline = true,
    this.textAlign = TextAlign.start,
  });

  @override
  State<LessonInlineField> createState() => _LessonInlineFieldState();
}

class _LessonInlineFieldState extends State<LessonInlineField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant LessonInlineField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent =
        widget.cursorColor ?? Theme.of(context).colorScheme.primary;
    return TextField(
      controller: _controller,
      style: widget.style,
      maxLines: null,
      minLines: widget.minLines,
      textAlign: widget.textAlign,
      onChanged: widget.onChanged,
      cursorColor: accent,
      decoration: InputDecoration(
        isDense: true,
        hintText: widget.hint,
        hintStyle: widget.style.copyWith(
          color: widget.style.color?.withValues(alpha: 0.35),
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        enabledBorder: widget.showUnderline
            ? UnderlineInputBorder(
                borderSide: BorderSide(color: accent.withValues(alpha: 0.15)),
              )
            : InputBorder.none,
        focusedBorder: widget.showUnderline
            ? UnderlineInputBorder(
                borderSide: BorderSide(color: accent.withValues(alpha: 0.55)),
              )
            : InputBorder.none,
      ),
    );
  }
}
