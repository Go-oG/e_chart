import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

abstract class BaseGridAxisImpl extends LineAxisRender<GridAxis, GridAxisAttr> {
  final Direction direction;
  GridCoord coord;

  BaseGridAxisImpl(this.direction, this.coord, super.context, super.axis, {super.axisIndex});

  ///表示轴的大小
  double axisSize = 0;

  void onScrollChange(double scroll) {
    onLayout(attrs, scale);
  }

  @override
  List<Drawable>? onLayoutAxisLine(GridAxisAttr attrs, BaseScale<dynamic, num> scale) {
    var axisLine = axis.axisLine;
    if (!axisLine.show) {
      return null;
    }
    var center = attrs.start;
    var angle = axisAngle;
    var style = axisLine.getStyle(axisTheme);

    final double interval = scale.tickInterval.toDouble();
    List<int> indexList = computeRangeIndex(axisLength, scale.tickCount, interval);
    List<AxisLineDrawable> resultList = [];

    for (int i = indexList[0]; i < indexList[1] - 1; i++) {
      var dis = interval * i;
      var nextDis = dis + interval;
      var s = center.translate(dis, 0);
      var e = center.translate(nextDis, 0);
      var start = s.rotate(angle, center: center);
      var end = e.rotate(angle, center: center);

      resultList
          .add(AxisLineDrawable([scale.toData(dis), scale.toData(nextDis)], i, scale.tickCount - 1, start, end, style));
    }

    return resultList;
  }

  @override
  List<Drawable>? onLayoutAxisTick(GridAxisAttr attrs, BaseScale<dynamic, num> scale) {
    var axisTick = axis.axisTick;
    var tick = axisTick.tick;
    if (!axisTick.show || (tick == null || !tick.show)) {
      return null;
    }

    int tickCount = scale.tickCount;
    if (tickCount <= 0) {
      tickCount = 1;
    }

    final double interval = scale.tickInterval;
    List<int> indexList = computeRangeIndex(axisLength, tickCount, interval);

    var minorTick = axis.axisTick.minorTick;
    final minorCount = minorTick?.splitNumber ?? 0;
    final int tickDir = axisTick.inside ? -1 : 1;
    final double tickOffset = axisTick.getTickSize() * tickDir;
    final double minorOffset = axisTick.getMinorSize() * tickDir;
    final minorInterval = interval / (minorCount + 1);

    final center = attrs.start;
    final angle = axisAngle;
    List<TickDrawable> resultList = [];
    var tickStyle = tick.lineStyle;
    for (int i = indexList[0]; i < indexList[1]; i++) {
      double dis = i * interval;
      final Offset offset = center.translate(dis, 0);
      Offset start = offset.rotate(angle, center: center);
      Offset end = offset.translate(0, tickOffset).rotate(angle, center: center);
      var tickNode = TickDrawable([scale.toData(dis)], i, tickCount, start, end, tickStyle, []);
      resultList.add(tickNode);
      if (minorCount <= 0 || minorTick == null || !minorTick.show) {
        continue;
      }

      for (int j = 1; j < minorCount; j++) {
        var dis2 = minorInterval * j + dis;
        Offset ms = offset.translate(minorInterval * j, 0);
        Offset me = ms.translate(0, minorOffset);
        ms = ms.rotate(angle, center: center);
        me = me.rotate(angle, center: center);
        tickNode.minorList.add(TickDrawable(scale.toData(dis2), i, tickCount, ms, me, minorTick.lineStyle));
      }
    }
    return resultList;
  }

