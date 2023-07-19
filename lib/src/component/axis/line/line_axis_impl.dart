import 'dart:math';
import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/src/ext/index.dart';

import 'package:flutter/material.dart';

import '../../../model/index.dart';
import '../../../style/index.dart';
import '../../../utils/index.dart';
import '../../index.dart';

class LineAxisImpl<T extends BaseAxis, P extends LineAxisAttrs> extends BaseAxisImpl<T, P, LineAxisLayoutResult> {
  final tmpTick = MainTick();
  final MinorTick tmpMinorTick = MinorTick();

  LineAxisImpl(super.context, super.axis, {super.axisIndex = 0});

  double _scaleFactor = 1;

  double get scaleFactor => _scaleFactor;

  double _scrollOffset = 0;

  double get scrollOffset => _scrollOffset;

  void updateScaleFactor(num v) {
    if (v <= 0) {
      throw ChartError('scaleFactor 必须大于0 当前值：$v');
    }
    if (_scaleFactor == v) {
      return;
    }
    _scaleFactor = v.toDouble();
    onScaleFactorChange(_scaleFactor);
  }

  void updateScrollOffset(num v) {
    if (_scrollOffset == v) {
      return;
    }
    _scrollOffset = v.toDouble();
    onScrollOffsetChange(_scrollOffset);
  }

  @override
  BaseScale onBuildScale(P attrs, List<DynamicData> dataSet) {
    num distance = attrs.start.distance2(attrs.end);
    distance *= scaleFactor;
    if (distance.isNaN || distance.isInfinite) {
      throw ChartError('$runtimeType 长度未知：$distance');
    }
    return BaseAxisImpl.toScale(axis, [0, distance], dataSet);
  }

  @override
  LineAxisLayoutResult onLayout(P attrs, BaseScale<dynamic, num> scale, List<DynamicData> dataSet) {
    num viewSize = attrs.start.distance2(attrs.end);
    final double distance = (scale.range[1] - scale.range[0]).toDouble();

    ///夹角
    final angle = attrs.end.offsetAngle(attrs.start);
    final Offset end = circlePoint(distance, angle, attrs.start);

    List<TickResult> tickResult = buildTickResult(scale, attrs.start, distance, angle);
    List<LineSplitResult> splitResult = buildSplitResult(tickResult, attrs.start);
    List<LabelResult> labelResult = buildLabelResult(attrs, scale, attrs.start, distance, angle);

    return LineAxisLayoutResult(viewSize, attrs.start, end, splitResult, tickResult, labelResult);
  }

