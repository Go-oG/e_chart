import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/component/axis/grid/grid_attrs.dart';
import 'package:flutter/material.dart';

abstract class BaseGridAxisImpl extends LineAxisImpl<GridAxis, GridAxisAttr> {
  final Direction direction;

  BaseGridAxisImpl(this.direction, super.context, super.axis, super.attrs);

  ///表示轴的大小
  final AxisInfo axisInfo = AxisInfo(Offset.zero, Offset.zero);

  void onScrollChange(double scroll) {
    axisPainter = onLayout(attrs, scale);
  }

  @override
  LineAxisPainter onLayout(GridAxisAttr attrs, BaseScale<dynamic, num> scale) {
    axisInfo.start = attrs.start;
    axisInfo.end = attrs.end;
    return super.onLayout(attrs, scale);
  }

  @override
  List<LinePainter> onBuildLineResult(BaseScale<dynamic, num> scale, Offset center, double distance, double angle) {
    final double interval = scale.tickInterval.toDouble();
    List<int> indexList = computeRangeIndex(distance, scale.tickCount, interval);
    List<LinePainter> resultList = [];
    for (int i = indexList[0]; i < indexList[1] - 1; i++) {
      Offset s = center.translate(interval * i, 0);
      Offset e = center.translate(interval * (i + 1), 0);
      Offset start = s.rotate(angle, center: center);
      Offset end = e.rotate(angle, center: center);
      resultList.add(LinePainter(i, scale.tickCount - 1, start, end));
    }
    return resultList;
  }

  @override
  List<TickPainter> onBuildTickResult(var scale, Offset center, double distance, double angle) {
    int tickCount = scale.tickCount;
    if (tickCount <= 0) {
      tickCount = 1;
    }
    final double interval = scale.tickInterval.toDouble();
    List<int> indexList = computeRangeIndex(distance, tickCount, interval);
    MainTick tick = axis.axisTick.tick ?? BaseAxisImpl.tmpTick;
    MinorTick minorTick = axis.axisTick.minorTick ?? BaseAxisImpl.tmpMinorTick;
    int minorSN = minorTick.splitNumber;
    if (minorSN < 0) {
      minorSN = 0;
    }
    final double tickOffset = (axis.axisTick.inside ? -tick.length : tick.length).toDouble();
    final double minorOffset = (axis.axisTick.inside ? -minorTick.length : minorTick.length).toDouble();

    List<TickPainter> resultList = [];
    for (int i = indexList[0]; i < indexList[1]; i++) {
      double dis = i * interval;
      final Offset offset = center.translate(dis, 0);
      Offset start = offset.rotate(angle, center: center);
      Offset end = offset.translate(0, tickOffset).rotate(angle, center: center);
      TickPainter result = TickPainter(scale.toData(dis), i, tickCount, start, end, []);
      resultList.add(result);
      int minorCount = minorTick.splitNumber;
      if (minorCount <= 0) {
        continue;
      }
      double minorInterval = interval / (minorCount + 1);
      for (int j = 1; j <= minorTick.splitNumber; j++) {
        var dis2 = minorInterval * j + dis;
        Offset ms = offset.translate(minorInterval * j, 0);
        Offset me = ms.translate(0, minorOffset);
        ms = ms.rotate(angle, center: center);
        me = me.rotate(angle, center: center);
        result.minorList.add(TickPainter(scale.toData(dis2), i, tickCount, ms, me));
      }
    }
    return resultList;
  }

