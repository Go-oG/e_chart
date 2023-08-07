import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import 'axis/base_grid_axis_impl.dart';

///实现二维坐标系
class GridCoordImpl extends GridCoord {
  final Map<XAxis, XAxisImpl> xMap = {};
  final Map<YAxis, YAxisImpl> yMap = {};

  GridCoordImpl(super.props);

  @override
  void onCreate() {
    super.onCreate();
    xMap.clear();
    yMap.clear();
    each(props.xAxisList, (ele, p1) {
      xMap[ele] = XAxisImpl(Direction.horizontal, context, this, ele, axisIndex: p1);
    });
    each(props.yAxisList, (axis, p1) {
      yMap[axis] = YAxisImpl(Direction.vertical, context, this, axis, axisIndex: p1);
    });
  }

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    Size size = Size(parentWidth, parentHeight);
    var lp = layoutParams.padding;
    double w = parentWidth - lp.horizontal;
    double h = parentHeight - lp.vertical;
    xMap.forEach((key, value) {
      value.doMeasure(w, h);
    });
    yMap.forEach((key, value) {
      value.doMeasure(w, h);
    });
    for (var child in children) {
      child.measure(w, h);
    }
    return size;
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    var lp = layoutParams.padding;
    double topOffset = lp.top;
    double bottomOffset = lp.bottom;
    double leftOffset = lp.left;
    double rightOffset = lp.right;

    ///计算所有X轴在竖直方向上的占用的高度
    List<XAxisImpl> topList = [];
    List<XAxisImpl> bottomList = [];
    for (var ele in props.xAxisList) {
      if (ele.position == Align2.start) {
        topList.add(xMap[ele]!);
      } else {
        bottomList.add(xMap[ele]!);
      }
    }
    topOffset += computeSize(topList, false);
    bottomOffset += computeSize(bottomList, false);

    ///计算所有Y轴在横向方向上的占用的宽度
    List<YAxisImpl> leftList = [];
    List<YAxisImpl> rightList = [];
    for (var ele in props.yAxisList) {
      var axis = yMap[ele]!;
      if (ele.position == Align2.end) {
        rightList.add(axis);
      } else {
        leftList.add(axis);
      }
    }
    leftOffset += computeSize(leftList, true);
    rightOffset += computeSize(rightList, true);

    double axisWith = width - (rightOffset + leftOffset);
    double axisHeight = height - (topOffset + bottomOffset);
    contentBox = Rect.fromLTWH(leftOffset, topOffset, axisWith, axisHeight);
    List<GridChild> childList = getGridChildList();

    ///布局X轴
    layoutXAxis(childList, contentBox);

    ///布局Y轴
    layoutYAxis(childList, contentBox);

