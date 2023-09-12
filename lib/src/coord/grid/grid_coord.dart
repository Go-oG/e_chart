import 'dart:math';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'axis/grid_axis_impl.dart';

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
    layoutXAxis(childList, contentBox, false, true);

    ///布局Y轴
    layoutYAxis(childList, contentBox, false, true);

    viewPort.width = contentBox.width;
    viewPort.height = contentBox.height;
    viewPort.contentWidth = 0;
    viewPort.contentHeight = 0;
    xMap.forEach((key, value) {
      if (value.attrs.distance > viewPort.contentWidth) {
        viewPort.contentWidth = value.attrs.distance;
      }
    });
    yMap.forEach((key, value) {
      if (value.attrs.distance > viewPort.contentHeight) {
        viewPort.contentHeight = value.attrs.distance;
      }
    });

    ///修正由于坐标系线条宽度导致的遮挡
    topOffset = topList.isEmpty ? 0 : topList.first.axis.axisLine.width / 2;
    bottomOffset = bottomList.isEmpty ? 0 : bottomList.first.axis.axisLine.width / 2;
    leftOffset = leftList.isEmpty ? 0 : leftList.first.axis.axisLine.width / 2;
    rightOffset = rightList.isEmpty ? 0 : rightList.first.axis.axisLine.width / 2;
    double ll = contentBox.left + leftOffset;
    double tt = contentBox.top + topOffset;

    for (var view in children) {
      double rr, bb;
      if (view.layoutParams.width.isMatch) {
        rr = contentBox.right;
      } else {
        rr = ll + view.width;
      }
      if (view.layoutParams.height.isMatch) {
        bb = contentBox.bottom;
      } else {
        bb = tt + view.height;
      }
      view.layout(ll, tt, rr, bb);
    }
  }

  void layoutXAxis(List<GridChild> childList, Rect contentBox, bool useViewPortExtreme, bool force) {
    List<XAxisImpl> topList = [];
    List<XAxisImpl> bottomList = [];
    bool needAlignTick = false;

    ///收集数据信息
    Map<XAxisImpl, List<dynamic>> extremeMap = {};
    for (var ele in props.xAxisList) {
      var axis = xMap[ele]!;
      if (ele.position == Align2.start) {
        topList.add(axis);
      } else {
        bottomList.add(axis);
      }
      if (axis.axis.alignTicks) {
        needAlignTick = true;
      }
      List<dynamic> dl = [];
      for (var child in childList) {
        var rl = useViewPortExtreme
            ? child.getViewPortAxisExtreme(axis.axisIndex, true, axis.scale)
            : child.getAxisExtreme(axis.axisIndex, true);
        dl.addAll(rl);
      }
      extremeMap[axis] = dl;
    }
    scale.dx = props.baseXScale;

    int? splitCount;
    double topOffset = contentBox.top;
    each(topList, (value, i) {
      var axisInfo = value.axisInfo;
      var h = axisInfo.bound.height;
      Rect rect = Rect.fromLTWH(contentBox.left, topOffset - h, contentBox.width, h);
      var attrs = LineAxisAttrs(scaleX, scrollX, rect, rect.bottomLeft, rect.bottomRight, splitCount: splitCount);
      topOffset -= (h + value.axis.offset);
      value.doLayout(attrs, extremeMap[value] ?? []);
      if (needAlignTick && i == 0) {
        splitCount = value.scale.tickCount - 1;
      }
    });

    double bottomOffset = contentBox.bottom;
    each(bottomList, (value, i) {
      var axisInfo = value.axisInfo;
      var h = axisInfo.bound.height;
      Rect rect = Rect.fromLTWH(contentBox.left, bottomOffset, contentBox.width, h);
      var attrs = LineAxisAttrs(scaleX, scrollX, rect, rect.topLeft.translate(0, -1), rect.topRight.translate(0, -1),
          splitCount: splitCount);
      bottomOffset += (h + value.axis.offset);
      value.doLayout(attrs, extremeMap[value] ?? []);

      if (needAlignTick && splitCount == null && i == 0) {
        splitCount = value.scale.tickCount - 1;
      }
    });
  }

  void layoutYAxis(List<GridChild> childList, Rect contentBox, bool useViewPortExtreme, bool force) {
    List<YAxisImpl> leftList = [];
    List<YAxisImpl> rightList = [];
    Map<YAxisImpl, List<dynamic>> extremeMap = {};

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
      List<dynamic> dl = [];
      for (var child in childList) {
        var rl = useViewPortExtreme
            ? child.getViewPortAxisExtreme(axis.axisIndex, false, axis.scale)
            : child.getAxisExtreme(axis.axisIndex, false);
        dl.addAll(rl);
      }
      extremeMap[axis] = dl;
    }
    scale.dy = props.baseYScale;
    int? splitCount;
    double rightOffset = contentBox.left;
    each(leftList, (value, i) {
      List<dynamic> dl = extremeMap[value] ?? [];
      if (i != 0) {
        rightOffset -= value.axis.offset;
      }
      double w = value.axisInfo.bound.width;
      Rect rect = Rect.fromLTRB(rightOffset - w, contentBox.top, rightOffset, contentBox.bottom);
      var attrs = LineAxisAttrs(scaleY, scrollY, rect, rect.bottomRight, rect.topRight, splitCount: splitCount);
      rightOffset -= w;
      if (!force && useViewPortExtreme && dl.length >= 2 && value.scale.isNum) {
        dl.sort();
        if (value.scale.domain.first == dl.first && value.scale.domain.last == dl.last) {
        } else {
          value.doLayout(attrs, dl);
        }
      } else {
        value.doLayout(attrs, dl);
      }

      if (needAlignTick && i == 0) {
        splitCount = value.scale.tickCount - 1;
      }
    });

    double leftOffset = contentBox.right;
    each(rightList, (value, i) {
      List<dynamic> dl = extremeMap[value] ?? [];
      if (i != 0) {
        leftOffset += value.axis.offset;
      }
      double w = value.axisInfo.bound.width;
      Rect rect = Rect.fromLTWH(leftOffset, contentBox.top, w, contentBox.height);
      var attrs = LineAxisAttrs(scaleY, scrollY, rect, rect.bottomLeft, rect.topLeft, splitCount: splitCount);
      leftOffset += w;
      value.doLayout(attrs, dl);
      if (needAlignTick && splitCount == null && i == 0) {
        splitCount = value.scale.tickCount - 1;
      }
    });
  }

  @override
  void onChildDataSetChange(bool layoutChild) {
    List<GridChild> childList = getGridChildList();

    ///布局X轴
    layoutXAxis(childList, contentBox, false, true);

    ///布局Y轴
    layoutYAxis(childList, contentBox, false, true);
    if (!layoutChild) {
      return;
    }
    for (var view in children) {
      view.setForceLayout();
      view.layout(view.left, view.top, view.right, view.bottom);
    }
  }

  @override
  void onAdjustAxisDataRange(AdjustAttr attr) {
    if (attr.xAxis) {
      layoutXAxis(getGridChildList(), contentBox, true, false);
    } else {
      layoutYAxis(getGridChildList(), contentBox, true, false);
    }
    for (var view in children) {
      view.onLayoutByParent(LayoutType.none);
    }
  }

  @override
  void onDraw(CCanvas canvas) {
    xMap.forEach((key, value) {
      value.draw(canvas, mPaint, contentBox);
    });
    yMap.forEach((key, value) {
      value.draw(canvas, mPaint, contentBox);
    });
  }

  @override
  void onDrawEnd(CCanvas canvas) {
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
    Offset old = viewPort.getTranslation();
    Offset sc = viewPort.scroll(diff);
    bool hasChange = false;
    if (sc.dx != old.dx) {
      hasChange = true;
      xMap.forEach((key, value) {
        value.attrs.scroll = sc.dx;
        value.onScrollChange(sc.dx);
      });
    }
    if (sc.dy != old.dy) {
      hasChange = true;
      yMap.forEach((key, value) {
        value.attrs.scroll = sc.dy;
        value.onScrollChange(sc.dy);
      });
    }
    if (!hasChange) {
      return;
    }
    var cs = CoordScroll(props.id, props.coordSystem, sc);
    each(children, (p0, p1) {
      if (p0 is CoordChildView) {
        p0.onCoordScrollUpdate(cs);
      }
    });
    invalidate();
  }

  @override
  void onDragEnd() {
    var cs = CoordScroll(props.id, props.coordSystem, viewPort.getTranslation());
    for (var child in children) {
      if (child is CoordChildView) {
        child.onCoordScrollEnd(cs);
      }
    }
  }

  @override
  void onScaleUpdate(Offset offset, double rotation, double scale, bool doubleClick) {
    if (!contentBox.contains(offset)) {
      return;
    }
    var sx = scaleX + scale * cos(rotation);
    if (sx < 0.001) {
      sx = 0.001;
    }
    if (sx > 100) {
      sx = 100;
    }
    bool hasChange = false;
    if (sx != scaleX) {
      hasChange = true;
      this.scale.dx = sx;
      xMap.forEach((key, value) {
        value.onAttrsChange(value.attrs.copyWith(scaleRatio: scaleX));
      });
    }
    var sy = scaleY + scale * sin(rotation);
    if (sy < 0.001) {
      sy = 0.001;
    }
    if (sy > 100) {
      sy = 100;
    }
    if (sy != scaleY) {
      hasChange = true;
      this.scale.dy = sy;
      yMap.forEach((key, value) {
        value.onAttrsChange(value.attrs.copyWith(scaleRatio: sy));
      });
    }
    if (hasChange) {
      each(children, (p0, p1) {
        if (p0 is CoordChildView) {
          p0.onCoordScaleUpdate(this.scale);
        }
      });
      invalidate();
    }
  }

  Offset? _axisPointerOffset;

  @override
  void onHoverStart(Offset offset) {
    super.onHoverStart(offset);
    if (needInvalidateAxisPointer(false)) {
      _axisPointerOffset = offset.translate(scrollX.abs(), scrollY.abs());
      invalidate();
    }
  }

  @override
  void onHoverMove(Offset offset, Offset last) {
    super.onHoverMove(offset, last);
    if (needInvalidateAxisPointer(false)) {
      _axisPointerOffset = offset.translate(scrollX.abs(), scrollY.abs());
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
      _axisPointerOffset = offset.translate(scrollX.abs(), scrollY.abs());
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
  Rect dataToRect(int xAxisIndex, dynamic x, int yAxisIndex, dynamic y) {
    List<Offset> dx = getXAxis(xAxisIndex).dataToPoint(x);
    List<Offset> dy = getYAxis(yAxisIndex).dataToPoint(y);
    double l = dx[0].dx;
    double t = dy[0].dy;
    double r = dx.length >= 2 ? dx[1].dx : l + 1;
    double b = dy.length >= 2 ? dy[1].dy : t + 1;
    return Rect.fromLTRB(l, t, r, b);
  }

  @override
  List<Offset> dataToPoint(int axisIndex, dynamic data, bool xAxis) {
    var axis = xAxis ? getXAxis(axisIndex) : getYAxis(axisIndex);
    return axis.dataToPoint(data);
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

  @override
  RangeInfo getViewportDataRange(int axisIndex, bool isXAxis) {
    if (axisIndex < 0) {
      axisIndex = 0;
    }
    BaseGridAxisImpl axisImpl;
    if (isXAxis) {
      if (axisIndex > props.xAxisList.length) {
        throw ChartError("越界");
      }
      axisImpl = xMap[props.xAxisList[axisIndex]]!;
    } else {
      if (axisIndex > props.yAxisList.length) {
        throw ChartError("越界");
      }
      axisImpl = yMap[props.yAxisList[axisIndex]]!;
    }
    return axisImpl.getViewportDataRange();
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

  @override
  dynamic pxToData(int axisIndex, bool xAxis, num position) {
    if (axisIndex < 0) {
      axisIndex = 0;
    }
    var axis = xAxis ? props.xAxisList[axisIndex] : props.yAxisList[axisIndex];
    var axisImpl = xAxis ? xMap[axis]! : yMap[axis]!;
    return axisImpl.pxToData(position);
  }

  @override
  double getMaxXScroll() {
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
    return dx;
  }

  @override
  double getMaxYScroll() {
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
    return dy;
  }
}

abstract class GridCoord extends CoordLayout<Grid> {
  GridCoord(super.props);

  ///获取指定坐标轴在当前窗口显示的数据范围
  RangeInfo getViewportDataRange(int axisIndex, bool isXAxis);

  ///该方法适用于Bar
  Rect dataToRect(int xAxisIndex, dynamic x, int yAxisIndex, dynamic y);

  dynamic pxToData(int axisIndex, bool xAxis, num position);

  ///该方法适用于Line
  List<Offset> dataToPoint(int axisIndex, dynamic data, bool xAxis);

  GridAxis getAxis(int axisIndex, bool isXAxis);

  double getLeftFirstAxisWidth();

  double getRightFirstAxisWidth();

  double getTopFirstAxisHeight();

  double getBottomFirstAxisHeight();

  ///获取比例尺
  BaseScale getScale(int axisIndex, bool isXAxis);

  double getAxisLength(int axisIndex, bool isXAxis);

  List<GridChild> getGridChildList();

  ///=====下面的方法由子视图回调
  ///当子视图的数据集发生改变时需要重新布局确定坐标系
  void onChildDataSetChange(bool layoutChild);

  ///当子视图需要实现动态坐标轴时回调该方法
  void onAdjustAxisDataRange(AdjustAttr attr);
}
