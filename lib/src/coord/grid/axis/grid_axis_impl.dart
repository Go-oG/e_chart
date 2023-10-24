import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

abstract class BaseGridAxisImpl extends LineAxisImpl<GridAxis, LineAxisAttrs, GridCoord> {
  final Direction direction;

  BaseGridAxisImpl(this.direction, super.context, super.coord, super.axis, {super.axisIndex});

  ///表示轴的大小
  final AxisInfo _axisInfo = AxisInfo(Offset.zero, Offset.zero, Rect.zero);

  AxisInfo get axisInfo => _axisInfo;

  DynamicText getMaxStr(Direction direction) {
    DynamicText maxStr = DynamicText.empty;
    Size size = Size.zero;
    bool isXAxis = direction == Direction.horizontal;
    for (var ele in coord.getGridChildList()) {
      DynamicText text = ele.getAxisMaxText(axisIndex, isXAxis);
      if ((maxStr.isString || maxStr.isTextSpan) && (text.isString || text.isTextSpan)) {
        if (text.length > maxStr.length) {
          maxStr = text;
        }
      } else {
        if (size == Size.zero) {
          size = maxStr.getTextSize();
        }
        Size size2 = text.getTextSize();
        if ((size2.height > size.height && isXAxis) || (!isXAxis && size2.width > size.width)) {
          maxStr = text;
          size = size2;
        }
      }
    }
    return maxStr;
  }

  void onScrollChange(double scroll) {
    layoutResult = onLayout(attrs, scale);
  }

  @override
  List<LineResult> onBuildLineResult(BaseScale<dynamic, num> scale, Offset center, double distance, double angle) {
    final double interval = scale.tickInterval.toDouble();
    List<int> indexList = computeRangeIndex(distance, scale.tickCount, interval);
    List<LineResult> resultList = [];
    for (int i = indexList[0]; i < indexList[1] - 1; i++) {
      Offset s = center.translate(interval * i, 0);
      Offset e = center.translate(interval * (i + 1), 0);
      Offset start = s.rotate(angle, center: center);
      Offset end = e.rotate(angle, center: center);
      resultList.add(LineResult(i, scale.tickCount - 1, start, end));
    }
    return resultList;
  }

