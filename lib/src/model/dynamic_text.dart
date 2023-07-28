import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/rendering.dart';

///动态文本
///只接受String、TextSpan、
class DynamicText {
  static DynamicText empty = DynamicText('');
  final dynamic text;

  DynamicText(this.text) {
    if (text is! String && text is! TextSpan && text is! Paragraph) {
      throw FlutterError('只能是 String、TextSpan、 num');
    }
  }

  DynamicText.fromString(String s) : text = s;

  DynamicText.fromTextSpan(TextSpan t) : text = t;

  DynamicText.fromParagraph(Paragraph p) : text = p;

  bool get isString => text is String;

  bool get isTextSpan => text is TextSpan;

  bool get isParagraph => text is Paragraph;

  bool get isEmpty {
    if (isString) {
      return (text as String).isEmpty;
    }
    if (isTextSpan) {
      return (text as TextSpan).text?.isEmpty ?? true;
    }
    return false;
  }

  bool get isNotEmpty {
    return !isEmpty;
  }

  int get length {
    if (isString) {
      return (text as String).length;
    }
    if (isTextSpan) {
      return (text as TextSpan).text?.length ?? 0;
    }
    Paragraph p = text as Paragraph;
    p.layout(const ParagraphConstraints(width: double.infinity));
    return p.width.toInt();
  }

  final TextStyle _textStyle = const TextStyle(fontSize: 15);

  Size getTextSize([TextStyle? style]) {
    var ts=style??_textStyle;
    if (isString) {
      TextPainter painter = ts.toPainter(text as String);
      painter.layout(maxWidth: double.infinity);
      return painter.size;
    }
    if (isTextSpan) {
      TextPainter painter = TextPainter(text: text as TextSpan, textAlign: TextAlign.center);
      painter.layout(maxWidth: double.infinity);
      return painter.size;
    }
    if (isString || isTextSpan) {
      TextPainter painter = ts.toPainter(text as String);
      painter.layout(maxWidth: double.infinity);
      return painter.size;
    }
    Paragraph p = text as Paragraph;
    p.layout(const ParagraphConstraints(width: double.infinity));
    return Size(p.width, p.height);
  }

  @override
  String toString() {
    return '$text';
  }

}
