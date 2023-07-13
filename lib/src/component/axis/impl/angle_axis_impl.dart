import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/model/tick_result.dart';
import 'package:flutter/material.dart';

///角度轴(是一个完整的环,类似于Y轴)
class AngleAxisImpl extends BaseAxisImpl<AngleAxis, ArcProps> {
  static const int maxAngle = 360;

  AngleAxisImpl(super.axis, [int index = 0]) : super(axisIndex: index);

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
    var axisLine = axis.axisStyle;
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
    var axisLine = axis.axisStyle;
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
    var axisLine = axis.axisStyle;
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
    var axisStyle = axis.axisStyle;
    var theme = getAxisTheme();
    int maxCount = arcTickList.length;
    each(arcTickList, (arc, p1) {
      MainTick? tick = axisStyle.getMainTick(p1, maxCount, theme);
      var minorTick = axisStyle.getMinorTick(p1, maxCount, theme);
      bool b1 = (tick != null && tick.show);
      bool b2 = (minorTick != null && minorTick.show);
      if (b1 || b2) {
        each(arc.tick, (at, p2) {
          if (b1) {
            tick?.lineStyle.drawPolygon(canvas, paint, [at.start, at.end]);
          }
          if (b2) {
            each(at.minorTickList, (minor, p1) {
              minorTick?.lineStyle.drawPolygon(canvas, paint, [minor.start, minor.end]);
            });
          }
        });
      }

      ///绘制标签
      var label = axisStyle.getLabelStyle(p1, maxCount, theme);
      var minorLabel = axisStyle.getMinorLabelStyle(p1, maxCount, theme);

      b1 = (label != null && label.show);
      b2 = (minorLabel != null && minorLabel.show);

      if (b1 || b2) {
        each(arc.tick, (at, p2) {
          if (b1 && at.text != null && at.textConfig != null) {
            label?.draw(canvas, paint, at.text!, at.textConfig!);
          }
          if (b2) {
            each(at.minorTickList, (minor, p1) {
              if (minor.text != null && minor.textConfig != null) {
                minorLabel?.draw(canvas, paint, minor.text!, minor.textConfig!);
              }
            });
          }
        });
      }
    });
  }

  List<ArcRange> arcTickList = [];

  @override
  void updateTickPosition() {
    final int count = scale.tickCount - 1;
    final int dir = props.clockwise ? 1 : -1;
    final num angleInterval = dir * maxAngle / count;
    List<ArcRange> rangeList = [];
    List<DynamicText> ticks = obtainTicks();

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

      List<DynamicText> tl = [];
      if (i < ticks.length) {
        tl.add(ticks[i]);
        tl.add(DynamicText.empty);
      }
      List<TickResult> result = computeCircleTick(i, count, startAngle, angleInterval, tl);
      rangeList.add(ArcRange(arc, firstData, endData, result));
    }
    arcTickList = rangeList;
  }

  final tmpTick = MainTick();
  final MinorTick _tmpMinorTick = MinorTick();

  List<TickResult> computeCircleTick(int index, int maxIndex, num startAngle, num sweepAngle, List<DynamicText> ticks) {
    MainTick tick = axis.axisStyle.getMainTick(index, maxIndex, getAxisTheme()) ?? tmpTick;
    int tickCount = ticks.length;
    tickCount = max([tickCount, 2]).toInt();
    double interval = sweepAngle / (tickCount - 1);

    final double tickDir = tick.inside ? -1 : 1;
    final double tickOffset = tick.length * tickDir;
    final double r = props.radius;

    List<TickResult> resultList = [];
    for (int i = 0; i < tickCount; i++) {
      double sa = startAngle + i * interval;
      Offset tickStart = circlePoint(r, sa, props.center);
      Offset tickEnd = circlePoint(r + tickOffset, sa, props.center);
      TickResult tickResult;
      if (i >= ticks.length) {
        tickResult = TickResult(tickStart, tickEnd, null, null);
      } else {
        if (ticks.length == 1) {
          sa += interval * 0.5;
        }
        Offset o3 = circlePoint(r + tickOffset, sa, props.center);
        TextDrawConfig config = TextDrawConfig(o3, align: toAlignment(sa, tick.inside));
        tickResult = TickResult(tickStart, tickEnd, config, ticks[i]);
      }

      tickResult.minorTickList.addAll(_computeMinorTickAndLabel(index, maxIndex, sa, interval, tick.inside));
      resultList.add(tickResult);
    }
    return resultList;
  }

  List<TickResult> _computeMinorTickAndLabel(int index, int maxIndex, num startAngle, num sweepAngle, bool inside) {
    if (axis.category) {
      return [];
    }
    final AxisStyle style = axis.axisStyle;
    final bool labelInside = style.axisLabel.inside;
    final MinorTick tick = style.getMinorTick(index, maxIndex, getAxisTheme()) ?? _tmpMinorTick;
    int tickCount = tick.splitNumber;
    if (tickCount <= 0) {
      return [];
    }
    final double interval = sweepAngle / (tickCount - 1);
    final double tickDir = inside ? -1 : 1;
    final int labelDir = labelInside ? -1 : 1;
    final double tickLen = tick.length.toDouble();
    final double tickOffset = tick.length * tickDir;
    final double r = props.radius;
    List<TickResult> resultList = [];
    for (int i = 1; i < tickCount; i++) {
      final double sa = startAngle + i * interval;
      final Offset ts = circlePoint(r, sa, props.center);
      final Offset te = circlePoint(r + tickOffset, sa, props.center);
      num offsetY = style.axisLabel.margin + style.axisLabel.padding;
      if (inside == labelInside) {
        offsetY += tickLen;
      }
      offsetY *= labelDir;
      Offset o3 = circlePoint(r + offsetY, sa, props.center);
      TextDrawConfig config = TextDrawConfig(o3, align: toAlignment(sa, labelInside));
      dynamic data = scale.toData(sa);
      DynamicText? text = style.axisLabel.formatter?.call(data);
      TickResult tickResult = TickResult(ts, te, config, text);
      resultList.add(tickResult);
    }
    return resultList;
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
