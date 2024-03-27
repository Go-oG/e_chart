import 'dart:ui';

import '../../../e_chart.dart';

class MarkPoint extends ChartNotifier2{
  MarkPointData data;
  ChartSymbol symbol = CircleSymbol();
  bool touch;
  LabelStyle? labelStyle;
  int precision; //精度

  late TextDraw _label;

  MarkPoint(
    this.data, {
    ChartSymbol? symbol,
    this.touch = false,
    this.labelStyle,
    this.precision = 1,
  }) {
    if (symbol != null) {
      this.symbol = symbol;
    }
    _label = TextDraw(DynamicText.empty, labelStyle ?? LabelStyle(), Offset.zero);
  }

  void draw(CCanvas canvas, Paint paint, Offset offset, [DynamicText? text]) {
    symbol.draw(canvas, paint, offset);
    if (_label.text != text && _label.offset != offset) {
      _label.updatePainter(text: text ?? DynamicText.empty, offset: offset);
    }
    _label.draw(canvas, paint);
  }
}

class MarkPointData {
  final List<dynamic>? data;

  final ValueType? valueType;
  final int? valueDimIndex;

  final List<SNumber>? coord;

  MarkPointData._({this.data, this.valueType, this.valueDimIndex, this.coord}) {
    if (valueType == null && coord == null && data == null) {
      throw ChartError("valueType and coord not all be null ");
    }
    if (valueType != null && valueDimIndex == null) {
      throw ChartError("if valueType not null,valueDimIndex must not null");
    }
    if (coord != null && coord!.length != 2) {
      throw ChartError("coord length must==2");
    }
  }

  MarkPointData.data(List<dynamic> data) : this._(data: data);

  MarkPointData.type(ValueType type, int dimIndex) : this._(valueType: type, valueDimIndex: dimIndex);

  MarkPointData.coord(List<SNumber> coord) : this._(coord: coord);
}

class MarkPointNode {
  final MarkPoint markPoint;
  Offset offset = Offset.zero;
  dynamic data;

  MarkPointNode(this.markPoint, this.data);
}