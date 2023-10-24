import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///角度轴(是一个完整的环,类似于Y轴)
class AngleAxisImpl<C extends CoordLayout> extends BaseAxisImpl<AngleAxis, AngleAxisAttrs, AngleAxisLayoutResult, C> {
  static const int maxAngle = 360;

  AngleAxisImpl(super.context, super.coord, super.axis, {super.axisIndex});

  @override
  BaseScale onBuildScale(AngleAxisAttrs attrs, List<dynamic> dataSet) {
    num s = attrs.angleOffset;
    num e;
    if (attrs.clockwise) {
      e = s + maxAngle;
    } else {
      e = s - maxAngle;
    }
    if (axis.isCategoryAxis) {
      List<String> sl = List.from(axis.categoryList);
      if (sl.isEmpty) {
        Set<String> dSet = {};
        for (var data in dataSet) {
          if (data is String && !dSet.contains(data)) {
            sl.add(data);
            dSet.add(data);
          }
        }
      }
      if (sl.isEmpty) {
        throw ChartError('当前提取Category数目为0');
      }
      if (axis.inverse) {
        return CategoryScale(List.from(sl.reversed), [s, e], true);
      }
      return CategoryScale(sl, [s, e], true);
    }
    return BaseAxisImpl.toScale(axis, [s, e], dataSet, attrs.splitCount);
  }

  @override
  AngleAxisLayoutResult onLayout(AngleAxisAttrs attrs, BaseScale<dynamic, num> scale) {
    double ir = attrs.radius.length > 1 ? attrs.radius.first : 0;
    double or = attrs.radius.last;
    Arc arc = Arc(
      center: attrs.center,
      outRadius: or,
      innerRadius: ir,
      startAngle: attrs.angleOffset,
      sweepAngle: attrs.clockwise ? maxAngle : -maxAngle,
    );
    List<Arc> splitList = buildSplitArc(attrs, scale);
    List<TickResult> tickList = buildTickResult(attrs, scale);
    List<LabelResult> labelList = buildLabelResult(attrs, scale);
    return AngleAxisLayoutResult(arc, splitList, [], tickList, labelList);
  }

  ///返回分割区域
  List<Arc> buildSplitArc(AngleAxisAttrs attrs, BaseScale<dynamic, num> scale) {
    int count = scale.tickCount - 1;
    final int dir = attrs.clockwise ? 1 : -1;
    final num angleInterval = dir * maxAngle / count;
    List<Arc> list = [];
    double ir = attrs.radius.length > 1 ? attrs.radius.first : 0;
    double or = attrs.radius.last;

    for (int i = 0; i < count; i++) {
      num sa = attrs.angleOffset + angleInterval * i;
      Arc arc = Arc(
        startAngle: sa,
        sweepAngle: angleInterval,
        outRadius: or,
        innerRadius: ir,
        center: attrs.center,
      );
      list.add(arc);
    }
    return list;
  }

  ///返回所有的Tick
  List<TickResult> buildTickResult(AngleAxisAttrs attrs, BaseScale<dynamic, num> scale) {
    int tickCount = scale.tickCount - 1;
    if (scale.isCategory) {
      tickCount = scale.domain.length;
    }
    final int dir = attrs.clockwise ? 1 : -1;
    final num angleInterval = dir * maxAngle / tickCount;

    List<TickResult> tickList = [];

    MainTick tick = axis.axisTick.tick ?? BaseAxisImpl.tmpTick;
    MinorTick minorTick = axis.minorTick?.tick ?? BaseAxisImpl.tmpMinorTick;
    int minorSN = minorTick.splitNumber;
    if (minorSN < 0) {
      minorSN = 0;
    }
    num r = attrs.radius.last;
    num minorR = attrs.radius.last;
    if (tick.inside) {
      r -= tick.length;
      minorR -= minorTick.length;
    } else {
      r += tick.length;
      minorR += minorTick.length;
    }

    for (int i = 0; i < tickCount; i++) {
      num angle = attrs.angleOffset + angleInterval * i;
      Offset so = circlePoint(attrs.radius.last, angle, attrs.center);
      Offset eo = circlePoint(r, angle, attrs.center);
      List<TickResult> minorList = [];
      int oi = i * minorSN;
      tickList.add(TickResult(oi, i, tickCount, so, eo, minorList));
      if (axis.isCategoryAxis || axis.isTimeAxis || i == tickCount - 1) {
        continue;
      }
      if (minorTick.splitNumber <= 0) {
        continue;
      }
      int minorCount = minorTick.splitNumber;
      num minorInterval = angleInterval / minorCount;
      if (i >= tickCount - 1) {
        continue;
      }

      for (int j = 1; j < minorTick.splitNumber; j++) {
        Offset minorSo = circlePoint(attrs.radius.last, angle + minorInterval * j, attrs.center);
        Offset minorEo = circlePoint(minorR, angle + minorInterval * j, attrs.center);
        minorList.add(TickResult(oi + j, i, tickCount, minorSo, minorEo));
      }
    }
    return tickList;
  }

