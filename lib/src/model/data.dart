import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/painting.dart';

class GroupData extends BaseGroupData<ItemData> {
  GroupData(
    super.data, {
    super.id,
    super.label,
  });
}

class BaseGroupData<T> {
  late final String id;
  DynamicText? label;

  List<T> data;

  bool show = true;

  BaseGroupData(
    this.data, {
    String? id,
    this.label,
  }) {
    if (id == null || id.isEmpty) {
      this.id = randomId();
    } else {
      this.id = id;
    }
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is BaseGroupData && other.id == id;
  }
}

class ItemData extends BaseItemData {
  num value;

  ItemData(this.value, {super.label, super.id});

  @override
  String toString() {
    return "$runtimeType value:${value.toStringAsFixed(2)}";
  }
}

class BaseItemData {
  late final String id;
  DynamicText? label;
  bool show = true;

  BaseItemData({this.label, String? id}) {
    if (id == null || id.isEmpty) {
      this.id = randomId();
    } else {
      this.id = id;
    }
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is BaseItemData && other.id == id;
  }
}

///动态文本
///只接受String、TextSpan、
class DynamicText {
  static DynamicText empty = DynamicText('');
  final dynamic text;

  DynamicText(this.text) {
    if (text is! String && text is! TextSpan && text is! Paragraph) {
      throw ChartError('只能是 String、TextSpan、 num');
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
    var ts = style ?? _textStyle;
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

String getText(dynamic data) {
  if (data is String) {
    return data;
  }

  if (data is num) {
    return formatNumber(data, 1);
  }
  if (data is DateTime) {
    return data.toString();
  }
  throw ChartError("only support String num DateTime");
}
