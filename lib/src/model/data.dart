import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/painting.dart';

class GroupData {
  late final String id;
  DynamicText? label;
  List<ItemData> childData;

  bool show = true;

  GroupData(
    this.childData, {
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
    return other is GroupData && other.id == id;
  }
}

class ItemData {
  late final String id;
  num value;
  DynamicText? label;

  bool show = true;

  ItemData({this.value = 0, this.label, String? id}) {
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
    return other is ItemData && other.id == id;
  }
}

class DataNode<P, D> with ViewStateProvider implements NodeAccessor<P, D> {
  final int dataIndex;
  final int? groupIndex;
  final D data;
  P attr;

  DataNode(this.data, this.dataIndex, this.groupIndex, this.attr);

  @override
  bool operator ==(Object other) {
    return other is DataNode && other.data == data;
  }

  @override
  int get hashCode {
    return data.hashCode;
  }

  @override
  D get d => data;

  @override
  P getP() {
    return attr;
  }

  @override
  void setP(P po) {
    attr = po;
  }
}

///动态数据(只接受字符串 数字 时间类型的数据)
class DynamicData {
  dynamic _data;

  dynamic get data => _data;

  DynamicData(this._data) {
    if (data is! String && data is! DateTime && data is! num) {
      throw ChartError('只能是 String、DateTime、num CurrentType:${data.runtimeType}');
    }
  }

  DynamicData change(dynamic data) {
    if (data is! String && data is! DateTime && data is! num) {
      throw ChartError('只能是 String DateTime num CurrentType:${data.runtimeType}');
    }
    _data = data;
    return this;
  }

  bool get isString {
    return data is String;
  }

  bool get isDate {
    return data is DateTime;
  }

  bool get isNum {
    return data is num;
  }

  String getText([int fractionDigits = 3, Fun2<DateTime, String>? timeFormatter]) {
    if (isString) {
      return '$data';
    }
    if (isNum) {
      return formatNumber(data as num, 1);
    }

    var time = data as DateTime;
    if (timeFormatter != null) {
      return timeFormatter.call(time);
    }
    return '${time.month.padLeft(2, '0')}-${time.day.padLeft(2, '0')}';
  }

  @override
  String toString() {
    if (isString) {
      return '$data';
    }
    if (isNum) {
      return (data as num).toStringAsFixed(1);
    }

    var time = data as DateTime;
    return 'Time:${time.year}-${time.month.padLeft(2, '0')}-${time.day.padLeft(2, '0')} '
        '${time.hour.padLeft(2, '0')}:${time.minute.padLeft(2, '0')}:${time.second.padLeft(2, '0')}';
  }

  @override
  int get hashCode {
    return data.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is DynamicData && other.data == data;
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
