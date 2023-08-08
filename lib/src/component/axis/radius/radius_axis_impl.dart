import 'dart:ui';

import 'package:e_chart/e_chart.dart';


///半径轴
class RadiusAxisImpl<C extends CoordLayout> extends LineAxisImpl<RadiusAxis, RadiusAxisAttrs, C> {
  RadiusAxisImpl(super.context, super.coord, super.axis);

  @override
  void onDrawAxisSplitLine(Canvas canvas, Paint paint, Offset scroll) {
    var theme = getAxisTheme();
    each(layoutResult.split, (split, i) {
      LineStyle? style = axis.getSplitLineStyle(split.index, split.maxIndex, theme);
      if (style == null) {
        return;
      }
      Arc arc = Arc(
        innerRadius: 0,
        outRadius: split.start.distance2(attrs.center),
        startAngle: attrs.offsetAngle,
        sweepAngle: 360,
        center: attrs.center,
      );
      style.drawPath(canvas, paint, arc.toPath(false));
    });
  }

  @override
  void onDrawAxisSplitArea(Canvas canvas, Paint paint, Offset scroll) {
    var theme = getAxisTheme();
    each(layoutResult.split, (split, i) {
      AreaStyle? style = axis.getSplitAreaStyle(split.index, split.maxIndex, theme);
      if (style == null) {
        return;
      }
      Arc arc = Arc(
        innerRadius: split.start.distance2(split.center),
        outRadius: split.end.distance2(split.center),
        startAngle: attrs.offsetAngle,
        sweepAngle: 360,
        center: attrs.center,
      );
      style.drawPath(canvas, paint, arc.toPath(true));
    });
  }

  @override
  void onDrawAxisPointer(Canvas canvas, Paint paint, Offset offset) {
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
    axisPointer.lineStyle.drawPath(canvas, paint, arc.toPath(true), drawDash: true, needSplit: false);
  }

  List<num> dataToRadius(DynamicData data) {
    return scale.toRange(data.data);
  }
}