  @override
  List<LabelPainter> onBuildLabelResult(var scale, Offset center, double distance, double angle) {
    final double interval = scale.tickInterval.toDouble();

    ///计算索引
    List<int> indexList = computeRangeIndex(distance, scale.tickCount, interval);

    MainTick tick = axis.axisTick.tick ?? BaseAxisImpl.tmpTick;
    MinorTick minorTick = axis.axisTick.minorTick ?? BaseAxisImpl.tmpMinorTick;
    int sn = minorTick.splitNumber;
    if (sn < 0) {
      sn = 0;
    }
    AxisLabel axisLabel = axis.axisLabel;
    List<DynamicText> labels = obtainLabel2(indexList[0], indexList[1]);
    double labelOffset = axisLabel.padding + axisLabel.margin + 0;
    if (axisLabel.inside == axis.axisTick.inside) {
      labelOffset += tick.length;
    }
    labelOffset *= axisLabel.inside ? -1 : 1;
    List<LabelPainter> resultList = [];

    final Alignment align;
    if (direction == Direction.horizontal) {
      if (axisLabel.inside) {
        align = axis.position == Align2.start ? Alignment.topCenter : Alignment.bottomCenter;
      } else {
        align = axis.position == Align2.start ? Alignment.bottomCenter : Alignment.topCenter;
      }
    } else {
      if (axisLabel.inside) {
        align = axis.position == Align2.end ? Alignment.centerLeft : Alignment.centerRight;
      } else {
        align = axis.position == Align2.end ? Alignment.centerRight : Alignment.centerLeft;
      }
    }

    for (int i = indexList[0]; i < indexList[1]; i++) {
      num d = i;
      if (scale.isCategory && axis.categoryCenter) {
        d += 0.5;
      }
      final double parenDis = interval * d;
      Offset offset = center.translate(parenDis, 0);
      Offset textOffset = offset.translate(0, labelOffset);
      textOffset = textOffset.rotate(angle, center: center);

      DynamicText? text;
      int t = i - indexList[0];
      if (labels.length > t) {
        text = labels[t];
      }
      var style = axisLabel.getStyle(i, scale.tickCount, getAxisTheme());
      var config = TextDraw(text ?? DynamicText.empty, style, textOffset, align: align, rotate: axisLabel.rotate);
      int oi = i * sn;
      var result = LabelPainter(oi, i, scale.tickCount, config, []);
      resultList.add(result);

      int minorCount = minorTick.splitNumber;
      if (minorCount <= 0 || scale.isCategory || scale.isTime) {
        continue;
      }

      ///构建minorLabel
      var minorStyle = axisLabel.getMinorStyle(i, scale.tickCount, getAxisTheme());

      double minorInterval = interval / (minorCount + 1);
      for (int j = 1; j <= minorTick.splitNumber; j++) {
        num dis = parenDis + minorInterval * j;
        var text = axisLabel.formatter?.call(scale.toData(dis)) ?? DynamicText.empty;
        final labelOffset = circlePoint(dis, angle, center);
        var minorConfig = TextDraw(
          text,
          minorStyle,
          labelOffset,
          align: toAlignment(angle + 90, axisLabel.inside),
          rotate: axisLabel.rotate,
        );
        result.minorLabel.add(LabelPainter(oi + j, i, scale.tickCount, minorConfig));
      }
    }
    return resultList;
  }

  @override
  void onDrawAxisSplitArea(CCanvas canvas, Paint paint) {
    var splitArea = axis.splitArea;
    if (!splitArea.show) {
      return;
    }

    AxisTheme theme = getAxisTheme();
    var box = attrs.contentBox;
    final left = attrs.scrollX.abs() + box.left;
    canvas.save();
    canvas.translate(attrs.scrollX, attrs.scrollY);
    canvas.clipRect(getSplitClipRect());
    each(axisPainter.split, (split, p1) {
      var style = splitArea.getStyle(split.index, split.maxIndex, theme);
      if (style.notDraw) {
        return;
      }
      Rect rect;
      if (direction == Direction.horizontal) {
        rect = Rect.fromLTRB(split.start.dx, box.top, split.end.dx, box.bottom);
      } else {
        var dis = split.start.distance2(split.end);
        rect = Rect.fromLTWH(left, split.start.dy, box.width, dis);
      }
      style.drawRect(canvas, paint, rect);
    });
    canvas.restore();
  }

