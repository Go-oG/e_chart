import 'dart:math';
import 'package:e_chart/src/ext/index.dart';
import 'package:flutter/material.dart';

import '../../../core/render/ccanvas.dart';
import '../../../model/index.dart';
import '../../../utils/index.dart';
import '../../index.dart';

class LineAxisImpl<T extends BaseAxis, P extends LineAxisAttrs> extends BaseAxisImpl<T, P, LineAxisPainter> {
  LineAxisImpl(super.context, super.axis, super.attrs);

  @override
  void onAttrsChange(P oldAttrs) {
    if (oldAttrs.rect != attrs.rect || oldAttrs.start != attrs.start || oldAttrs.end != attrs.end) {
      super.onAttrsChange(attrs);
      return;
    }
    if (oldAttrs.scaleRatio != attrs.scaleRatio) {
      scale = onBuildScale(attrs, scale.domain);
      axisPainter = onLayout(attrs, scale);
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

  @override
  LineAxisPainter onLayout(P attrs, BaseScale<dynamic, num> scale) {
    num viewSize = attrs.start.distance2(attrs.end);
    final double distance = attrs.distance;

    ///夹角
    final angle = attrs.end.angle(attrs.start);
    final Offset end = circlePoint(distance, angle, attrs.start);
    List<LinePainter> lineResult = onBuildLineResult(scale, attrs.start, distance, angle);
    List<TickPainter> tickResult = onBuildTickResult(scale, attrs.start, distance, angle);
    List<LineSplitResult> splitResult = onBuildSplitResult(tickResult, attrs.start);
    List<LabelPainter> labelResult = onBuildLabelResult(scale, attrs.start, distance, angle);
    return LineAxisPainter(viewSize, attrs.start, end, splitResult, lineResult, tickResult, labelResult);
  }

  List<LinePainter> onBuildLineResult(BaseScale<dynamic, num> scale, Offset center, double distance, double angle) {
    int tickCount = scale.tickCount;
    if (tickCount <= 0) {
      tickCount = 1;
    }
    final double interval = scale.tickInterval.toDouble();
    List<LinePainter> resultList = [];
    for (int i = 0; i < tickCount - 1; i++) {
      Offset offset = center.translate(interval * i, 0);
      Offset start = offset.rotate(angle, center: center);
      Offset end = center.translate(interval * (i + 1), 0).rotate(angle, center: center);
      resultList.add(LinePainter(i, tickCount - 1, start, end));
    }
    return resultList;
  }

  List<TickPainter> onBuildTickResult(BaseScale<dynamic, num> scale, Offset center, double distance, double angle) {
    int tickCount = scale.tickCount;
    if (tickCount <= 0) {
      tickCount = 1;
    }
    final double interval = distance / (tickCount - 1);
    var tick = axis.axisTick.tick ?? BaseAxisImpl.tmpTick;
    var minorTick = axis.axisTick.minorTick ?? BaseAxisImpl.tmpMinorTick;
    final double tickOffset = (axis.axisTick.inside ? -tick.length : tick.length).toDouble();
    final double minorOffset = (axis.axisTick.inside ? -minorTick.length : minorTick.length).toDouble();
    int minorSN = minorTick.splitNumber;
    if (minorSN < 0) {
      minorSN = 0;
    }

    List<TickPainter> resultList = [];
    for (int i = 0; i < tickCount; i++) {
      Offset offset = center.translate(interval * i, 0);
      Offset start = offset.rotate(angle, center: center);
      Offset end = offset.translate(0, tickOffset).rotate(angle, center: center);
      var data = scale.toData(interval * i);
      TickPainter result = TickPainter(data, i, tickCount, start, end, []);
      resultList.add(result);

      int minorCount = minorTick.splitNumber;
      if (minorCount <= 0) {
        continue;
      }
      double minorInterval = interval / (minorCount + 1);
      for (int j = 1; j <= minorTick.splitNumber; j++) {
        Offset ms = offset.translate(minorInterval * j, 0);
        Offset me = ms.translate(0, minorOffset);
        var data = scale.toData(minorInterval * j + interval * i);
        ms = ms.rotate(angle, center: center);
        me = me.rotate(angle, center: center);
        result.minorList.add(TickPainter(data, i, tickCount, ms, me));
      }
    }
    return resultList;
  }

  List<LabelPainter> onBuildLabelResult(BaseScale<dynamic, num> scale, Offset center, double distance, double angle) {
    int tickCount = scale.tickCount;
    if (tickCount <= 0) {
      tickCount = 1;
    }
    final double interval = distance / (tickCount - 1);
    MainTick tick = axis.axisTick.tick ?? BaseAxisImpl.tmpTick;
    MinorTick minorTick = axis.axisTick.minorTick ?? BaseAxisImpl.tmpMinorTick;
    AxisLabel axisLabel = axis.axisLabel;
    List<DynamicText> labels = obtainLabel();
    double labelOffset = axisLabel.padding + axisLabel.margin + 0;
    if (axisLabel.inside == axis.axisTick.inside) {
      labelOffset += tick.length;
    }
    labelOffset *= axisLabel.inside ? -1 : 1;
    List<LabelPainter> resultList = [];
    for (int i = 0; i < tickCount; i++) {
      double d = i.toDouble();
      if (scale.isCategory && axis.categoryCenter) {
        d += 0.5;
      }
      DynamicText? text;
      if (labels.length > i) {
        text = labels[i];
      }
      final double parenDis = interval * d;
      Offset offset = center.translate(parenDis, 0);
      Offset textOffset = offset.translate(0, labelOffset);
      textOffset = textOffset.rotate(angle, center: center);
      var ls = axisLabel.getStyle(i, tickCount, getAxisTheme());
      var config = TextDraw(
        text ?? DynamicText.empty,
        ls,
        textOffset,
        align: toAlignment(angle + 90, axisLabel.inside),
        rotate: axisLabel.rotate,
      );

      var result = LabelPainter(i, i, tickCount, config, []);
      resultList.add(result);

      int minorCount = minorTick.splitNumber;
      if (minorCount <= 0 || scale.isCategory || scale.isTime) {
        continue;
      }

      ///构建minorLabel
      var minorLS = axisLabel.getMinorStyle(i, tickCount, getAxisTheme());
      double minorInterval = interval / (minorCount + 1);
      for (int j = 1; j <= minorTick.splitNumber; j++) {
        num dis = parenDis + minorInterval * j;
        final labelOffset = circlePoint(dis, angle, center);

        dynamic data = scale.toData(dis);
        var text = axisLabel.formatter?.call(data) ?? DynamicText.empty;
        var minorConfig = TextDraw(
          text,
          minorLS,
          labelOffset,
          align: toAlignment(angle + 90, axisLabel.inside),
          rotate: axisLabel.rotate,
        );
        result.minorLabel.add(LabelPainter(i + j, i, tickCount, minorConfig));
      }
    }

    return resultList;
  }

  List<LineSplitResult> onBuildSplitResult(List<TickPainter> tickResult, Offset center) {
    List<LineSplitResult> resultList = [];
    int c = tickResult.length - 1;
    for (int i = 0; i < c; i++) {
      var pre = tickResult[i];
      var next = tickResult[i + 1];
      var result = LineSplitResult(pre.data, pre.index, pre.maxIndex - 1, center, pre.start, next.start);
      resultList.add(result);
    }
    return resultList;
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
    AxisTheme theme = getAxisTheme();
    canvas.save();
    canvas.translate(attrs.scrollX, attrs.scrollY);
    axisPainter.drawLine(canvas, paint, axis.axisLine.getStyle(theme));
    canvas.restore();
  }

  @override
  void onDrawAxisTick(CCanvas canvas, Paint paint) {
    canvas.save();
    canvas.translate(attrs.scrollX, attrs.scrollY);
    axisPainter.drawTick(canvas, paint, axis.axisTick.tick, axis.axisTick.minorTick);
    canvas.restore();
  }

  @override
  void onDrawAxisLabel(CCanvas canvas, Paint paint) {
    canvas.save();
    canvas.translate(attrs.scrollX, attrs.scrollY);
    axisPainter.drawLabel(canvas, paint, axis.axisLabel.interval);
    canvas.restore();
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
