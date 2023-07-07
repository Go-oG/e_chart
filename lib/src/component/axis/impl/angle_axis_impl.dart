import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/model/tick_result.dart';
import 'package:flutter/material.dart';

///角度轴(是一个完整的环,类似于Y轴)
class AngleAxisImpl extends BaseAxisImpl<AngleAxis, ArcProps> {
  static const int maxAngle = 360;

  AngleAxisImpl(super.axis, [int index = 0]) : super(index: index);

  @override
  BaseScale buildScale(ArcProps props, List<DynamicData> dataSet) {
    num s = props.angleOffset;
    num e;
    if (props.clockwise) {
      e = s + maxAngle;
    } else {
      e = s - maxAngle;
    }
    return axis.toScale([s, e], dataSet, false);
  }

  @override
  TextDrawConfig layoutAxisName() {
    DynamicText? label = titleNode.label;
    Offset start = props.center;
    Offset end = circlePoint(props.radius, props.angleOffset, props.center);
    if (axis.nameAlign == Align2.center || (label == null || label.isEmpty)) {
      return TextDrawConfig(Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2), align: Alignment.center);
    }
    if (axis.nameAlign == Align2.start) {
      return TextDrawConfig(start, align: Alignment.centerLeft);
    }
    return TextDrawConfig(end, align: toAlignment(end.offsetAngle(start)));
  }

  @override
  void onDrawAxisSplitArea(Canvas canvas, Paint paint, Rect coord) {
    var axisLine = axis.axisLine;
    var theme = getAxisTheme();
    for (int i = 1; i < arcTickList.length; i++) {
      var preArc = arcTickList[i - 1].arc;
      var curArc = arcTickList[i].arc;
      AreaStyle? style = axisLine.getSplitAreaStyle(i, arcTickList.length, theme);
      if (style != null) {
        Arc arc = Arc(
          center: curArc.center,
          innerRadius: preArc.outRadius,
          outRadius: curArc.outRadius,
          sweepAngle: maxAngle,
          startAngle: props.angleOffset,
        );
        style.drawPath(canvas, paint, arc.toPath(true));
      }
    }
  }

  @override
  void onDrawAxisSplitLine(Canvas canvas, Paint paint, Rect coord) {
    var axisLine = axis.axisLine;
    var theme = getAxisTheme();
    each(arcTickList, (arc, index) {
      LineStyle? style = axisLine.getSplitLineStyle(index, arcTickList.length, theme);
      if (style != null) {
        Offset offset = circlePoint(arc.arc.outRadius, arc.arc.startAngle, arc.arc.center);
        style.drawPolygon(canvas, paint, [props.center, offset]);
      }
    });
  }

  @override
  void onDrawAxisLine(Canvas canvas, Paint paint) {
    var axisLine = axis.axisLine;
    var theme = getAxisTheme();
    each(arcTickList, (arc, index) {
      LineStyle? style = axisLine.getAxisLineStyle(index, arcTickList.length, theme);
      if (style != null) {
        style.drawPath(canvas, paint, arc.arc.arcOpen(), true);
      }
    });
  }

  @override
  void onDrawAxisTick(Canvas canvas, Paint paint) {
    var axisLine = axis.axisLine;
    var theme = getAxisTheme();
    each(arcTickList, (arc, p1) {
      MainTick? tick = axisLine.getMainTick(p1, arcTickList.length, theme);
      if (tick == null || !tick.show) {
        return;
      }
      each(arc.tick, (at, p1) {
        tick.lineStyle.drawPolygon(canvas, paint, [at.start, at.end]);
        if (at.text != null && at.textConfig != null) {
          tick.labelStyle.draw(canvas, paint, at.text!, at.textConfig!);
        }
      });
    });
  }

  @override
  List<DynamicText> obtainTicks() {
    if (scale is! LinearScale) {
      return super.obtainTicks();
    }
    return axis.buildTicks(scale);
  }

  List<ArcRange> arcTickList = [];

  @override
  void updateTickPosition() {
    final int count = scale.tickCount - 1;
    final int dir = props.clockwise ? 1 : -1;
    final num angleInterval = dir * maxAngle / count;
    List<ArcRange> rangeList = [];
    List<DynamicText> ticks = obtainTicks();

    final tmpTick = MainTick();
    for (int i = 0; i < count; i++) {
      num startAngle = axis.offsetAngle + i * angleInterval;
      dynamic firstData = scale.toData(startAngle);
      dynamic endData = scale.toData(startAngle + angleInterval);

      var arc = Arc(
        innerRadius: 0,
        outRadius: props.radius,
        startAngle: startAngle,
        sweepAngle: angleInterval,
        center: props.center,
      );
      MainTick tick = axis.axisLine.getMainTick(i, count, getAxisTheme()) ?? tmpTick;
      List<DynamicText> tl = [];
      if (i < ticks.length) {
        tl.add(ticks[i]);
        tl.add(DynamicText.empty);
      }
      List<TickResult> result = tick.computeCircleTick(props.radius, startAngle, angleInterval, tl, center: props.center);
      rangeList.add(ArcRange(arc, firstData, endData, result));
    }
    arcTickList = rangeList;
  }

  ///将一个"Y轴数据" 转换到角度范围
  ///如果轴类型为category 则返回角度的范围，否则返回单一角度
  List<num> dataToAngle(DynamicData data) {
    return scale.toRange(data.data);
  }
}

///在半径轴中使用
class ArcProps {
  final Offset center;
  final double radius;
  final double angleOffset;
  final bool clockwise;

  ArcProps(
    this.center,
    this.angleOffset,
    this.radius, {
    this.clockwise = true,
  });
}

class ArcRange {
  final Arc arc;

  final dynamic startData;
  final dynamic endData;
  final List<TickResult> tick;

  ArcRange(this.arc, this.startData, this.endData, this.tick);
}
