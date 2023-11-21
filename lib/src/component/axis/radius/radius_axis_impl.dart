import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///半径轴
class RadiusAxisImpl<C extends CoordLayout> extends LineAxisImpl<RadiusAxis, RadiusAxisAttrs, C> {
  RadiusAxisImpl(super.context, super.coord, super.axis);

  @override
  void onDrawAxisSplitLine(CCanvas canvas, Paint paint, Offset scroll) {
    var theme = getAxisTheme();
    each(axisPainter.split, (split, i) {
      var style = axis.splitLine.getStyle(split.index, split.maxIndex, theme);
      if (style.notDraw) {
        return;
      }
      style.drawArc(canvas, paint, split.start.distance2(attrs.center), attrs.offsetAngle, 360, attrs.center);
    });
  }

  @override
  void onDrawAxisSplitArea(CCanvas canvas, Paint paint, Offset scroll) {
    var theme = getAxisTheme();
    each(axisPainter.split, (split, i) {
      var style = axis.splitArea.getStyle(split.index, split.maxIndex, theme);
      if (style.notDraw) {
        return;
      }
      var arc = Arc(
        innerRadius: split.start.distance2(split.center),
        outRadius: split.end.distance2(split.center),
        startAngle: attrs.offsetAngle,
        sweepAngle: 360,
        center: attrs.center,
      );
      style.drawArc(canvas, paint, arc);
    });
  }

  @override
  void onDrawAxisPointer(CCanvas canvas, Paint paint, Offset offset) {
    var axisPointer = axis.axisPointer;
    if (axisPointer == null || !axisPointer.show) {
      return;
    }
    var ir = attrs.start.distance2(attrs.center);
    var or = attrs.end.distance2(attrs.center);
    var dis = offset.distance2(attrs.center);
    if (dis <= ir || dis >= or) {
      return;
    }

    bool snap = axisPointer.snap ?? (axis.isCategoryAxis || axis.isTimeAxis);
    Arc arc;
    if (snap) {
      var interval = scale.tickInterval;
      var diff = dis - ir;
      int c = diff ~/ interval;
      if (axis.isCategoryAxis) {
        c -= 1;
      }
      if (!axis.isCategoryAxis) {
        int next = c + 1;
        num diff1 = (c * interval - dis).abs();
        num diff2 = (next * interval - dis).abs();
        if (diff1 > diff2) {
          c = next;
        }
      }

      if (axis.isCategoryAxis && axis.categoryCenter) {
        dis = (c + 0.5) * interval;
      } else {
        dis = c * interval * 1;
      }
      arc = Arc(
        innerRadius: 0,
        outRadius: dis,
        startAngle: attrs.offsetAngle,
        sweepAngle: 360,
        center: attrs.center,
      );
    } else {
      arc = Arc(
        innerRadius: 0,
        outRadius: offset.distance2(attrs.center),
        startAngle: attrs.offsetAngle,
        sweepAngle: 360,
        center: attrs.center,
      );
    }
    axisPointer.lineStyle.drawPath(canvas, paint, arc.toPath(), drawDash: true);
  }

  List<num> dataToRadius(dynamic data) {
    checkDataType(data);
    return scale.toRange(data);
  }
}