  List<TickResult> buildTickResult(BaseScale<dynamic, num> scale, Offset center, double distance, double angle) {
    int tickCount = scale.tickCount;

    if (tickCount <= 0) {
      tickCount = 1;
    }

    final double interval = distance / (tickCount - 1);

    MainTick tick = axis.axisStyle.axisTick.tick ?? tmpTick;
    MinorTick minorTick = axis.axisStyle.minorTick?.tick ?? tmpMinorTick;
    final double tickOffset = (tick.inside ? -tick.length : tick.length).toDouble();
    final double minorOffset = (tick.inside ? -minorTick.length : minorTick.length).toDouble();

    List<TickResult> resultList = [];
    for (int i = 0; i < tickCount; i++) {
      Offset offset = center.translate(interval * i, 0);

      Offset start = offset.rotateOffset(angle, center: center);
      Offset end = offset.translate(0, tickOffset).rotateOffset(angle, center: center);
      TickResult result = TickResult(start, end, []);
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
        result.minorTickList.add(TickResult(ms, me));
      }
    }
    return resultList;
  }

  List<LineSplitResult> buildSplitResult(List<TickResult> tickResult, Offset center) {
    List<LineSplitResult> resultList = [];
    int c = tickResult.length - 1;
    for (int i = 0; i < c; i++) {
      TickResult pre = tickResult[i];
      TickResult next = tickResult[i + 1];
      LineSplitResult result = LineSplitResult(center, pre.start, next.start);
      resultList.add(result);
    }
    return resultList;
  }

  List<LabelResult> buildLabelResult(P attrs, BaseScale<dynamic, num> scale, Offset center, double distance, double angle) {
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

      LabelResult result = LabelResult(config, text, []);
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
        result.minorLabel.add(LabelResult(minorConfig, text));
      }
    }
    return resultList;
  }

  @override
  TextDrawConfig onLayoutAxisName() {
    Offset center;
    Offset p;

    if (axis.nameAlign == Align2.end) {
      center = attrs.start;
      p = attrs.end;
    } else if (axis.nameAlign == Align2.start) {
      center = attrs.end;
      p = attrs.start;
    } else {
      center = attrs.start;
      p = Offset((attrs.start.dx + attrs.end.dx) / 2, (attrs.start.dy + attrs.end.dy) / 2);
    }
    num a = p.offsetAngle(center);
    double r = center.distance2(p);
    r += axis.nameGap;
    return TextDrawConfig(circlePoint(r, a, center), align: toAlignment(a));
  }

  @override
  void onDrawAxisSplitArea(Canvas canvas, Paint paint, Rect coord) {
    Offset start = attrs.start;
    Offset end = attrs.end;

    ///只实现垂直和水平方向
    if (!(start.dx == end.dx || start.dy == end.dy)) {
      return;
    }
    bool vertical = start.dy == end.dy;
    AxisTheme theme = getAxisTheme();
    AxisStyle axisLine = axis.axisStyle;
    int count = layoutResult.split.length;
    each(layoutResult.split, (split, i) {
      AreaStyle? style = axisLine.getSplitAreaStyle(i, count, theme);
      if (style == null) {
        return;
      }
      Rect rect;
      if (vertical) {
        rect = Rect.fromLTRB(split.start.dx, coord.top, split.end.dx, coord.bottom);
      } else {
        var dis = split.start.distance2(split.end);
        if (start.dy <= end.dy) {
          rect = Rect.fromLTWH(split.start.dx, split.start.dy, coord.width, dis);
        } else {
          rect = Rect.fromLTWH(split.end.dx, split.end.dy, coord.width, dis);
        }
      }
      style.drawRect(canvas, paint, rect);
    });
  }

  @override
  void onDrawAxisSplitLine(Canvas canvas, Paint paint, Rect coord) {
    Offset start = attrs.start;
    Offset end = attrs.end;

    ///只实现垂直和水平方向
    if (!(start.dx == end.dx || start.dy == end.dy)) {
      return;
    }
    bool vertical = start.dx == end.dx;
    AxisTheme theme = getAxisTheme();
    AxisStyle axisLine = axis.axisStyle;
    int count = layoutResult.split.length;
    for (int i = 0; i < count; i++) {
      var split = layoutResult.split[i];
      LineStyle? style = axisLine.getSplitLineStyle(i, count, theme);
      if (style != null) {
        List<Offset> ol = [];
        if (vertical) {
          if (start.dx <= end.dx) {
            ol.add(split.start);
            ol.add(split.start.translate(coord.width, 0));
          } else {
            ol.add(split.end);
            ol.add(split.end.translate(-coord.width, 0));
          }
        } else {
          if (start.dy < end.dy) {
            ol.add(split.start);
            ol.add(split.start.translate(0, coord.height));
          } else {
            ol.add(split.end);
            ol.add(split.end.translate(0, -coord.height));
          }
        }
        style.drawPolygon(canvas, paint, ol);
      }
    }
  }

  @override
  void onDrawAxisLine(Canvas canvas, Paint paint) {
    var axisStyle = axis.axisStyle;
    if (!axisStyle.show) {
      logPrint("onDrawAxisLine() axisStyle.show==false not Draw");
      return;
    }
    AxisTheme theme = getAxisTheme();
    int c = layoutResult.split.length;
    each(layoutResult.split, (split, i) {
      LineStyle? style = axisStyle.getAxisLineStyle(i, c, theme);
      style?.drawPolygon(canvas, paint, [split.start, split.end]);
    });
  }

  @override
  void onDrawAxisTick(Canvas canvas, Paint paint) {
    var axisStyle = axis.axisStyle;
    if (!axisStyle.show) {
      return;
    }
    var theme = getAxisTheme();
    int maxCount = layoutResult.tick.length;
    each(layoutResult.tick, (line, i) {
      MainTick? tick = axisStyle.getMainTick(i, maxCount, theme);
      var minorTick = axisStyle.getMinorTick(i, maxCount, theme);
      bool b1 = (tick != null && tick.show);
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
  }

  @override
  void onDrawAxisLabel(Canvas canvas, Paint paint) {
    var axisStyle = axis.axisStyle;
    if (!axisStyle.show) {
      return;
    }
    var theme = getAxisTheme();
    int maxCount = layoutResult.label.length;
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
  }

  void onScaleFactorChange(double factor) {}

  void onScrollOffsetChange(double offset) {}

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
    return (scale.range[0] - scale.range[1]).abs().toDouble();
  }
}
