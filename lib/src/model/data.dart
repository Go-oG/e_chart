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

class ItemData extends BaseItemData {
  num value;
  ItemData(this.value, {super.label, super.id});
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

String getText(dynamic data){
  if(data is String){return data;}

  if(data is num){return formatNumber(data,1);}
  if(data is DateTime){
    return data.toString();
  }
  throw ChartError("only support String num DateTime");

}