    ///修正由于坐标系线条宽度导致的遮挡
    topOffset = topList.isEmpty ? 0 : topList.first.axis.axisLine.width / 2;
    bottomOffset = bottomList.isEmpty ? 0 : bottomList.first.axis.axisLine.width / 2;
    leftOffset = leftList.isEmpty ? 0 : leftList.first.axis.axisLine.width / 2;
    rightOffset = rightList.isEmpty ? 0 : rightList.first.axis.axisLine.width / 2;
    for (var view in children) {
      double ll = contentBox.left + leftOffset;
      double tt = contentBox.top + topOffset;
      double rr, bb;
      if (view.layoutParams.width.isMatch) {
        rr = contentBox.right - rightOffset;
      } else {
        rr = ll + view.width;
      }

      if (view.layoutParams.height.isMatch) {
        bb = contentBox.bottom - bottomOffset;
      } else {
        bb = tt + view.height;
      }
      view.layout(ll, tt, rr, bb);
    }
  }

  void layoutXAxis(List<GridChild> childList, Rect contentBox) {
    List<XAxisImpl> topList = [];
    List<XAxisImpl> bottomList = [];

    bool needAlignTick = false;

    ///收集数据信息
    Map<XAxisImpl, List<DynamicData>> extremeMap = {};
    for (var ele in props.xAxisList) {
      var axis = xMap[ele]!;
      if (ele.position == Align2.start) {
        topList.add(xMap[ele]!);
      } else {
        bottomList.add(xMap[ele]!);
      }
      if (axis.axis.alignTicks) {
        needAlignTick = true;
      }
      List<DynamicData> dl = [];
      for (var child in childList) {
        dl.addAll(child.getAxisExtreme(axis.axisIndex, true));
      }
      extremeMap[axis] = dl;
    }

    ///确定宽度
    final w = contentBox.width;
    double maxWidth = w;
    for (var ele in props.xAxisList) {
      var axis = xMap[ele]!;
      var dl = extremeMap[axis] ?? [];
      var tmpScale = BaseAxisImpl.toScale(axis.axis, [0, 100], dl, null);
      if (tmpScale.isCategory) {
        int c = tmpScale.domain.length;
        if (maxWidth / c < 40) {
          maxWidth = c * 40;
        }
      } else if (tmpScale.isTime) {
        int c = tmpScale.tickCount - 1;
        if (c <= 0) {
          continue;
        }
        if (maxWidth / c < 8) {
          maxWidth = c * 8;
        }
      } else {
        var scale = tmpScale as LinearScale;
        num c = (scale.domain[0] - scale.domain[1]).abs();
        if (c <= 0) {
          continue;
        }
        if (maxWidth / c < 2) {
          maxWidth = c * 2;
        }
      }
    }
    double scale = 1;
    if (maxWidth > w) {
      scale = maxWidth / w;
    }
    scaleXFactor = scale;

    int? splitCount;
    double topOffset = contentBox.top;
    each(topList, (value, i) {
      var axisInfo = value.axisInfo;
      List<DynamicData> dl = extremeMap[value] ?? [];
      var h = axisInfo.bound.height;
      Rect rect = Rect.fromLTWH(contentBox.left, topOffset - h, contentBox.width, h);
      var attrs = LineAxisAttrs(scaleYFactor, scrollYOffset, rect, rect.bottomRight, rect.topRight, splitCount: splitCount);
      topOffset -= (h + value.axis.offset);
      value.doLayout(attrs, dl);
      if (needAlignTick && i == 0) {
        splitCount = value.scale.tickCount - 1;
      }
    });

    double bottomOffset = contentBox.bottom;
    each(bottomList, (value, i) {
      var axisInfo = value.axisInfo;
      List<DynamicData> dl = extremeMap[value] ?? [];
      var h = axisInfo.bound.height;
      Rect rect = Rect.fromLTWH(contentBox.left, bottomOffset, contentBox.width, h);
      var attrs = LineAxisAttrs(
        scale,
        scrollXOffset,
        rect,
        rect.topLeft.translate(0, -1),
        rect.topRight.translate(0, -1),
        splitCount: splitCount,
      );
      bottomOffset += (h + value.axis.offset);
      value.doLayout(attrs, dl);

      if (needAlignTick && splitCount == null && i == 0) {
        splitCount = value.scale.tickCount - 1;
      }
    });
  }

  void layoutYAxis(List<GridChild> childList, Rect contentBox) {
    List<YAxisImpl> leftList = [];
    List<YAxisImpl> rightList = [];
    Map<YAxisImpl, List<DynamicData>> extremeMap = {};

    bool needAlignTick = false;
    for (var ele in props.yAxisList) {
      var axis = yMap[ele]!;
      if (ele.position == Align2.end) {
        rightList.add(axis);
      } else {
        leftList.add(axis);
      }
      if (axis.axis.alignTicks) {
        needAlignTick = true;
      }
      List<DynamicData> dl = [];
      for (var child in childList) {
        var da = child.getAxisExtreme(axis.axisIndex, false);
        dl.addAll(da);
      }
      extremeMap[axis] = dl;
    }

    int? splitCount;
    double rightOffset = contentBox.left;
    each(leftList, (value, i) {
      List<DynamicData> dl = extremeMap[value] ?? [];
      if (i != 0) {
        rightOffset -= value.axis.offset;
      }
      double w = value.axisInfo.bound.width;
      Rect rect = Rect.fromLTRB(rightOffset - w, contentBox.top, rightOffset, contentBox.bottom);
      var attrs = LineAxisAttrs(scaleYFactor, scrollYOffset, rect, rect.bottomRight, rect.topRight, splitCount: splitCount);
      rightOffset -= w;
      value.doLayout(attrs, dl);
      if (needAlignTick && i == 0) {
        splitCount = value.scale.tickCount - 1;
      }
    });

    double leftOffset = contentBox.right;
    each(rightList, (value, i) {
      List<DynamicData> dl = extremeMap[value] ?? [];
      if (i != 0) {
        leftOffset += value.axis.offset;
      }
      double w = value.axisInfo.bound.width;
      Rect rect = Rect.fromLTWH(leftOffset, contentBox.top, w, contentBox.height);
      var attrs = LineAxisAttrs(scaleYFactor, scrollYOffset, rect, rect.bottomLeft, rect.topLeft, splitCount: splitCount);

      leftOffset += w;
      value.doLayout(attrs, dl);
      if (needAlignTick && splitCount == null && i == 0) {
        splitCount = value.scale.tickCount - 1;
      }
    });
  }

  @override
  void onDraw(Canvas canvas) {
    xMap.forEach((key, value) {
      value.draw(canvas, mPaint, contentBox);
    });
    yMap.forEach((key, value) {
      value.draw(canvas, mPaint, contentBox);
    });
  }

  @override
  void onDrawEnd(Canvas canvas) {
    super.onDrawEnd(canvas);
    var offset = _axisPointerOffset;
    if (offset == null) {
      return;
    }
    xMap.forEach((key, value) {
      value.onDrawAxisPointer(canvas, mPaint, offset);
    });
    yMap.forEach((key, value) {
      value.onDrawAxisPointer(canvas, mPaint, offset);
    });
  }

  @override
  void onDragMove(Offset offset, Offset diff) {
    if (!contentBox.contains(offset)) {
      return;
    }
    var sx = diff.dx + scrollXOffset;
    var sy = diff.dy + scrollYOffset;

    Offset maxOffset = getMaxTranslation();
    if (sx.abs() > maxOffset.dx) {
      sx = -maxOffset.dx;
    }
    if (sx > 0) {
      sx = 0;
    }
    bool hasChange = false;
    if (sx != scrollXOffset) {
      hasChange = true;
      scrollXOffset = sx;
      xMap.forEach((key, value) {
        value.attrs.scroll = sx;
        value.onScrollChange(sx);
      });
    }

    if (sy.abs() > maxOffset.dy) {
      sy = maxOffset.dy;
    }
    if (sy < 0) {
      sy = 0;
    }
    if (sy != scrollYOffset) {
      hasChange = true;
      scrollYOffset = sy;
      yMap.forEach((key, value) {
        value.attrs.scroll = sy;
        value.onScrollChange(sy);
      });
    }

    if (hasChange) {
      Offset offset = Offset(scrollXOffset, scrollYOffset);
      each(children, (p0, p1) {
        if (p0 is CoordChildView) {
          p0.onContentScrollUpdate(offset);
        }
      });
    }

    invalidate();
  }

  @override
  void onDragEnd() {
    Offset offset = Offset(scrollXOffset, scrollYOffset);
    for (var child in children) {
      if (child is CoordChildView) {
        child.onContentScrollEnd(offset);
      }
    }
  }

  @override
  void onScaleUpdate(Offset offset, double rotation, double scale, bool doubleClick) {
    if (!contentBox.contains(offset)) {
      return;
    }
    var sx = scaleXFactor + scale;
    if (sx < 0.001) {
      sx = 0.001;
    }
    if (sx > 100) {
      sx = 100;
    }
    if (sx == scaleXFactor) {
      return;
    }
    scaleXFactor = sx;
    xMap.forEach((key, value) {});

    invalidate();
  }

  Offset? _axisPointerOffset;

  @override
  void onHoverStart(Offset offset) {
    super.onHoverStart(offset);
    if (needInvalidateAxisPointer(false)) {
      _axisPointerOffset = offset.translate(scrollXOffset.abs(), scrollYOffset);
      invalidate();
    }
  }

  @override
  void onHoverMove(Offset offset, Offset last) {
    super.onHoverMove(offset, last);
    if (needInvalidateAxisPointer(false)) {
      _axisPointerOffset = offset.translate(scrollXOffset.abs(), scrollYOffset);
      invalidate();
    }
  }

  @override
  void onHoverEnd() {
    super.onHoverEnd();
    if (needInvalidateAxisPointer(false)) {
      _axisPointerOffset = null;
      invalidate();
    }
  }

  @override
  void onClick(Offset offset) {
    super.onClick(offset);
    if (needInvalidateAxisPointer(true)) {
      _axisPointerOffset = offset.translate(scrollXOffset.abs(), scrollYOffset);
      if (!contentBox.contains(offset)) {
        _axisPointerOffset = null;
      }
      invalidate();
    }
  }

  bool needInvalidateAxisPointer(bool click) {
    for (var entry in xMap.entries) {
      var axisPointer = entry.value.axis.axisPointer;
      if (axisPointer == null || !axisPointer.show) {
        continue;
      }
      if (axisPointer.triggerOn == TriggerOn.none) {
        continue;
      }
      if (axisPointer.triggerOn == TriggerOn.moveAndClick) {
        return true;
      }
      if (click && axisPointer.triggerOn == TriggerOn.click) {
        return true;
      }
      if (!click && axisPointer.triggerOn == TriggerOn.mouseMove) {
        return true;
      }
    }
    for (var entry in yMap.entries) {
      var axisPointer = entry.value.axis.axisPointer;
      if (axisPointer == null || !axisPointer.show) {
        continue;
      }
      if (axisPointer.triggerOn == TriggerOn.none) {
        continue;
      }
      if (axisPointer.triggerOn == TriggerOn.moveAndClick) {
        return true;
      }
      if (click && axisPointer.triggerOn == TriggerOn.click) {
        return true;
      }
      if (!click && axisPointer.triggerOn == TriggerOn.mouseMove) {
        return true;
      }
    }
    return false;
  }

  @override
  List<GridChild> getGridChildList() {
    List<GridChild> list = [];
    for (var child in children) {
      if (child is GridChild) {
        list.add(child as GridChild);
      }
    }
    return list;
  }

  @override
  Rect dataToRect(int xAxisIndex, DynamicData x, int yAxisIndex, DynamicData y) {
    List<Offset> dx = getXAxis(xAxisIndex).dataToPoint(x);
    List<Offset> dy = getYAxis(yAxisIndex).dataToPoint(y);
    double l = dx[0].dx;
    double t = dy[0].dy;
    double r = dx.length >= 2 ? dx[1].dx : l + 1;
    double b = dy.length >= 2 ? dy[1].dy : t + 1;
    return Rect.fromLTRB(l, t, r, b);
  }

  @override
  Offset dataToPoint(int xAxisIndex, DynamicData x, int yAxisIndex, DynamicData y) {
    List<Offset> dx = getXAxis(xAxisIndex).dataToPoint(x);
    List<Offset> dy = getYAxis(yAxisIndex).dataToPoint(y);
    return Offset(dx[0].dx, dy[0].dy);
  }

  @override
  GridAxis getAxis(int axisIndex, bool isXAxis) {
    if (axisIndex < 0) {
      axisIndex = 0;
    }
    if (isXAxis) {
      return getXAxis(axisIndex).axis;
    }
    return getYAxis(axisIndex).axis;
  }

  @override
  double getAxisLength(int axisIndex, bool isXAxis) {
    var axis = isXAxis ? getXAxis(axisIndex) : getYAxis(axisIndex);
    return axis.getLength();
  }

  @override
  BaseScale<dynamic, num> getScale(int axisIndex, bool isXAxis) {
    if (isXAxis) {
      return getXAxis(axisIndex).scale;
    }
    return getYAxis(axisIndex).scale;
  }

  @override
  Offset getMaxTranslation() {
    double dx = 0;
    xMap.forEach((key, value) {
      List<num> rv = value.scale.range;
      double diff = (rv[0] - rv[1]).abs().toDouble();
      if (diff > contentBox.width) {
        diff = diff - contentBox.width;
        if (diff > dx) {
          dx = diff;
        }
      }
    });
    double dy = 0;
    yMap.forEach((key, value) {
      List<num> rv = value.scale.range;
      double diff = (rv[0] - rv[1]).abs().toDouble();
      if (diff > contentBox.height) {
        diff = diff - contentBox.height;
        if (diff > dy) {
          dy = diff;
        }
      }
    });
    return Offset(dx, dy);
  }

  @override
  double getBottomFirstAxisHeight() {
    XAxis? xAxis;
    for (var axis in props.xAxisList) {
      if (axis.position != Align2.start) {
        xAxis = axis;
        break;
      }
    }
    if (xAxis == null) {
      return 0;
    }

    return xMap[xAxis]!.attrs.rect.height;
  }

  @override
  double getTopFirstAxisHeight() {
    XAxis? xAxis;
    for (var axis in props.xAxisList) {
      if (axis.position == Align2.start) {
        xAxis = axis;
        break;
      }
    }
    if (xAxis == null) {
      return 0;
    }
    return xMap[xAxis]!.attrs.rect.height;
  }

  @override
  double getLeftFirstAxisWidth() {
    YAxis? yAxis;
    for (var axis in props.yAxisList) {
      if (axis.position != Align2.end) {
        yAxis = axis;
        break;
      }
    }
    if (yAxis == null) {
      return 0;
    }
    return yMap[yAxis]!.attrs.rect.width;
  }

  @override
  double getRightFirstAxisWidth() {
    YAxis? yAxis;
    for (var axis in props.yAxisList) {
      if (axis.position == Align2.end) {
        yAxis = axis;
        break;
      }
    }
    if (yAxis == null) {
      return 0;
    }
    return yMap[yAxis]!.attrs.rect.width;
  }

  XAxisImpl getXAxis(int xAxisIndex) {
    if (xAxisIndex < 0) {
      xAxisIndex = 0;
    }
    return xMap[props.xAxisList[xAxisIndex]]!;
  }

  YAxisImpl getYAxis(int yAxisIndex) {
    if (yAxisIndex < 0) {
      yAxisIndex = 0;
    }
    return yMap[props.yAxisList[yAxisIndex]]!;
  }

  double computeSize(List<BaseGridAxisImpl> axisList, bool computeWidth) {
    double size = 0;
    each(axisList, (axis, i) {
      if (computeWidth) {
        size += axis.axisInfo.bound.width;
      } else {
        size += axis.axisInfo.bound.height;
      }
      if (i != 0) {
        size += axis.axis.offset;
      }
    });
    return size;
  }
}

abstract class GridCoord extends CoordLayout<Grid> {
  GridCoord(super.props);

  ///该方法适用于Bar
  Rect dataToRect(int xAxisIndex, DynamicData x, int yAxisIndex, DynamicData y);

  ///该方法适用于Line
  Offset dataToPoint(int xAxisIndex, DynamicData x, int yAxisIndex, DynamicData y);

  GridAxis getAxis(int axisIndex, bool isXAxis);

  double getLeftFirstAxisWidth();

  double getRightFirstAxisWidth();

  double getTopFirstAxisHeight();

  double getBottomFirstAxisHeight();

  ///获取比例尺
  BaseScale getScale(int axisIndex, bool isXAxis);

  double getAxisLength(int axisIndex, bool isXAxis);

  List<GridChild> getGridChildList();
}
