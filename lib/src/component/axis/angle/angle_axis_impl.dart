import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///角度轴(是一个完整的环,类似于Y轴)
class AngleAxisImpl extends BaseAxisImpl<AngleAxis, AngleAxisAttrs, AngleAxisLayoutResult> {
  static const int maxAngle = 360;
  final tmpTick = MainTick();
  final MinorTick tmpMinorTick = MinorTick();

  AngleAxisImpl(super.context, super.axis, {super.axisIndex});

  @override
  BaseScale onBuildScale(AngleAxisAttrs attrs, List<DynamicData> dataSet) {
    num s = attrs.angleOffset;
    num e;
    if (attrs.clockwise) {
      e = s + maxAngle;
    } else {
      e = s - maxAngle;
    }

    return BaseAxisImpl.toScale(axis, [s, e], dataSet);
  }

  @override
  AngleAxisLayoutResult onLayout(AngleAxisAttrs attrs, BaseScale<dynamic, num> scale, List<DynamicData> dataSet) {
    Arc arc = Arc(
      center: attrs.center,
      outRadius: attrs.radius,
      innerRadius: 0,
      startAngle: attrs.angleOffset,
      sweepAngle: attrs.clockwise ? maxAngle : -maxAngle,
    );
    List<Arc> splitList = buildSplitArc(attrs, scale);
    List<TickResult> tickList = buildTickResult(attrs, scale);
    List<LabelResult> labelList = buildLabelResult(attrs, scale);
    return AngleAxisLayoutResult(arc, splitList, tickList, labelList);
  }

  ///返回分割区域
  List<Arc> buildSplitArc(AngleAxisAttrs attrs, BaseScale<dynamic, num> scale) {
    final int tickCount = scale.tickCount - 1;
    final int dir = attrs.clockwise ? 1 : -1;
    final num angleInterval = dir * maxAngle / tickCount;
    List<Arc> list = [];
    for (int i = 0; i < tickCount; i++) {
      num sa = attrs.angleOffset + angleInterval * i;
      Arc arc = Arc(
        startAngle: sa,
        sweepAngle: angleInterval,
        outRadius: attrs.radius,
        innerRadius: 0,
        center: attrs.center,
      );
      list.add(arc);
    }
    return list;
  }

  ///返回所有的Tick
  List<TickResult> buildTickResult(AngleAxisAttrs attrs, BaseScale<dynamic, num> scale) {
    final int tickCount = scale.tickCount - 1;
    final int dir = attrs.clockwise ? 1 : -1;
    final num angleInterval = dir * maxAngle / tickCount;
    List<TickResult> tickList = [];

    MainTick tick = axis.axisStyle.axisTick.tick ?? tmpTick;
    MinorTick minorTick = axis.axisStyle.minorTick?.tick ?? tmpMinorTick;

    num r = attrs.radius;
    num minorR = attrs.radius;
    if (tick.inside) {
      r -= tick.length;
      minorR -= minorTick.length;
    } else {
      r += tick.length;
      minorR += minorTick.length;
    }

    for (int i = 0; i < tickCount; i++) {
      num angle = attrs.angleOffset + angleInterval * i;
      Offset so = circlePoint(attrs.radius, angle, attrs.center);
      Offset eo = circlePoint(r, angle, attrs.center);
      List<TickResult> minorList = [];
      tickList.add(TickResult(so, eo, minorList));
      if (axis.isCategoryAxis || axis.isTimeAxis || i == tickCount - 1) {
        continue;
      }
      if (minorTick.splitNumber <= 0) {
        continue;
      }
      int minorCount = minorTick.splitNumber;
      num minorInterval = angleInterval / minorCount;
      for (int j = 1; j < minorTick.splitNumber; j++) {
        Offset minorSo = circlePoint(attrs.radius, angle + minorInterval * j, attrs.center);
        Offset minorEo = circlePoint(minorR, angle + minorInterval * j, attrs.center);
        minorList.add(TickResult(minorSo, minorEo));
      }
    }
    return tickList;
  }

  ///返回所有的Label
  List<LabelResult> buildLabelResult(AngleAxisAttrs attrs, BaseScale<dynamic, num> scale) {
    final int dir = attrs.clockwise ? 1 : -1;
    int count = scale.tickCount - 1;
    if (axis.isCategoryAxis && axis.categoryCenter) {
      count += 1;
    }
    if (count <= 0) {
      return [];
    }
    final num angleInterval = dir * maxAngle / count;
    MainTick tick = axis.axisStyle.axisTick.tick ?? tmpTick;
    AxisLabel axisLabel = axis.axisStyle.axisLabel;
    num r = attrs.radius;
    if (tick.inside == axisLabel.inside) {
      r += axisLabel.margin + axisLabel.padding;
    } else {
      if (axisLabel.inside) {
        r -= axisLabel.margin + axisLabel.padding;
      } else {
        r += axisLabel.margin + axisLabel.padding;
      }
    }

    List<LabelResult> resultList = [];
    List<DynamicText> labels = obtainLabel();
    for (int i = 0; i < labels.length; i++) {
      DynamicText text = labels[i];
      num d = i;
      if (axis.isCategoryAxis && axis.categoryCenter) {
        d += 0.5;
      }
      num angle = attrs.angleOffset + angleInterval * d;
      Offset offset = circlePoint(r, angle, attrs.center);
      TextDrawConfig config = TextDrawConfig(offset, align: toAlignment(angle, axisLabel.inside));
      resultList.add(LabelResult(config, text));
      if (axis.isCategoryAxis || axis.isTimeAxis) {
        continue;
      }
      //TODO minorTick label
    }

    return resultList;
  }

