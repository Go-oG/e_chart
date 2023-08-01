import 'dart:math';
import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/src/ext/index.dart';
import 'package:flutter/material.dart';

import '../../../coord/coord_impl.dart';
import '../../../model/index.dart';
import '../../../style/index.dart';
import '../../../utils/index.dart';
import '../../index.dart';

class LineAxisImpl<T extends BaseAxis, P extends LineAxisAttrs, C extends CoordLayout> extends BaseAxisImpl<T, P, LineAxisLayoutResult, C> {
  final tmpTick = MainTick();
  final MinorTick tmpMinorTick = MinorTick();

  LineAxisImpl(super.context, super.coord, super.axis, {super.axisIndex = 0});

  @override
  void onAttrsChange(P attrs) {
    var old = this.attrs;
    this.attrs = attrs;
    if (old.rect != attrs.rect || old.start != attrs.start || old.end != attrs.end) {
      super.onAttrsChange(attrs);
      return;
    }
    if (old.scaleRatio != attrs.scaleRatio) {
      List<DynamicData> dl = [];
      for (var data in scale.domain) {
        if (data is DynamicData) {
          dl.add(data);
        } else {
          dl.add(DynamicData(data));
        }
      }
      scale = onBuildScale(attrs, dl);
      layoutResult = onLayout(attrs, scale);
    }
  }

  @override
  BaseScale onBuildScale(P attrs, List<DynamicData> dataSet) {
    num distance = attrs.distance;
    if (distance.isNaN || distance.isInfinite) {
      throw ChartError('$runtimeType 长度未知：$distance');
    }
    return BaseAxisImpl.toScale(axis, [0, distance], dataSet, attrs.splitCount, attrs.scaleRatio);
  }

  @override
  LineAxisLayoutResult onLayout(P attrs, BaseScale<dynamic, num> scale) {
    num viewSize = attrs.start.distance2(attrs.end);
    final double distance = attrs.distance;

    ///夹角
    final angle = attrs.end.offsetAngle(attrs.start);
    final Offset end = circlePoint(distance, angle, attrs.start);
    List<TickResult> tickResult = onBuildTickResult(scale, attrs.start, distance, angle);
    List<LineSplitResult> splitResult = onBuildSplitResult(tickResult, attrs.start);
    List<LabelResult> labelResult = onBuildLabelResult(attrs, scale, attrs.start, distance, angle);
    return LineAxisLayoutResult(viewSize, attrs.start, end, splitResult, tickResult, labelResult);
  }

  List<TickResult> onBuildTickResult(BaseScale<dynamic, num> scale, Offset center, double distance, double angle) {
    int tickCount = scale.tickCount;
    if (tickCount <= 0) {
      tickCount = 1;
    }

    final double interval = distance / (tickCount - 1);

    MainTick tick = axis.axisStyle.axisTick.tick ?? tmpTick;
    MinorTick minorTick = axis.axisStyle.minorTick?.tick ?? tmpMinorTick;
    final double tickOffset = (tick.inside ? -tick.length : tick.length).toDouble();
    final double minorOffset = (tick.inside ? -minorTick.length : minorTick.length).toDouble();
    int minorSN = minorTick.splitNumber;
    if (minorSN < 0) {
      minorSN = 0;
    }

    List<TickResult> resultList = [];
    for (int i = 0; i < tickCount; i++) {
      Offset offset = center.translate(interval * i, 0);
      Offset start = offset.rotateOffset(angle, center: center);
      Offset end = offset.translate(0, tickOffset).rotateOffset(angle, center: center);
      int oi = i * minorSN;
      TickResult result = TickResult(oi, i, tickCount, start, end, []);
      resultList.add(result);

      int minorCount = minorTick.splitNumber;
      if (minorCount <= 0) {
        continue;
      }
      double minorInterval = interval / (minorCount + 1);
      for (int j = 1; j <= minorTick.splitNumber; j++) {
        Offset ms = offset.translate(minorInterval * j, 0);
        Offset me = ms.translate(0, minorOffset);

        ms = ms.rotateOffset(angle, center: center);
        me = me.rotateOffset(angle, center: center);
        result.minorTickList.add(TickResult(oi + j, i, tickCount, ms, me));
      }
    }
    return resultList;
  }

  List<LineSplitResult> onBuildSplitResult(List<TickResult> tickResult, Offset center) {
    List<LineSplitResult> resultList = [];
    int c = tickResult.length - 1;
    for (int i = 0; i < c; i++) {
      TickResult pre = tickResult[i];
      TickResult next = tickResult[i + 1];
      LineSplitResult result = LineSplitResult(pre.index, pre.maxIndex - 1, center, pre.start, next.start);
      resultList.add(result);
    }
    return resultList;
  }

