import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class MarkLine extends ChartNotifier2{
  MarkPoint start;
  MarkPoint end;
  bool touch;
  LineStyle lineStyle;
  int precision; //精度

  MarkLine(
    this.start,
    this.end, {
    this.touch = false,
    this.lineStyle = const LineStyle(dash: [4,8]),
    this.precision = 2,
  }){
    start.addListener(notifyListeners);
    end.addListener(notifyListeners);
  }

  void draw(CCanvas canvas, Paint paint, Offset start, Offset end, {DynamicText? startText, DynamicText? endText}) {
    lineStyle.drawPolygon(canvas, paint, [start, end]);
    this.start.draw(canvas, paint, start);
    this.end.draw(canvas, paint, end);
  }
}

class MarkLineNode {
  final MarkLine line;
  final MarkPointNode start;
  final MarkPointNode end;

  MarkLineNode(this.line,this.start, this.end);
}