  @override
  TextDrawConfig onLayoutAxisName() {
    DynamicText? label = titleNode.label;
    Offset start = attrs.center;
    Offset end = circlePoint(attrs.radius, attrs.angleOffset, attrs.center);
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
    if (!axisLine.show) {
      return;
    }
    var theme = getAxisTheme();

    int maxCount = layoutResult.splitList.length;
    each(layoutResult.splitList, (split, i) {
      AreaStyle? style = axisLine.getSplitAreaStyle(i, maxCount, theme);
      style?.drawPath(canvas, paint, split.toPath(true));
    });
  }

  @override
  void onDrawAxisSplitLine(Canvas canvas, Paint paint, Rect coord) {
    var axisLine = axis.axisStyle;
    if (!axisLine.show) {
      return;
    }
    var theme = getAxisTheme();

    int maxCount = layoutResult.splitList.length;
    each(layoutResult.splitList, (arc, i) {
      LineStyle? style = axisLine.getSplitLineStyle(i, maxCount, theme);
      if (style != null) {
        Offset end = circlePoint(arc.outRadius, arc.startAngle, arc.center);
        style.drawPolygon(canvas, paint, [attrs.center, end]);
      }
    });
  }

  @override
  void onDrawAxisLine(Canvas canvas, Paint paint) {
    var axisStyle = axis.axisStyle;
    if (!axisStyle.show) {
      return;
    }
    var axisLine = axisStyle.axisLine;
    if (!axisLine.show) {
      return;
    }
    var theme = getAxisTheme();

    LineStyle? style = axisLine.getAxisLineStyleNotFun(theme);
    if (style != null) {
      style.drawPath(canvas, paint, layoutResult.arc.toPath(true));
    } else {
      int maxCount = layoutResult.splitList.length;
      each(layoutResult.splitList, (arc, index) {
        var s = axisLine.getAxisLineStyle(index, maxCount, theme);
        s?.drawPath(canvas, paint, arc.arcOpen(), true);
      });
    }
  }

  @override
  void onDrawAxisTick(Canvas canvas, Paint paint) {
    var axisStyle = axis.axisStyle;
    if (!axisStyle.show) {
      return;
    }
    var theme = getAxisTheme();

    ///绘制Tick
    var axisTick = axisStyle.axisTick;
    if (axisTick.show) {
      int maxCount = layoutResult.tick.length;
      each(layoutResult.tick, (result, i) {
        MainTick? tick = axisStyle.getMainTick(i, maxCount, theme);
        var minorTick = axisStyle.getMinorTick(i, maxCount, theme);

        bool b1 = (tick != null && tick.show);
        bool b2 = (minorTick != null && minorTick.show);
        if (b1) {
          tick.lineStyle.drawPolygon(canvas, paint, [result.start, result.end]);
        }
        if (b2) {
          each(result.minorTickList, (mr, j) {
            minorTick.lineStyle.drawPolygon(canvas, paint, [mr.start, mr.end]);
          });
        }
      });
    }

    ///绘制标签
    var axisLabel = axisStyle.axisLabel;
    if (axisLabel.show) {
      int maxCount = layoutResult.label.length;
      each(layoutResult.label, (label, i) {
        var labelStyle = axisStyle.getLabelStyle(i, maxCount, theme);
        var minorStyle = axisStyle.getMinorLabelStyle(i, maxCount, theme);
        bool b1 = (labelStyle != null && labelStyle.show);
        bool b2 = (minorStyle != null && minorStyle.show);
        if (b1 && label.text != null && label.text!.isNotEmpty) {
          labelStyle.draw(canvas, paint, label.text!, label.textConfig);
        }
        if (b2 && label.minorLabel.isNotEmpty) {
          each(label.minorLabel, (ml, i) {
            if (ml.text != null && ml.text!.isNotEmpty) {
              minorStyle.draw(canvas, paint, ml.text!, ml.textConfig);
            }
          });
        }
      });
    }
  }

  ///将一个"Y轴数据" 转换到角度范围
  ///如果轴类型为category 则返回角度的范围，否则返回单一角度
  List<num> dataToAngle(DynamicData data) {
    return scale.toRange(data.data);
  }
}
