import 'dart:ui';
import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/coord/grid/axis/base_grid_axis_impl.dart';
import 'package:flutter/material.dart';

///横向轴
class XAxisImpl extends BaseGridAxisImpl {
  XAxisImpl(super.coord, super.context, super.axis, {super.axisIndex});

  Rect? clipRect;

  @override
  void doMeasure(double parentWidth, double parentHeight) {
    AxisStyle axisStyle = axis.axisStyle;
    if (!axisStyle.show) {
      axisInfo.start = axis.position == Align2.start ? const Offset(0, 0) : Offset(0, parentHeight);
      axisInfo.end = Offset(parentWidth, 0);
      axisInfo.bound = Rect.fromLTWH(0, 0, parentWidth, 0);
      return;
    }
    double width = parentWidth;
    double height = (axisStyle.getAxisLineStyle(0, 1, getAxisTheme())?.width.toDouble()) ?? 0;
    MainTick? tick = axisStyle.getMainTick(0, 1, getAxisTheme());
    num tickHeight = 0;
    if (tick != null && tick.show) {
      tickHeight = tick.length;
    }
    MinorTick? minorTick = axisStyle.getMinorTick(0, 1, getAxisTheme());
    if (minorTick != null && minorTick.show) {
      tickHeight = max([tickHeight, minorTick.length]);
    }
    height += tickHeight;

    AxisLabel axisLabel = axisStyle.axisLabel;
    if (axisLabel.show) {
      height += axisLabel.margin + axisLabel.padding;
      var maxStr = getMaxStr(Direction.horizontal);
      Size textSize = axisLabel.getLabelStyle(0, 1, getAxisTheme())?.measure(maxStr) ?? Size.zero;
      height += textSize.height;
    }
    Rect rect = Rect.fromLTWH(0, 0, width, height);
    axisInfo.start = rect.topLeft;
    axisInfo.end = rect.topRight;
    axisInfo.bound = rect;
  }

  @override
  LineAxisLayoutResult onLayout(LineAxisAttrs attrs, BaseScale<dynamic, num> scale) {
    Rect rect = coord.contentBox;
    Offset offset = splitScrollOffset(coord.getTranslation());
    if (offset.dx.abs() != 0) {
      clipRect =Rect.fromLTWH(attrs.start.dx, attrs.start.dy - 1, rect.width, attrs.rect.height + 1);
    }else{
      clipRect=null;
    }
    return super.onLayout(attrs, scale);
  }

  @override
  List<TickResult> onBuildTickResult(BaseScale<dynamic, num> scale, Offset center, double distance, double angle) {
    int tickCount = scale.tickCount;
    if (tickCount <= 0) {
      tickCount = 1;
    }
    final double interval = distance / (tickCount - 1);
    List<int> indexList = computeIndex(distance, tickCount, interval);
    MainTick tick = axis.axisStyle.axisTick.tick ?? tmpTick;
    MinorTick minorTick = axis.axisStyle.minorTick?.tick ?? tmpMinorTick;
    final double tickOffset = (tick.inside ? -tick.length : tick.length).toDouble();
    final double minorOffset = (tick.inside ? -minorTick.length : minorTick.length).toDouble();
    List<TickResult> resultList = [];
    for (int i = indexList[0]; i < indexList[1]; i++) {
      Offset offset = center.translate(interval * i, 0);
      Offset start = offset.rotateOffset(angle, center: center);
      Offset end = offset.translate(0, tickOffset).rotateOffset(angle, center: center);
      TickResult result = TickResult(i, tickCount, start, end, []);
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
        result.minorTickList.add(TickResult(i, tickCount, ms, me));
      }
    }
    return resultList;
  }

  @override
  List<LabelResult> onBuildLabelResult(LineAxisAttrs attrs, BaseScale<dynamic, num> scale, Offset center, double distance, double angle) {
    int tickCount = scale.tickCount;
    if (tickCount <= 0) {
      tickCount = 1;
    }
    final double interval = distance / (tickCount - 1);
    List<int> indexList = computeIndex(distance, tickCount, interval);

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
    for (int i = indexList[0]; i < indexList[1]; i++) {
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

      LabelResult result = LabelResult(i, tickCount, config, text, []);
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
        result.minorLabel.add(LabelResult(i, tickCount, minorConfig, text));
      }
    }
    return resultList;
  }

  @override
  void draw(Canvas canvas, Paint paint, Rect coord) {
    canvas.save();
    if (clipRect != null) {
      canvas.clipRect(clipRect!);
    }
    super.draw(canvas, paint, coord);
    canvas.restore();
  }

  @override
  List<Offset> dataToPoint(DynamicData data) {
    List<num> nl = scale.toRange(data.data);
    List<Offset> ol = [];
    for (var d in nl) {
      ol.add(Offset(d.toDouble(), attrs.start.dy));
    }
    return ol;
  }

  @override
  void onScrollChange(double scroll) {
    layoutResult = onLayout(attrs, scale);
  }

  @override
  Offset splitScrollOffset(Offset scroll) {
    return Offset(scroll.dx, 0);
  }

  List<int> computeIndex(num distance, int tickCount, num interval) {
    Rect rect = coord.contentBox;
    int startIndex, endIndex;
    if (distance <= rect.width) {
      startIndex = 0;
      endIndex = tickCount;
    } else {
      double scroll = coord.scrollXOffset.abs();
      startIndex = scroll ~/ interval - 2;
      if (startIndex < 0) {
        startIndex = 0;
      }
      endIndex = (scroll + rect.width) ~/ interval + 2;
      if (endIndex > tickCount) {
        endIndex = tickCount;
      }
    }
    return [startIndex, endIndex];
  }
}