  @override
  void onDrawAxisSplitLine(CCanvas canvas, Paint paint) {
    var splitLine = axis.splitLine;
    if (!splitLine.show) {
      return;
    }
    bool vertical = direction != Direction.vertical;
    double w = attrs.contentBox.width;
    double h = attrs.contentBox.height;
    AxisTheme theme = getAxisTheme();
    int dir;
    if (vertical) {
      dir = axis.position == Align2.start ? 1 : -1;
    } else {
      dir = axis.position == Align2.end ? -1 : 1;
    }

    canvas.save();
    canvas.translate(attrs.scrollX, attrs.scrollY);
    canvas.clipRect(getSplitClipRect());
    each(axisPainter.split, (split, p1) {
      int interval = splitLine.interval;
      if (interval > 0) {
        interval += 1;
      }
      if (interval > 0 && split.index % interval != 0) {
        return;
      }
      var style = axis.splitLine.getStyle(split.data, split.index, split.maxIndex, theme);
      if (style.notDraw) {
        return;
      }
      List<Offset> ol = [split.start];
      if (vertical) {
        ol.add(split.start.translate(0, h * dir));
      } else {
        ol.add(split.start.translate(dir * w, 0));
      }
      style.drawPolygon(canvas, paint, ol);
    });
    canvas.restore();
  }

  @override
  void onDrawAxisLine(CCanvas canvas, Paint paint) {
    var axisLine = axis.axisLine;
    if (!axisLine.show) {
      return;
    }
    final double diff = axisLine.width / 2;
    canvas.save();
    if (isXAxis) {
      int dir = axis.position == Align2.start ? -1 : 1;
      canvas.translate(attrs.scrollX, diff * dir);
    } else {
      int dir = axis.position == Align2.end ? 1 : -1;
      canvas.translate(diff * dir, attrs.scrollY);
    }
    canvas.clipRect(getAxisClipRect());
    axisPainter.drawLine(canvas, paint, axisLine.getStyle(getAxisTheme()));
    canvas.restore();
  }

  @override
  void onDrawAxisTick(CCanvas canvas, Paint paint) {
    if (!axis.axisTick.show) {
      return;
    }
    canvas.save();
    if (isXAxis) {
      canvas.translate(attrs.scrollX, 0);
    } else {
      canvas.translate(0, attrs.scrollY);
    }
    canvas.clipRect(getAxisClipRect());
    axisPainter.drawTick(canvas, paint, axis.axisTick.tick, axis.axisTick.minorTick);
    canvas.restore();
  }

  @override
  void onDrawAxisLabel(CCanvas canvas, Paint paint) {
    var axisLabel = axis.axisLabel;
    if (!axisLabel.show) {
      return;
    }

    canvas.save();
    if (direction == Direction.horizontal) {
      canvas.translate(attrs.scrollX, 0);
    } else {
      canvas.translate(0, attrs.scrollY);
    }

    canvas.clipRect(getAxisClipRect());
    int interval = axisLabel.interval;
    if (interval > 0) {
      interval += 1;
    }
    axisPainter.drawLabel(canvas, paint, interval);
    canvas.restore();
  }

  final TextDraw _axisPointerTD = TextDraw(DynamicText.empty, LabelStyle.empty, Offset.zero);

  @override
  void onDrawAxisPointer(CCanvas canvas, Paint paint, Offset touchOffset) {
    var axisPointer = axis.axisPointer;
    if (axisPointer == null || !axisPointer.show) {
      return;
    }
    final bool vertical = direction == Direction.horizontal;
    Rect rect = attrs.contentBox;
    final pointerDis = computeAxisPointerDis(axisPointer, touchOffset);
    final double paintOffset = axisPointer.lineStyle.width * 0.5;

    canvas.save();
    if (vertical) {
      canvas.translate(attrs.scrollX, 0);
    } else {
      canvas.translate(0, attrs.scrollY);
    }

    List<Offset> ol = [];
    if (vertical) {
      var x = pointerDis + paintOffset + rect.left;
      ol.add(Offset(x, rect.top));
      ol.add(Offset(x, rect.bottom));
    } else {
      var y = attrs.start.dy - pointerDis - paintOffset;
      ol.add(Offset(rect.left, y));
      ol.add(Offset(rect.right, y));
    }
    axisPointer.lineStyle.drawPolygon(canvas, paint, ol);

    ///绘制指示点
    Offset tmp = ol.first;
    if (vertical) {
      tmp = Offset(tmp.dx, attrs.start.dy);
    } else {
      tmp = Offset(attrs.start.dx, tmp.dy);
    }
    var dt = axis.formatData(scale.toData(pointerDis));
    Alignment alignment;
    if (vertical) {
      alignment = axis.position == Align2.start ? Alignment.bottomCenter : Alignment.topCenter;
    } else {
      alignment = axis.position == Align2.end ? Alignment.centerLeft : Alignment.centerRight;
    }
    if (_axisPointerTD.offset != tmp || _axisPointerTD.align != alignment || _axisPointerTD.text != dt) {
      _axisPointerTD.updatePainter(
        text: dt,
        style: axisPointer.labelStyle,
        offset: tmp,
        align: alignment,
      );
    }
    _axisPointerTD.draw(canvas, paint);
    canvas.restore();
  }