  @override
  List<TickResult> onBuildTickResult(var scale, Offset center, double distance, double angle) {
    int tickCount = scale.tickCount;
    if (tickCount <= 0) {
      tickCount = 1;
    }
    final double interval = scale.tickInterval.toDouble();
    List<int> indexList = computeRangeIndex(distance, tickCount, interval);
    MainTick tick = axis.axisTick.tick ?? BaseAxisImpl.tmpTick;
    MinorTick minorTick = axis.minorTick?.tick ?? BaseAxisImpl.tmpMinorTick;
    int minorSN = minorTick.splitNumber;
    if (minorSN < 0) {
      minorSN = 0;
    }
    final double tickOffset = (tick.inside ? -tick.length : tick.length).toDouble();
    final double minorOffset = (tick.inside ? -minorTick.length : minorTick.length).toDouble();

    List<TickResult> resultList = [];
    for (int i = indexList[0]; i < indexList[1]; i++) {
      double t = i.toDouble();
      final Offset offset = center.translate(interval * t, 0);
      Offset start = offset.rotate(angle, center: center);
      Offset end = offset.translate(0, tickOffset).rotate(angle, center: center);
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

        ms = ms.rotate(angle, center: center);
        me = me.rotate(angle, center: center);
        result.minorTickList.add(TickResult(oi + j, i, tickCount, ms, me));
      }
    }
    return resultList;
  }

  @override
  List<LabelResult> onBuildLabelResult(var scale, Offset center, double distance, double angle) {
    final double interval = scale.tickInterval.toDouble();

    ///计算索引
    List<int> indexList = computeRangeIndex(distance, scale.tickCount, interval);

    MainTick tick = axis.axisTick.tick ?? BaseAxisImpl.tmpTick;
    MinorTick minorTick = axis.minorTick?.tick ?? BaseAxisImpl.tmpMinorTick;
    int sn = minorTick.splitNumber;
    if (sn < 0) {
      sn = 0;
    }
    AxisLabel axisLabel = axis.axisLabel;
    List<DynamicText> labels = obtainLabel2(indexList[0], indexList[1]);
    double labelOffset = axisLabel.padding + axisLabel.margin + 0;
    if (axisLabel.inside == tick.inside) {
      labelOffset += tick.length;
    }
    labelOffset *= axisLabel.inside ? -1 : 1;
    List<LabelResult> resultList = [];

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
      var style = axisLabel.getLabelStyle(i, scale.tickCount, getAxisTheme());
      var config = TextDraw(text ?? DynamicText.empty, style, textOffset, align: align, rotate: axisLabel.rotate);
      int oi = i * sn;
      var result = LabelResult(oi, i, scale.tickCount, config, []);
      resultList.add(result);

      int minorCount = minorTick.splitNumber;
      if (minorCount <= 0 || scale.isCategory || scale.isTime) {
        continue;
      }

      ///构建minorLabel
      var minorStyle = axisLabel.getMinorLabelStyle(i, scale.tickCount, getAxisTheme());

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
        result.minorLabel.add(LabelResult(oi + j, i, scale.tickCount, minorConfig));
      }
    }
    return resultList;
  }

  @override
  void onDrawAxisSplitArea(CCanvas canvas, Paint paint, Offset scroll) {
    var splitArea = axis.splitArea;
    if (splitArea == null || !splitArea.show) {
      return;
    }

    AxisTheme theme = getAxisTheme();
    var box = coord.contentBox;
    canvas.save();
    canvas.translate(scroll.dx, scroll.dy);
    canvas.clipRect(getClipRect(scroll));
    each(layoutResult.split, (split, p1) {
      AreaStyle? style = splitArea.getSplitAreaStyle(split.index, split.maxIndex, theme);
      if (style == null) {
        return;
      }
      Rect rect;
      if (direction == Direction.horizontal) {
        rect = Rect.fromLTRB(split.start.dx, box.top, split.end.dx, box.bottom);
      } else {
        var dis = split.start.distance2(split.end);
        double left = scroll.dx.abs() + box.left;
        rect = Rect.fromLTWH(left, split.start.dy, box.width, dis);
      }
      style.drawRect(canvas, paint, rect);
    });
    canvas.restore();
  }

  @override
  void onDrawAxisSplitLine(CCanvas canvas, Paint paint, Offset scroll) {
    var splitLine = axis.splitLine;
    if (!splitLine.show) {
      return;
    }
    bool vertical = direction != Direction.vertical;
    double w = coord.contentBox.width;
    double h = coord.contentBox.height;
    AxisTheme theme = getAxisTheme();
    int dir;
    if (vertical) {
      dir = axis.position == Align2.start ? 1 : -1;
    } else {
      dir = axis.position == Align2.end ? -1 : 1;
    }

    canvas.save();
    canvas.translate(scroll.dx, scroll.dy);
    canvas.clipRect(getClipRect(scroll));
    each(layoutResult.split, (split, p1) {
      int interval = splitLine.interval;
      if (interval > 0) {
        interval += 1;
      }
      if (interval > 0 && split.index % interval != 0) {
        return;
      }
      var style = axis.getSplitLineStyle(split.index, split.maxIndex, theme);
      if (style == null) {
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
  void onDrawAxisLine(CCanvas canvas, Paint paint, Offset scroll) {
    var axisLine = axis.axisLine;
    if (!axisLine.show) {
      return;
    }
    AxisTheme theme = getAxisTheme();
    final double diff = axisLine.width / 2;
    canvas.save();
    if (direction == Direction.horizontal) {
      int dir = axis.position == Align2.start ? -1 : 1;
      canvas.translate(scroll.dx, diff * dir);
    } else {
      int dir = axis.position == Align2.end ? 1 : -1;
      canvas.translate(diff * dir, scroll.dy);
    }
    canvas.clipRect(getAxisClipRect(scroll));
    each(layoutResult.split, (split, i) {
      var style = axis.getAxisLineStyle(i, split.maxIndex, theme);
      if (style == null || style.notDraw) {
        return;
      }
      style.drawPolygon(canvas, paint, [split.start, split.end]);
    });
    canvas.restore();
  }

  @override
  void onDrawAxisTick(CCanvas canvas, Paint paint, Offset scroll) {
    var theme = getAxisTheme();
    canvas.save();
    if (direction == Direction.horizontal) {
      canvas.translate(scroll.dx, 0);
    } else {
      canvas.translate(0, scroll.dy);
    }
    canvas.clipRect(getAxisClipRect(scroll));
    each(layoutResult.tick, (line, p1) {
      MainTick? tick = axis.getMainTick(line.index, line.maxIndex, theme);
      bool b1 = (tick != null && tick.show);
      if (b1) {
        int interval = tick.interval;
        if (interval > 0) {
          interval += 1;
        }
        var start = line.start;
        var end = line.end;
        if (interval <= 0 || (line.originIndex % interval == 0)) {
          tick.lineStyle.drawPolygon(canvas, paint, [start, end]);
        }
      }
      var minorTick = axis.getMinorTick(line.index, line.maxIndex, theme);
      bool b2 = (minorTick != null && minorTick.show);
      if (b2) {
        int interval = minorTick.interval;
        if (interval > 0) {
          interval += 1;
        }
        each(line.minorTickList, (at, p2) {
          if (interval <= 0) {
            minorTick.lineStyle.drawPolygon(canvas, paint, [at.start, at.end]);
            return;
          }
          if (at.originIndex % interval == 0) {
            minorTick.lineStyle.drawPolygon(canvas, paint, [at.start, at.end]);
          }
        });
      }
    });
    canvas.restore();
  }

  @override
  void onDrawAxisLabel(CCanvas canvas, Paint paint, Offset scroll) {
    var axisLabel = axis.axisLabel;
    if (!axisLabel.show) {
      return;
    }

    canvas.save();
    if (direction == Direction.horizontal) {
      canvas.translate(scroll.dx, 0);
    } else {
      canvas.translate(0, scroll.dy);
    }

    Rect clipRect = getAxisClipRect(scroll);
    if (direction == Direction.horizontal) {
      //X 轴
      double left = coord.getLeftFirstAxisWidth() * 0.5;
      if (left <= 0) {
        left = 10;
      }
      double right = coord.getRightFirstAxisWidth() * 0.5;
      if (right <= 0) {
        right = 10;
      }
      clipRect = Rect.fromLTRB(clipRect.left - left, clipRect.top, clipRect.right + right, clipRect.bottom);
    } else {
      double top = coord.getTopFirstAxisHeight() * 0.5;
      if (top <= 0) {
        top = 10;
      }
      double bottom = coord.getBottomFirstAxisHeight() * 0.5;
      if (bottom <= 0) {
        bottom = 10;
      }
      clipRect = Rect.fromLTRB(clipRect.left, clipRect.top - top, clipRect.right, clipRect.bottom + bottom);
    }
    canvas.clipRect(clipRect);

    int interval = axisLabel.interval;
    if (interval > 0) {
      interval += 1;
    }

    each(layoutResult.label, (label, i) {
      if (!label.textConfig.notDraw) {
        if (interval <= 0 || label.originIndex % interval == 0) {
          label.textConfig.draw(canvas, paint);
        }
      }
      if (label.minorLabel.isNotEmpty && label.minorLabel.first.textConfig.style.show) {
        each(label.minorLabel, (minor, p1) {
          if (interval <= 0 || minor.originIndex % interval == 0) {
            minor.textConfig.draw(canvas, paint);
          }
        });
      }
    });
    canvas.restore();
  }

  final TextDraw _axisPointerTD = TextDraw(DynamicText.empty, LabelStyle.empty, Offset.zero);

  @override
  void onDrawAxisPointer(CCanvas canvas, Paint paint, Offset offset) {
    var axisPointer = axis.axisPointer;
    if (axisPointer == null || !axisPointer.show) {
      return;
    }
    final bool vertical = direction == Direction.horizontal;
    Rect rect = coord.contentBox;
    Offset scroll = coord.translation;
    final pointerDis = computeAxisPointerDis(axisPointer, offset);
    final double paintOffset = axisPointer.lineStyle.width * 0.5;

    canvas.save();
    if (vertical) {
      canvas.translate(scroll.dx, 0);
    } else {
      canvas.translate(0, scroll.dy);
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
    var dt = formatData(scale.toData(pointerDis));
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
    Offset scroll = coord.translation;
    offset = offset.translate(-scroll.dx, -scroll.dy);

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

  Rect getClipRect(Offset scroll) {
    var box = coord.contentBox;
    return Rect.fromLTWH(scroll.dx.abs() + box.left, box.top - scroll.dy, box.width, box.height);
  }

  Rect getAxisClipRect(Offset scroll) {
    var box = coord.contentBox;

    if (direction == Direction.horizontal) {
      //X轴
      double left = scroll.dx.abs() + box.left;
      var offset = coord.getAxisLayoutOffset(true);
      left -= offset[0];
      var w = box.width + offset[0] + offset[1];
      if (axis.position == Align2.start) {
        return Rect.fromLTRB(left, -attrs.rect.height, left + w, box.top + attrs.rect.height);
      }
      return Rect.fromLTRB(left, box.bottom - attrs.rect.height, left + w, coord.height);
    }
    //Y轴
    var offset = coord.getAxisLayoutOffset(false);
    double top = box.top + scroll.dy - offset[0];
    double h = box.height + offset[0] + offset[1];
    if (axis.position == Align2.end) {
      return Rect.fromLTRB(box.right - attrs.rect.width, top, coord.width + attrs.rect.width, top + h);
    }
    return Rect.fromLTRB(-attrs.rect.width, top, box.left + attrs.rect.width, top + h);
  }

  List<int> computeRangeIndex(num distance, int tickCount, num interval) {
    Rect rect = coord.contentBox;
    int startIndex, endIndex;
    if (direction == Direction.horizontal) {
      //X 轴
      if (distance <= rect.width) {
        startIndex = 0;
        endIndex = tickCount;
      } else {
        double scroll = coord.translationX.abs();
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
      double scroll = coord.translationY.abs();
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
    num scroll = direction == Direction.horizontal ? coord.translationX.abs() : coord.translationY.abs();
    return RangeInfo.range(Pair<num>(scale.toData(scroll), scale.toData(scroll + viewSize)));
  }

  dynamic pxToData(num position);
}
