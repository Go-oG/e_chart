import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import '../../model/node/split_area.dart';

///角度轴(是一个完整的环,类似于Y轴)
class AngleAxisImpl extends BaseAxisImpl<AngleAxis, AngleAxisAttrs> {
  static const int maxAngle = 360;

  AngleAxisImpl(super.context, super.axis, super.attrs);

  ///存储坐标轴相关的节点
  late List<CurveSegment> lineList = [];

  void updateAxisLines(List<CurveSegment> list) {
    lineList = list;
  }

  late List<CurveSplitLineNode> splitLineList = [];

  void updateSplitLines(List<CurveSplitLineNode> list) {
    splitLineList = list;
  }

  late List<SplitAreaNode> splitAreaList = [];

  void updateSplitAreas(List<SplitAreaNode> list) {
    splitAreaList = list;
  }

  late List<TickNode> tickList = [];

  void updateTicks(List<TickNode> list) {
    tickList = list;
  }

  late List<AxisLabelNode> labelList = [];

  void updateLabels(List<AxisLabelNode> list) {
    labelList = list;
  }

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
    return axis.toScale([s, e], dataSet, attrs.splitCount);
  }

  @override
  void onLayoutAxisLine(AngleAxisAttrs attrs, BaseScale scale) {}

  @override
  void onLayoutSplitLine(AngleAxisAttrs attrs, BaseScale scale) {
    var splitLine = axis.splitLine;
    if (!splitLine.show) {
      updateSplitAreas([]);
      return;
    }

    int count = scale.tickCount - 1;
    final int dir = attrs.clockwise ? 1 : -1;
    final num angleInterval = dir * maxAngle / count;
    List<CurveSplitLineNode> list = [];
    double ir = attrs.radius.length > 1 ? attrs.radius.first : 0;
    double or = attrs.radius.last;

    for (int i = 0; i < count; i++) {
      num sa = attrs.angleOffset + angleInterval * i;
      var data = [];
      var segment = CurveSplitLineNode(
        data,
        i,
        count,
        attrs.center,
        ir,
        or,
        sa,
        splitLine.getStyle(data, i, count, getAxisTheme()),
      );
      list.add(segment);
    }
    updateSplitLines(list);
  }

  @override
  void onLayoutSplitArea(AngleAxisAttrs attrs, BaseScale scale) {
    var splitArea = axis.splitArea;
    if (!splitArea.show) {
      updateSplitAreas([]);
      return;
    }

    int count = scale.tickCount - 1;
    final int dir = attrs.clockwise ? 1 : -1;
    final num angleInterval = dir * maxAngle / count;
    List<SplitAreaNode> list = [];
    double ir = attrs.radius.length > 1 ? attrs.radius.first : 0;
    double or = attrs.radius.last;

    for (int i = 0; i < count; i++) {
      num sa = attrs.angleOffset + angleInterval * i;
      var arc = Arc(
        startAngle: sa,
        sweepAngle: angleInterval,
        outRadius: or,
        innerRadius: ir,
        center: attrs.center,
      );
      list.add(SplitAreaNode([], arc.toPath(), splitArea.getStyle(i, count, getAxisTheme())));
    }
    updateSplitAreas(list);
  }

  @override
  void onLayoutAxisTick(AngleAxisAttrs attrs, BaseScale scale) {
    var axisTick = axis.axisTick;
    var tick = axisTick.tick;
    if (!axis.show || !axisTick.show || tick == null || !tick.show) {
      updateTicks([]);
      return;
    }
    var minorTick = axisTick.minorTick;

    int tickCount = scale.tickCount - 1;
    if (scale.isCategory) {
      tickCount = scale.domain.length;
    }

    final int dir = attrs.clockwise ? 1 : -1;
    final num angleInterval = dir * maxAngle / tickCount;
    List<TickNode> tickList = [];

    final int minorCount = minorTick?.splitNumber ?? 0;
    final minorInterval = angleInterval / minorCount;

    num r = attrs.radius.last;
    num minorR = attrs.radius.last;
    if (axis.axisTick.inside) {
      r -= tick.length;
      minorR -= axisTick.getMinorSize();
    } else {
      r += tick.length;
      minorR += axisTick.getMinorSize();
    }

    var tickStyle = tick.lineStyle;
    for (int i = 0; i < tickCount; i++) {
      num angle = attrs.angleOffset + angleInterval * i;
      Offset so = circlePoint(attrs.radius.last, angle, attrs.center);
      Offset eo = circlePoint(r, angle, attrs.center);
      List<TickNode> minorList = [];

      tickList.add(TickNode(scale.toData(angle), i, tickCount, so, eo, tickStyle, minorList));
      if (axis.isCategoryAxis || axis.isTimeAxis || i >= tickCount - 1) {
        continue;
      }
      if (minorTick == null || minorCount <= 0 || !minorTick.show) {
        continue;
      }

      for (int j = 1; j < minorTick.splitNumber; j++) {
        var minorAngle = angle + minorInterval * j;
        Offset minorSo = circlePoint(attrs.radius.last, angle + minorInterval * j, attrs.center);
        Offset minorEo = circlePoint(minorR, angle + minorInterval * j, attrs.center);
        minorList.add(TickNode(scale.toData(minorAngle), i, tickCount, minorSo, minorEo, minorTick.lineStyle));
      }
    }

    updateTicks(tickList);
  }

  @override
  void onLayoutAxisLabel(AngleAxisAttrs attrs, BaseScale scale) {
    var axisLabel = axis.axisLabel;
    if (!axisLabel.show) {
      updateLabels([]);
      return;
    }
    final labels = obtainLabel();
    final int labelCount = labels.length;
    if (labelCount <= 1) {
      updateLabels([]);
      return;
    }
    var axisTick = axis.axisTick;

    final int dir = attrs.clockwise ? 1 : -1;
    int count = scale.tickCount - 1;
    if (scale.isCategory) {
      count = labels.length;
    }

    final num angleInterval = dir * maxAngle / count;
    num r = attrs.radius.last;
    if (axisTick.inside == axisLabel.inside) {
      r += axisLabel.margin + axisLabel.padding;
    } else {
      if (axisLabel.inside) {
        r -= axisLabel.margin + axisLabel.padding;
      } else {
        r += axisLabel.margin + axisLabel.padding;
      }
    }
    List<AxisLabelNode> resultList = [];

    for (int i = 0; i < labels.length; i++) {
      DynamicText text = labels[i];
      num d = i;
      if (axis.isCategoryAxis) {
        d += 0.5;
      }
      num angle = attrs.angleOffset + angleInterval * d;
      Offset offset = circlePoint(r, angle, attrs.center);
      var labelStyle = axisLabel.getStyle(i, labels.length, getAxisTheme());
      var config = TextDraw(
        text,
        labelStyle,
        offset,
        align: toAlignment(angle, axisLabel.inside),
        rotate: axisLabel.rotate,
      );
      var result = AxisLabelNode(i, labels.length, config, []);
      resultList.add(result);
    }
    updateLabels(resultList);
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
  void onDrawAxisSplitArea(CCanvas canvas, Paint paint) {
    var splitArea = axis.splitArea;
    if (!splitArea.show) {
      return;
    }
    each(splitAreaList, (split, i) {
      split.draw(canvas, paint);
    });
  }

  @override
  void onDrawAxisSplitLine(CCanvas canvas, Paint paint) {
    var splitLine = axis.splitLine;
    if (!splitLine.show) {
      return;
    }
    each(splitLineList, (sp, i) {
      sp.draw(canvas, paint);
    });
  }

  @override
  void onDrawAxisLine(CCanvas canvas, Paint paint) {
    var axisLine = axis.axisLine;
    if (!axisLine.show) {
      return;
    }
    each(lineList, (line, index) {
      line.draw(canvas, paint);
    });
  }

  @override
  void onDrawAxisTick(CCanvas canvas, Paint paint) {
    var axisTick = axis.axisTick;
    if (!axisTick.show) {
      return;
    }
    each(tickList, (p0, p1) {
      p0.draw(canvas, paint);
    });
  }

  @override
  void onDrawAxisLabel(CCanvas canvas, Paint paint) {
    var axisLabel = axis.axisLabel;
    if (axisLabel.show) {
      each(labelList, (p0, p1) {
        p0.draw(canvas, paint);
      });
    }
  }

  final TextDraw _axisPointerTD = TextDraw(DynamicText.empty, LabelStyle.empty, Offset.zero);

  @override
  void onDrawAxisPointer(CCanvas canvas, Paint paint, Offset touchOffset) {
    var axisPointer = axis.axisPointer;
    if (axisPointer == null || !axisPointer.show) {
      return;
    }
    num dis = touchOffset.distance2(attrs.center);
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
      final angle = touchOffset.angle(attrs.center);
      ol = [attrs.center, circlePoint(dis, angle, attrs.center)];
    } else {
      ol = [attrs.center, touchOffset];
    }
    axisPointer.lineStyle.drawPolygon(canvas, paint, ol);

    ///绘制 数据
    dis = ol.last.distance2(ol.first);
    var dt = axis.formatData(scale.toData(dis));
    num angle = touchOffset.angle(attrs.center);
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