  @override
  List<Drawable>? onLayoutAxisLabel(GridAxisAttr attrs, BaseScale<dynamic, num> scale) {
    var axisLabel = axis.axisLabel;
    if (!axisLabel.show) {
      return null;
    }

    final double interval = scale.tickInterval;

    ///计算索引
    final indexList = computeRangeIndex(axisLength, scale.tickCount, interval);
    final labels = obtainLabel2(indexList[0], indexList[1]);

    double labelOffset = axisLabel.padding + axisLabel.margin + 0;
    if (axisLabel.inside == axis.axisTick.inside) {
      labelOffset += axis.axisTick.getMaxTickSize();
    }
    labelOffset *= axisLabel.inside ? -1 : 1;

    List<AxisLabelDrawable> resultList = [];
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

    final center = attrs.start;
    final angle = axisAngle;
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
      var style = axisLabel.getStyle(i, scale.tickCount, axisTheme);
      var config = TextDraw(text ?? DynamicText.empty, style, textOffset, align: align, rotate: axisLabel.rotate);
      var result = AxisLabelDrawable(i, scale.tickCount, config, []);
      resultList.add(result);
    }
    return resultList;
  }

  @override
  List<Drawable>? onLayoutSplitArea(GridAxisAttr attrs, BaseScale<dynamic, num> scale) {
    var splitArea = axis.splitArea;
    if (!splitArea.show) {
      return null;
    }
    List<SplitAreaDrawable> list = [];
    final double interval = scale.tickInterval;
    List<int> indexList = computeRangeIndex(axisLength, scale.tickCount, interval);

    List<List<Offset>> pl = [];
    for (int i = indexList[0]; i < indexList[1]; i++) {
      double dis = i * interval;
      Offset start;
      Offset end;
      if (isXAxis) {
        start = Offset(dis, coord.contentBox.bottom);
        end = start.translate(0, -coord.contentBox.height);
      } else {
        start = Offset(coord.contentBox.left, dis);
        end = start.translate(coord.contentBox.width, 0);
      }
      var ol = [start, end];
      if (pl.isNotEmpty) {
        var pre = pl.last;
        var style = splitArea.getStyle(pl.length ~/ 2, scale.tickCount - 1, axisTheme);
        Path path = Path();
        path.moveTo2(pre.first);
        path.lineTo2(pre.last);
        path.lineTo2(ol.last);
        path.lineTo2(ol.first);
        path.close();
        list.add(SplitAreaDrawable([], path, style));
      }
      pl.add(ol);
    }
    return list;
  }

  @override
  List<Drawable>? onLayoutSplitLine(GridAxisAttr attrs, BaseScale<dynamic, num> scale) {
    var splitLine = axis.splitLine;
    if (!splitLine.show) {
      return null;
    }
    List<AxisLineDrawable> list = [];
    int tickCount = scale.tickCount;
    if (tickCount <= 0) {
      tickCount = 1;
    }
    final double interval = scale.tickInterval;
    List<int> indexList = computeRangeIndex(axisLength, tickCount, interval);
    for (int i = indexList[0]; i < indexList[1]; i++) {
      double dis = i * interval;
      Offset start;
      Offset end;
      if (isXAxis) {
        start = Offset(dis, coord.contentBox.bottom);
        end = start.translate(0, -coord.contentBox.height);
      } else {
        start = Offset(coord.contentBox.left, dis);
        end = start.translate(coord.contentBox.width, 0);
      }
      final data = scale.toData(dis);
      var style = splitLine.getStyle(data, i, tickCount, axisTheme);
      list.add(AxisLineDrawable([scale.toData(dis)], i, tickCount, start, end, style));
    }
    return list;
  }

  @override
  void onDrawAxisSplitArea(CCanvas canvas, Paint paint) {
    var splitArea = axis.splitArea;
    if (!splitArea.show) {
      return;
    }
    canvas.save();
    canvas.translate(attrs.scrollX, attrs.scrollY);
    canvas.clipRect(getSplitClipRect());
    super.onDrawAxisSplitArea(canvas, paint);
    canvas.restore();
  }

  @override
  void onDrawAxisSplitLine(CCanvas canvas, Paint paint) {
    var splitLine = axis.splitLine;
    if (!splitLine.show) {
      return;
    }
    bool vertical = direction != Direction.vertical;
    double w = coord.contentBox.width;
    double h = coord.contentBox.height;
    AxisTheme theme = AxisTheme();
    int dir;
    if (vertical) {
      dir = axis.position == Align2.start ? 1 : -1;
    } else {
      dir = axis.position == Align2.end ? -1 : 1;
    }

    canvas.save();
    canvas.translate(attrs.scrollX, attrs.scrollY);
    canvas.clipRect(getSplitClipRect());
    each(splitLineList, (render, p1) {
      Logger.i(render.runtimeType);
      var split = render as AxisLineDrawable;
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
    super.onDrawAxisLine(canvas, paint);
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
    super.onDrawAxisTick(canvas, paint);
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
    super.onDrawAxisLabel(canvas, paint);
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
    Rect rect = coord.contentBox;
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
    var box = coord.contentBox;
    return Rect.fromLTWH(attrs.scrollX.abs() + box.left, box.top - attrs.scrollY, box.width, box.height);
  }

  ///获取坐标轴裁剪范围
  Rect getAxisClipRect() {
    var box = coord.contentBox;
    if (isXAxis) {
      //X轴
      double left = attrs.scrollX.abs() + box.left;
      var w = box.width;
      if (axis.position == Align2.start) {
        return Rect.fromLTRB(left, -attrs.rect.height, left + w, box.top + attrs.rect.height);
      }
      return Rect.fromLTRB(left, box.bottom - attrs.rect.height, left + w, coord.height);
    }
    //Y轴
    double top = box.top + attrs.scrollY;
    double h = box.height;
    if (axis.position == Align2.end) {
      return Rect.fromLTRB(box.right - attrs.rect.width, top, coord.width + attrs.rect.width, top + h);
    }
    return Rect.fromLTRB(-attrs.rect.width, top, box.left + attrs.rect.width, top + h);
  }

  List<int> computeRangeIndex(num distance, int tickCount, num interval) {
    Rect rect = coord.contentBox;
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

    Rect rect = coord.contentBox;
    num viewSize = direction == Direction.horizontal ? rect.width : rect.height;
    if (distance <= viewSize) {
      RangeInfo.range(Pair<num>(scale.domain.first, scale.domain.last));
    }
    num scroll = direction == Direction.horizontal ? attrs.scrollX.abs() : attrs.scrollY.abs();
    return RangeInfo.range(Pair<num>(scale.toData(scroll), scale.toData(scroll + viewSize)));
  }

  dynamic pxToData(num position);

  bool get isXAxis => direction == Direction.horizontal;

  @override
  GridAxisAttr onBuildDefaultAttrs() => GridAxisAttr(Rect.zero, Offset.zero, Offset.zero, DynamicText.empty);
}