  ///返回所有的Label
  List<LabelResult> buildLabelResult(AngleAxisAttrs attrs, BaseScale<dynamic, num> scale) {
    List<DynamicText> labels = obtainLabel();
    if (labels.length <= 1) {
      return [];
    }

    final int dir = attrs.clockwise ? 1 : -1;
    int count = scale.tickCount - 1;
    if (scale.isCategory) {
      count = labels.length;
    }

    final num angleInterval = dir * maxAngle / count;
    MainTick tick = axis.axisTick.tick ?? BaseAxisImpl.tmpTick;
    MinorTick minorTick = axis.minorTick?.tick ?? BaseAxisImpl.tmpMinorTick;

    AxisLabel axisLabel = axis.axisLabel;
    num r = attrs.radius.last;
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

    for (int i = 0; i < labels.length; i++) {
      DynamicText text = labels[i];
      num d = i;
      if (axis.isCategoryAxis) {
        d += 0.5;
      }
      num angle = attrs.angleOffset + angleInterval * d;
      Offset offset = circlePoint(r, angle, attrs.center);

      var labelStyle = axis.getLabelStyle(i, labels.length, getAxisTheme());
      var config = TextDraw(
        text,
        labelStyle,
        offset,
        align: toAlignment(angle, axisLabel.inside),
        rotate: axisLabel.rotate,
      );
      var result = LabelResult(i, i, labels.length, config, []);
      resultList.add(result);
      if (axis.isCategoryAxis || axis.isTimeAxis) {
        continue;
      }

      int minorCount = minorTick.splitNumber;
      if (minorCount <= 0 || scale.isCategory || scale.isTime) {
        continue;
      }

      ///构建minorLabel
      var minorStyle = axis.getMinorLabelStyle(i, labels.length, getAxisTheme());
      double minorInterval = angleInterval / (minorCount + 1);
      for (int j = 1; j <= minorTick.splitNumber; j++) {
        num childAngle = angle + minorInterval * j;
        dynamic data = scale.toData(childAngle);
        var text = axisLabel.formatter?.call(data) ?? DynamicText.empty;
        final labelOffset = circlePoint(r, childAngle, attrs.center);
        var minorConfig = TextDraw(
          text,
          minorStyle,
          labelOffset,
          align: toAlignment(childAngle, axisLabel.inside),
          rotate: axisLabel.rotate,
        );
        result.minorLabel.add(LabelResult(i + j, i, labels.length, minorConfig));
      }
    }
    return resultList;
  }

