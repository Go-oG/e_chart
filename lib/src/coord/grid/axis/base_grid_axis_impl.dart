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
  List<TickResult> onBuildTickResult(BaseScale<dynamic, num> scale, Offset center, double distance, double angle) {
    int tickCount = scale.tickCount;
    if (tickCount <= 0) {
      tickCount = 1;
    }
    final double interval = distance / (tickCount - 1);
    List<int> indexList = computeIndex(distance, tickCount, interval);
    MainTick tick = axis.axisTick.tick ?? tmpTick;
    MinorTick minorTick = axis.minorTick?.tick ?? tmpMinorTick;
    int minorSN = minorTick.splitNumber;
    if (minorSN < 0) {
      minorSN = 0;
    }
    final double tickOffset = (tick.inside ? -tick.length : tick.length).toDouble();
    final double minorOffset = (tick.inside ? -minorTick.length : minorTick.length).toDouble();

    List<TickResult> resultList = [];
    for (int i = indexList[0]; i < indexList[1]; i++) {
      double t = i.toDouble();
      Offset offset = center.translate(interval * t, 0);
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

  @override
  List<LabelResult> onBuildLabelResult(LineAxisAttrs attrs, BaseScale<dynamic, num> scale, Offset center, double distance, double angle) {
    int tickCount = scale.tickCount;
    if (tickCount <= 0) {
      tickCount = 1;
    }

    final double interval = distance / (tickCount - 1);

    ///计算索引
    List<int> indexList = computeIndex(distance, tickCount, interval);

    MainTick tick = axis.axisTick.tick ?? tmpTick;
    MinorTick minorTick = axis.minorTick?.tick ?? tmpMinorTick;
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
    for (int i = indexList[0]; i < indexList[1]; i++) {
      double d = i.toDouble();
      if (scale.isCategory && axis.categoryCenter) {
        d += 0.5;
      }
      final double parenDis = interval * d;
      Offset offset = center.translate(parenDis, 0);
      Offset textOffset = offset.translate(0, labelOffset);
      textOffset = textOffset.rotateOffset(angle, center: center);
      TextDrawInfo config = TextDrawInfo(textOffset, align: toAlignment(angle + 90, axisLabel.inside));
      DynamicText? text;
      int t = i - indexList[0];
      if (labels.length > t) {
        text = labels[t];
      }
      int oi = i * sn;
      LabelResult result = LabelResult(oi, i, tickCount, config, text, []);
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
        TextDrawInfo minorConfig = TextDrawInfo(labelOffset, align: toAlignment(angle + 90, axisLabel.inside));
        dynamic data = scale.toData(dis);
        DynamicText? text = axisLabel.formatter?.call(data);
        result.minorLabel.add(LabelResult(oi + j, i, tickCount, minorConfig, text));
      }
    }
    return resultList;
  }

  @override
  void onDrawAxisSplitArea(Canvas canvas, Paint paint, Offset scroll) {
    AxisTheme theme = getAxisTheme();
    var box = coord.contentBox;
    canvas.save();
    canvas.translate(scroll.dx, scroll.dy);
    canvas.clipRect(getClipRect(scroll));
    each(layoutResult.split, (split, p1) {
      AreaStyle? style = axis.getSplitAreaStyle(split.index, split.maxIndex, theme);
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
  void onDrawAxisSplitLine(Canvas canvas, Paint paint, Offset scroll) {
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
      LineStyle? style = axis.getSplitLineStyle(split.index, split.maxIndex, theme);
      if (style == null) {
        return;
      }
      List<Offset> ol = [];
      if (vertical) {
        ol.add(split.start);
        ol.add(split.start.translate(0, h * dir));
      } else {
        ol.add(split.start);
        ol.add(split.start.translate(dir * w, 0));
      }
      style.drawPolygon(canvas, paint, ol);
    });
    canvas.restore();
  }

  @override
  void onDrawAxisLine(Canvas canvas, Paint paint, Offset scroll) {
    AxisTheme theme = getAxisTheme();
    canvas.save();
    if (direction == Direction.horizontal) {
      canvas.translate(scroll.dx, 0);
    } else {
      canvas.translate(0, scroll.dy);
    }
    canvas.clipRect(getAxisClipRect(scroll));
    each(layoutResult.split, (split, i) {
      LineStyle? style = axis.getAxisLineStyle(i, split.maxIndex, theme);
      if (style == null) {
        logPrint("$runtimeType 坐标轴axisLine样式为空 不绘制");
      }
      style?.drawPolygon(canvas, paint, [split.start, split.end]);
    });
    canvas.restore();
  }

  @override
  void onDrawAxisTick(Canvas canvas, Paint paint, Offset scroll) {
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
        if (interval > 0) {
          if (line.originIndex % interval == 0) {
            tick.lineStyle.drawPolygon(canvas, paint, [line.start, line.end]);
          }
        } else {
          tick.lineStyle.drawPolygon(canvas, paint, [line.start, line.end]);
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
  void onDrawAxisLabel(Canvas canvas, Paint paint, Offset scroll) {
    var axisLabel = axis.axisLabel;
    if (!axisLabel.show) {
      return;
    }
    var theme = getAxisTheme();
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
      var labelStyle = axisLabel.getLabelStyle(label.index, label.maxIndex, theme);
      var minorStyle = axisLabel.getMinorLabelStyle(label.index, label.maxIndex, theme);
      bool b1 = (labelStyle != null && labelStyle.show);
      bool b2 = (minorStyle != null && minorStyle.show);
      if (b1 && label.text != null) {
        if (interval > 0) {
          if (label.originIndex % interval == 0) {
            labelStyle.draw(canvas, paint, label.text!, label.textConfig);
          }
        } else {
          labelStyle.draw(canvas, paint, label.text!, label.textConfig);
        }
      }

      if (b2) {
        each(label.minorLabel, (minor, p1) {
          if (minor.text == null) {
            return;
          }
          if (interval <= 0) {
            minorStyle.draw(canvas, paint, minor.text!, minor.textConfig);
            return;
          }

          if (minor.originIndex % interval == 0) {
            minorStyle.draw(canvas, paint, minor.text!, minor.textConfig);
          }
        });
      }
    });
    canvas.restore();
  }

  @override
  void onDrawAxisPointer(Canvas canvas, Paint paint, Offset offset) {
    var axisPointer = axis.axisPointer;
    if (axisPointer == null || !axisPointer.show) {
      return;
    }
    final bool vertical = direction == Direction.horizontal;
    Rect rect = coord.contentBox;
    Offset scroll = coord.getTranslation();
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

    DynamicText dt = formatData(scale.toData(pointerDis));
    Alignment alignment;
    if (vertical) {
      alignment = axis.position == Align2.start ? Alignment.bottomCenter : Alignment.topCenter;
    } else {
      alignment = axis.position == Align2.end ? Alignment.centerLeft : Alignment.centerRight;
    }
    TextDrawInfo config = TextDrawInfo(tmp, align: alignment);
    axisPointer.labelStyle.draw(canvas, paint, dt, config);
    canvas.restore();
  }

  ///计算AxisPointer的距离
  double computeAxisPointerDis(AxisPointer axisPointer, Offset offset) {
    Offset scroll = coord.getTranslation();
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
    Rect clipRect;
    double w = axis.axisLine.width;
    if (direction == Direction.horizontal) {
      //X轴
      double left = scroll.dx.abs() + box.left;
      if (axis.position == Align2.start) {
        clipRect = Rect.fromLTWH(left, 0, box.width, coord.height);
      } else {
        clipRect = Rect.fromLTWH(left, 0, box.width, coord.height);
      }
    } else {
      //Y轴
      double top = box.top + scroll.dy;
      if (axis.position == Align2.end) {
        clipRect = Rect.fromLTWH(box.right - w, top, coord.width + w, box.height);
      } else {
        clipRect = Rect.fromLTWH(0, top, coord.width + 1, box.height);
      }
    }
    return clipRect;
  }

  List<int> computeIndex(num distance, int tickCount, num interval) {
    Rect rect = coord.contentBox;
    int startIndex, endIndex;
    if (direction == Direction.horizontal) {
      //X 轴
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

    //Y轴
    if (distance <= rect.height) {
      startIndex = 0;
      endIndex = tickCount;
    } else {
      double scroll = coord.scrollYOffset.abs();
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
}
