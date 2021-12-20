import 'package:flutter/material.dart';

const shrug = '¯\\_(ツ)_/¯';

class AsciimojiShrug extends StatelessWidget {
  final double fontSize;
  final String? label;
  final double? labelFontSize;
  final int? labelMaxLines;

  const AsciimojiShrug({
    Key? key,
    this.fontSize = 32,
    this.label,
    this.labelFontSize,
    this.labelMaxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).textTheme.caption!.color;
    final text = Text(
      shrug,
      maxLines: 1,
      style: TextStyle(color: color, fontSize: fontSize),
    );
    if (label == null) {
      return text;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        text,
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            label!,
            maxLines: labelMaxLines,
            style: TextStyle(color: color, fontSize: labelFontSize),
          ),
        ),
      ],
    );
  }
}