  @override
  TextDraw onLayoutAxisName() {
    var label = titleNode.name?.name ?? DynamicText.empty;
    Offset start = attrs.center;
    Offset end = circlePoint(attrs.radius.last, attrs.angleOffset, attrs.center);
    var axisName = axis.axisName;
    var align = axisName?.align ?? Align2.end;
    var style = axisName?.labelStyle ?? const LabelStyle();
    if (align == Align2.center || label.isEmpty) {
      return TextDraw(label, style, Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2),
          align: Alignment.center, rotate: axisName?.rotate ?? 0);
    }
    if (align == Align2.start) {
      return TextDraw(label, style, start, align: Alignment.centerLeft, rotate: axisName?.rotate ?? 0);
    }
    return TextDraw(
      label,
      style,
      end,
      align: toAlignment(end.angle(start)),
      rotate: axisName?.rotate ?? 0,
    );
  }

  @override
  void onDrawAxisSplitArea(CCanvas canvas, Paint paint, Offset scroll) {
    var splitArea = axis.splitArea;
    if (splitArea != null && !splitArea.show) {
      return;
    }
    var theme = getAxisTheme();
    if (splitArea == null && !theme.showSplitArea) {
      return;
    }

    int maxCount = layoutResult.splitList.length;
    each(layoutResult.splitList, (split, i) {
      var style = axis.getSplitAreaStyle(i, maxCount, theme);
      style?.drawArc(canvas, paint, split);
    });
  }

  @override
  void onDrawAxisSplitLine(CCanvas canvas, Paint paint, Offset scroll) {
    var theme = getAxisTheme();
    var splitLine = axis.splitLine;
    if (!splitLine.show) {
      return;
    }
    int maxCount = layoutResult.splitList.length;
    each(layoutResult.splitList, (arc, i) {
      LineStyle? style = axis.getSplitLineStyle(i, maxCount, theme);
      if (style != null) {
        Offset end = circlePoint(arc.outRadius, arc.startAngle, arc.center);
        Offset start = arc.innerRadius <= 0 ? attrs.center : circlePoint(arc.innerRadius, arc.startAngle, arc.center);
        style.drawPolygon(canvas, paint, [start, end]);
      }
    });
  }

  @override
  void onDrawAxisLine(CCanvas canvas, Paint paint, Offset scroll) {
    var axisLine = axis.axisLine;
    if (!axisLine.show) {
      return;
    }
    var theme = getAxisTheme();
    int maxCount = layoutResult.splitList.length;
    each(layoutResult.splitList, (arc, index) {
      var s = axisLine.getAxisLineStyle(index, maxCount, theme);
      s?.drawPath(canvas, paint, arc.arcOpen(), drawDash: true, needSplit: false);
    });
  }

  @override
  void onDrawAxisTick(CCanvas canvas, Paint paint, Offset scroll) {
    var theme = getAxisTheme();
    var axisTick = axis.axisTick;
    if (!axisTick.show) {
      return;
    }
    int maxCount = layoutResult.tick.length;
    each(layoutResult.tick, (result, i) {
      MainTick? tick = axis.getMainTick(i, maxCount, theme);
      var minorTick = axis.getMinorTick(i, maxCount, theme);
      bool b1 = (tick != null && tick.show);
      bool b2 = (minorTick != null && minorTick.show);
      if (b1) {
        int interval = tick.interval;
        if (!(interval > 0 && result.originIndex != 0 && (result.originIndex % interval) == 0)) {
          tick.lineStyle.drawPolygon(canvas, paint, [result.start, result.end]);
        }
      }

      if (b2) {
        int interval = minorTick.interval;
        each(result.minorTickList, (mr, j) {
          if (interval > 0 && mr.originIndex != 0 && (mr.originIndex % interval) == 0) {
            return;
          }
          minorTick.lineStyle.drawPolygon(canvas, paint, [mr.start, mr.end]);
        });
      }
    });
  }

  @override
  void onDrawAxisLabel(CCanvas canvas, Paint paint, Offset scroll) {
    var axisLabel = axis.axisLabel;
    if (axisLabel.show) {
      int maxCount = layoutResult.label.length;
      each(layoutResult.label, (label, i) {
        var labelStyle = label.textConfig.style;
        if (labelStyle.show && (axis.isCategoryAxis || i != maxCount - 1)) {
          label.textConfig.draw(canvas, paint);
        }

        if (label.minorLabel.isNotEmpty && label.minorLabel.first.textConfig.style.show) {
          each(label.minorLabel, (ml, i) {
            ml.textConfig.draw(canvas, paint);
          });
        }
      });
    }
  }

  final TextDraw _axisPointerTD = TextDraw(DynamicText.empty, LabelStyle.empty, Offset.zero);

  @override
  void onDrawAxisPointer(CCanvas canvas, Paint paint, Offset offset) {
    var axisPointer = axis.axisPointer;
    if (axisPointer == null || !axisPointer.show) {
      return;
    }
    num dis = offset.distance2(attrs.center);
    var ir = attrs.radius.length > 1 ? attrs.radius[0] : 0;
    var or = attrs.radius.last;
    if (dis <= ir || dis >= or) {
      return;
    }
    if (dis <= 0 || dis > attrs.radius.last) {
      return;
    }
    bool snap = axisPointer.snap ?? (axis.isCategoryAxis || axis.isTimeAxis);
    List<Offset> ol;
    if (snap) {
      double interval = scale.tickInterval.toDouble();
      int c = dis ~/ interval;
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
        dis = c * interval;
      }
      final angle = offset.angle(attrs.center);
      ol = [attrs.center, circlePoint(dis, angle, attrs.center)];
    } else {
      ol = [attrs.center, offset];
    }
    axisPointer.lineStyle.drawPolygon(canvas, paint, ol);

    ///绘制 数据
    dis = ol.last.distance2(ol.first);
    var dt = formatData(scale.toData(dis));
    num angle = offset.angle(attrs.center);
    var o = circlePoint(attrs.radius.last, angle, attrs.center);

    if (_axisPointerTD.text != dt ||
        _axisPointerTD.offset != o ||
        _axisPointerTD.align != toAlignment(angle, axis.axisLabel.inside)) {
      _axisPointerTD.updatePainter(
        offset: o,
        text: dt,
        style: axisPointer.labelStyle,
        align: toAlignment(angle, axis.axisLabel.inside),
      );
    }
    _axisPointerTD.draw(canvas, paint);
  }

  ///将一个"Y轴数据" 转换到角度范围
  ///如果轴类型为category 则返回角度的范围，否则返回单一角度
  List<num> dataToAngle(dynamic data) {
    checkDataType(data);
    return scale.toRange(data);
  }

  @override
  void dispose() {
    _axisPointerTD.dispose();
    super.dispose();
  }
}
