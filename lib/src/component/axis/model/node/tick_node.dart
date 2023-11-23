import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class TickNode extends Disposable {
  ///数据可能为空
  List<dynamic> data;
  int index;
  int maxIndex;
  Offset start;
  Offset end;
  LineStyle style;
  List<TickNode> minorList;

  TickNode(
    this.data,
    this.index,
    this.maxIndex,
    this.start,
    this.end,
    this.style, [
    this.minorList = const [],
  ]);

  void draw(CCanvas canvas, Paint paint) {
    style.drawLine(canvas, paint, start, end);
    each(minorList, (tick, p1) {
      tick.draw(canvas, paint);
    });
  }

  @override
  void dispose() {
    super.dispose();
    each(minorList, (p0, p1) {
      p0.dispose();
    });
    minorList = [];
  }
}
