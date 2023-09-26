import 'package:e_chart/e_chart.dart';
import 'package:flutter/painting.dart';

class ChartAlign {
  static const center = ChartAlign();
  final Alignment align;
  final bool inside;

  const ChartAlign({this.align = Alignment.center, this.inside = true});

  void fill(TextDraw textDraw, Rect rect, LabelStyle style, Direction direction) {
    double x = rect.center.dx + align.x * rect.width / 2;
    double y = rect.center.dy + align.y * rect.height / 2;
    if (!inside) {
      double lineWidth = (style.guideLine?.length ?? 0).toDouble();
      List<num> lineGap = (style.guideLine?.gap ?? [0, 0]);
      if (direction == Direction.vertical) {
        int dir = align.x > 0 ? 1 : -1;
        x += dir * (lineWidth + lineGap[0]);
      } else {
        int dir = align.y > 0 ? 1 : -1;
        y += dir * (lineWidth + lineGap[1]);
      }
    }
    Offset offset = Offset(x, y);
    Alignment textAlign = toInnerAlign(align);
    if (!inside) {
      textAlign = Alignment(-textAlign.x, -textAlign.y);
    }
    textDraw.updatePainter(style: style, offset: offset, align: textAlign);
  }

  void fill2(TextDraw draw, Arc arc, LabelStyle style, Direction direction) {
    var angle = (arc.startAngle + arc.sweepAngle / 2) + align.x * arc.sweepAngle.abs();
    num diff = arc.outRadius - arc.innerRadius;
    var radius = (arc.innerRadius + diff / 2) + align.y * diff;
    draw.updatePainter(offset: circlePoint(radius, angle, arc.center), align: Alignment.center);
  }

}
