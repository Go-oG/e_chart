import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/core/render/element_render.dart';

class TickRender extends ElementRender {
  ///数据可能为空
  late List<dynamic> data;
  int index;
  int maxIndex;
  Offset start;
  Offset end;
  LineStyle style;
  List<TickRender> minorList;

  TickRender(
    dynamic data,
    this.index,
    this.maxIndex,
    this.start,
    this.end,
    this.style, [
    this.minorList = const [],
  ]) {
    if (data is List<dynamic>) {
      this.data = data;
    } else {
      this.data = [data];
    }
  }

  @override
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