  ///计算AxisPointer的距离
  double computeAxisPointerDis(AxisPointer axisPointer, Offset offset) {
    offset = offset.translate(-attrs.scrollX, -attrs.scrollY);
    bool vertical = direction == Direction.horizontal;
    double dis = vertical ? (offset.dx - attrs.start.dx).abs() : (offset.dy - attrs.start.dy).abs();
    bool snap = axisPointer.snap ?? (axis.isCategoryAxis || axis.isTimeAxis);
    if (!snap) {
      return dis;
    }
    final interval = scale.tickInterval.toDouble();
    int c = dis ~/ interval;
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
    return dis;
  }

  ///获取分割区域的裁剪范围
  Rect getSplitClipRect() {
    var box = attrs.contentBox;
    return Rect.fromLTWH(attrs.scrollX.abs() + box.left, box.top - attrs.scrollY, box.width, box.height);
  }

  ///获取坐标轴裁剪范围
  Rect getAxisClipRect() {
    var box = attrs.contentBox;
    if (isXAxis) {
      //X轴
      double left = attrs.scrollX.abs() + box.left;
      var w = box.width;
      if (axis.position == Align2.start) {
        return Rect.fromLTRB(left, -attrs.rect.height, left + w, box.top + attrs.rect.height);
      }
      return Rect.fromLTRB(left, box.bottom - attrs.rect.height, left + w, attrs.coordRect.height);
    }
    //Y轴
    double top = box.top + attrs.scrollY;
    double h = box.height;
    if (axis.position == Align2.end) {
      return Rect.fromLTRB(box.right - attrs.rect.width, top, attrs.coordRect.width + attrs.rect.width, top + h);
    }
    return Rect.fromLTRB(-attrs.rect.width, top, box.left + attrs.rect.width, top + h);
  }

  List<int> computeRangeIndex(num distance, int tickCount, num interval) {
    Rect rect = attrs.contentBox;
    int startIndex, endIndex;
    if (isXAxis) {
      if (distance <= rect.width) {
        startIndex = 0;
        endIndex = tickCount;
      } else {
        double scroll = attrs.scrollX.abs();
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

    //Y轴
    if (distance <= rect.height) {
      startIndex = 0;
      endIndex = tickCount;
    } else {
      double scroll = attrs.scrollY.abs();
      startIndex = scroll ~/ interval - 2;
      if (startIndex < 0) {
        startIndex = 0;
      }
      endIndex = (scroll + rect.height) ~/ interval + 2;
      if (endIndex > tickCount) {
        endIndex = tickCount;
      }
    }
    return [startIndex, endIndex];
  }

  ///获取坐标轴当前显示范围的数据值
  RangeInfo getViewportDataRange() {
    int tickCount = scale.tickCount;
    if (tickCount <= 0) {
      tickCount = 1;
    }
    final distance = attrs.distance;
    final double interval = distance / (tickCount - 1);
    if (scale.isCategory || scale.isTime) {
      List<int> indexList = computeRangeIndex(distance, tickCount, interval);
      List<dynamic> dl = scale.getRangeLabel(indexList[0], indexList[1]);
      if (scale.isCategory) {
        return RangeInfo.category(dl as List<String>);
      }
      return RangeInfo.time(dl as List<DateTime>);
    }

    Rect rect = attrs.contentBox;
    num viewSize = direction == Direction.horizontal ? rect.width : rect.height;
    if (distance <= viewSize) {
      RangeInfo.range(Pair<num>(scale.domain.first, scale.domain.last));
    }
    num scroll = direction == Direction.horizontal ? attrs.scrollX.abs() : attrs.scrollY.abs();
    return RangeInfo.range(Pair<num>(scale.toData(scroll), scale.toData(scroll + viewSize)));
  }

  dynamic pxToData(num position);

  bool get isXAxis => direction == Direction.horizontal;
}