  List<LabelResult> onBuildLabelResult(P attrs, BaseScale<dynamic, num> scale, Offset center, double distance, double angle) {
    int tickCount = scale.tickCount;
    if (tickCount <= 0) {
      tickCount = 1;
    }
    final double interval = distance / (tickCount - 1);
    MainTick tick = axis.axisStyle.axisTick.tick ?? tmpTick;
    MinorTick minorTick = axis.axisStyle.minorTick?.tick ?? tmpMinorTick;

    AxisLabel axisLabel = axis.axisStyle.axisLabel;

    List<DynamicText> labels = obtainLabel();

    double labelOffset = axisLabel.padding + axisLabel.margin + 0;
    if (axisLabel.inside == tick.inside) {
      labelOffset += tick.length;
    }
    labelOffset *= axisLabel.inside ? -1 : 1;
    List<LabelResult> resultList = [];
    for (int i = 0; i < tickCount; i++) {
      double d = i.toDouble();
      if (scale.isCategory && axis.categoryCenter) {
        d += 0.5;
      }
      final double parenDis = interval * d;

      Offset offset = center.translate(parenDis, 0);
      Offset textOffset = offset.translate(0, labelOffset);
      textOffset = textOffset.rotateOffset(angle, center: center);
      TextDrawConfig config = TextDrawConfig(textOffset, align: toAlignment(angle + 90, axisLabel.inside));
      DynamicText? text;
      if (labels.length > i) {
        text = labels[i];
      }

      LabelResult result = LabelResult(i, i, tickCount, config, text, []);
      resultList.add(result);

      int minorCount = minorTick.splitNumber;
      if (minorCount <= 0 || scale.isCategory || scale.isTime) {
        continue;
      }

      ///构建minorLabel
      double minorInterval = interval / (minorCount + 1);
      for (int j = 1; j <= minorTick.splitNumber; j++) {
        num dis = parenDis + minorInterval * j;
        final labelOffset = circlePoint(dis, angle, center);
        TextDrawConfig minorConfig = TextDrawConfig(labelOffset, align: toAlignment(angle + 90, axisLabel.inside));
        dynamic data = scale.toData(dis);
        DynamicText? text = axisLabel.formatter?.call(data);
        result.minorLabel.add(LabelResult(i + j, i, tickCount, minorConfig, text));
      }
    }
    return resultList;
  }

  @override
  TextDrawConfig onLayoutAxisName() {
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

    num a = p.offsetAngle(center);
    double r = center.distance2(p);
    r += axis.axisName?.nameGap ?? 0;
    return TextDrawConfig(circlePoint(r, a, center), align: toAlignment(a));
  }

  @override
  void onDrawAxisLine(Canvas canvas, Paint paint, Offset scroll) {
    var axisStyle = axis.axisStyle;
    AxisTheme theme = getAxisTheme();
    int c = layoutResult.split.length;
    canvas.save();
    canvas.translate(scroll.dx, scroll.dy);
    each(layoutResult.split, (split, i) {
      LineStyle? style = axisStyle.getAxisLineStyle(i, c, theme);
      style?.drawPolygon(canvas, paint, [split.start, split.end]);
    });
    canvas.restore();
  }

  @override
  void onDrawAxisTick(Canvas canvas, Paint paint, Offset scroll) {
    var axisStyle = axis.axisStyle;
    var theme = getAxisTheme();
    int maxCount = layoutResult.tick.length;
    canvas.save();
    canvas.translate(scroll.dx, scroll.dy);
    each(layoutResult.tick, (line, i) {
      MainTick? tick = axisStyle.getMainTick(i, maxCount, theme);
      bool b1 = (tick != null && tick.show);
      var minorTick = axisStyle.getMinorTick(i, maxCount, theme);
      bool b2 = (minorTick != null && minorTick.show);
      if (b1) {
        tick.lineStyle.drawPolygon(canvas, paint, [line.start, line.end]);
      }
      if (b2) {
        each(line.minorTickList, (at, p2) {
          minorTick.lineStyle.drawPolygon(canvas, paint, [at.start, at.end]);
        });
      }
    });
    canvas.restore();
  }

  @override
  void onDrawAxisLabel(Canvas canvas, Paint paint, Offset scroll) {
    var axisStyle = axis.axisStyle;
    var theme = getAxisTheme();
    int maxCount = layoutResult.label.length;
    canvas.save();
    canvas.translate(scroll.dx, scroll.dy);
    each(layoutResult.label, (label, i) {
      var labelStyle = axisStyle.getLabelStyle(i, maxCount, theme);
      var minorStyle = axisStyle.getMinorLabelStyle(i, maxCount, theme);
      bool b1 = (labelStyle != null && labelStyle.show);
      bool b2 = (minorStyle != null && minorStyle.show);
      if (b1 && label.text != null) {
        labelStyle.draw(canvas, paint, label.text!, label.textConfig);
      }
      if (b2) {
        each(label.minorLabel, (minor, p1) {
          if (minor.text != null) {
            minorStyle.draw(canvas, paint, minor.text!, minor.textConfig);
          }
        });
      }
    });
    canvas.restore();
  }

  List<Offset> dataToPoint(DynamicData data) {
    double diffY = attrs.end.dy - attrs.start.dy;
    double diffX = attrs.end.dx - attrs.start.dx;
    double at = atan2(diffY, diffX);
    List<num> nl = scale.toRange(data.data);
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
