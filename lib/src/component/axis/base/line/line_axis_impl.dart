import 'dart:math';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import '../../model/node/split_area.dart';
import 'line_attrs.dart';

abstract class LineAxisImpl<T extends BaseAxis, P extends LineAxisAttrs> extends BaseAxisImpl<T, P> {
  LineAxisImpl(super.context, super.axis, super.attrs);

  ///存储坐标轴相关的节点
  late List<LineSegment> lineList = [];

  void updateAxisLines(List<LineSegment> list) {
    lineList = list;
  }

  late List<LineSegment> splitLineList = [];

  void updateSplitLines(List<LineSegment> list) {
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
  void onAttrsChange(P oldAttrs) {
    if (oldAttrs.rect != attrs.rect || oldAttrs.start != attrs.start || oldAttrs.end != attrs.end) {
      super.onAttrsChange(attrs);
      return;
    }
    if (oldAttrs.scaleRatio != attrs.scaleRatio) {
      scale = onBuildScale(attrs, scale.domain);
      onLayout(attrs, scale);
    }
  }

  @override
  BaseScale onBuildScale(P attrs, List<dynamic> dataSet) {
    num distance = attrs.distance;
    if (distance.isNaN || distance.isInfinite) {
      throw ChartError('$runtimeType 长度未知：$distance');
    }
    return axis.toScale([0, distance], dataSet, attrs.splitCount, attrs.scaleRatio);
  }

  ///返回坐标轴的映射长度
  double get axisLength => attrs.distance;

  ///返回坐标轴的夹角
  ///夹角为轴线与轴线起点水平方向的夹角
  double get axisAngle => attrs.end.angle(attrs.start);

  @override
  void onLayoutAxisLine(P attrs, BaseScale<dynamic, num> scale) {
    var axisLine = axis.axisLine;
    if (!axisLine.show) {
      updateAxisLines([]);
      return;
    }

    var lineStyle = axisLine.getStyle(getAxisTheme());

    int tickCount = scale.tickCount;
    if (tickCount <= 0) {
      tickCount = 1;
    }
    final double interval = scale.tickInterval.toDouble();
    List<LineSegment> resultList = [];
    var angle = axisAngle;
    final int maxCount = tickCount - 1;
    for (int i = 0; i < maxCount; i++) {
      var dis = interval * i;
      var nextDis = dis + interval;
      var offset = attrs.start.translate(dis, 0);
      var start = offset.rotate(angle, center: attrs.start);
      var startData = scale.toData(dis);
      var end = attrs.start.translate(nextDis, 0).rotate(angle, center: attrs.start);
      var endData = scale.toData(nextDis);
      resultList.add(LineSegment([startData, endData], i, maxCount, start, end, lineStyle));
    }
    updateAxisLines(resultList);
  }

  @override
  void onLayoutAxisTick(P attrs, BaseScale<dynamic, num> scale) {
    var axisTick = axis.axisTick;
    var tick = axisTick.tick;
    if (!axisTick.show || (tick == null || !tick.show)) {
      updateTicks([]);
      return;
    }

    var minorTick = axisTick.minorTick;

    int tickCount = scale.tickCount;
    if (tickCount <= 0) {
      tickCount = 1;
    }

    final double interval = scale.tickInterval;
    final int insideDir = axisTick.inside ? -1 : 1;
    final double tickOffset = axisTick.getTickSize() * insideDir;
    final double minorOffset = axisTick.getMinorSize() * insideDir;
    final minorCount = minorTick?.splitNumber ?? 0;
    final double minorInterval = minorCount <= 0 ? 0 : (interval / (minorCount + 1));

    List<TickNode> resultList = [];
    final center = attrs.start;
    final angle = axisAngle;

    for (int i = 0; i < tickCount; i++) {
      var dis = interval * i;
      final offset = center.translate(dis, 0);
      var start = offset.rotate(angle, center: center);
      var end = offset.translate(0, tickOffset).rotate(angle, center: center);
      var data = scale.toData(dis);
      var tickNode = TickNode(data, i, tickCount, start, end, tick.lineStyle, []);
      resultList.add(tickNode);
      if (minorCount <= 0 || minorTick == null || !minorTick.show) {
        continue;
      }
      for (int j = 1; j < minorCount; j++) {
        var dis2 = minorInterval * j;
        var ms = offset.translate(dis2, 0);
        var me = ms.translate(0, minorOffset);
        var data = scale.toData(dis2 + dis);
        ms = ms.rotate(angle, center: center);
        me = me.rotate(angle, center: center);
        tickNode.minorList.add(TickNode(data, i, tickCount, ms, me, minorTick.lineStyle));
      }
    }
    updateTicks(resultList);
  }

  @override
  void onLayoutAxisLabel(P attrs, BaseScale<dynamic, num> scale) {
    var axisLabel = axis.axisLabel;
    if (!axisLabel.show) {
      updateLabels([]);
      return;
    }
    final labels = obtainLabel();
    final int labelCount = labels.length;
    if (labelCount <= 0) {
      updateLabels([]);
      return;
    }

    var axisTick = axis.axisTick;
    final tickSize = axisTick.getMaxTickSize();

    ///计算 Label偏移量
    double labelOffset = axisLabel.padding + axisLabel.margin + 0;
    if (axisLabel.inside == axisTick.inside) {
      labelOffset += tickSize;
    }
    labelOffset *= axisLabel.inside ? -1 : 1;

    List<AxisLabelNode> resultList = [];
    final center = attrs.start;
    final angle = axisAngle;

    double labelInterval = axisLength / (labelCount - 1);
    double startOffset = 0;
    if (axis.isCategoryAxis && axis.categoryCenter) {
      labelInterval = axisLength / labelCount;
      startOffset = labelInterval * 0.5;
    }

    each(labels, (label, i) {
      final double dis = startOffset + i * labelInterval;
      final offset = center.translate(dis, 0);
      var textOffset = offset.translate(0, labelOffset).rotate(angle, center: center);

      var ls = axisLabel.getStyle(i, labelCount, getAxisTheme());
      var config = TextDraw(
        label,
        ls,
        textOffset,
        align: toAlignment(angle + 90, axisLabel.inside),
        rotate: axisLabel.rotate,
      );
      var result = AxisLabelNode(i, labelCount, config, []);
      resultList.add(result);
      // ///构建minorLabel
      // var minorLS = axisLabel.getMinorStyle(i, tickCount, getAxisTheme());
      // double minorInterval = interval / (minorCount + 1);
      // for (int j = 1; j <= minorTick.splitNumber; j++) {
      //   num dis = parenDis + minorInterval * j;
      //   final labelOffset = circlePoint(dis, angle, center);
      //
      //   dynamic data = scale.toData(dis);
      //   var text = axisLabel.formatter?.call(data) ?? DynamicText.empty;
      //   var minorConfig = TextDraw(
      //     text,
      //     minorLS,
      //     labelOffset,
      //     align: toAlignment(angle + 90, axisLabel.inside),
      //     rotate: axisLabel.rotate,
      //   );
      //   result.minorLabel.add(AxisLabelNode(i, tickCount, minorConfig));
      // }
    });

    updateLabels(resultList);
  }

  @override
  TextDraw onLayoutAxisName() {
    Offset center;
    Offset p;
    var align = axis.axisName?.align ?? Align2.end;
    if (align == Align2.end) {
      center = attrs.start;
      p = attrs.end;
    } else if (align == Align2.start) {
      center = attrs.end;
      p = attrs.start;
    } else {
      center = attrs.start;
      p = Offset((attrs.start.dx + attrs.end.dx) / 2, (attrs.start.dy + attrs.end.dy) / 2);
    }
    num a = p.angle(center);
    double r = center.distance2(p);
    r += axis.axisName?.nameGap ?? 0;
    var label = axis.axisName?.name ?? DynamicText.empty;
    var s = axis.axisName?.labelStyle ?? const LabelStyle();
    return TextDraw(label, s, circlePoint(r, a, center), align: toAlignment(a));
  }

  @override
  void onDrawAxisLine(CCanvas canvas, Paint paint) {
    each(lineList, (line, p1) {
      line.draw(canvas, paint);
    });
  }

  @override
  void onDrawAxisTick(CCanvas canvas, Paint paint) {
    each(tickList, (tick, p1) {
      tick.draw(canvas, paint);
    });
  }

  @override
  void onDrawAxisLabel(CCanvas canvas, Paint paint) {
    each(labelList, (label, p1) {
      label.draw(canvas, paint);
    });
  }

  @override
  void onDrawAxisSplitLine(CCanvas canvas, Paint paint) {
    each(splitLineList, (p0, p1) {
      p0.draw(canvas, paint);
    });
  }

  @override
  void onDrawAxisSplitArea(CCanvas canvas, Paint paint) {
    each(splitAreaList, (p0, p1) {
      p0.draw(canvas, paint);
    });
  }

  List<Offset> dataToPoint(dynamic data) {
    checkDataType(data);
    double diffY = attrs.end.dy - attrs.start.dy;
    double diffX = attrs.end.dx - attrs.start.dx;
    double at = atan2(diffY, diffX);
    List<num> nl = scale.toRange(data);
    List<Offset> ol = [];
    for (var d in nl) {
      double x = attrs.start.dx + d * cos(at);
      double y = attrs.start.dy + d * sin(at);
      ol.add(Offset(x, y));
    }
    return ol;
  }

  double getLength() {
    return attrs.distance;
  }
}
