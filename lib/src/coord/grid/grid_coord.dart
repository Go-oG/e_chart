import 'dart:math' as m;

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///实现二维坐标系
class GridCoordImpl extends GridCoord {
  final Map<XAxis, XAxisImpl> xMap = {};
  final Map<YAxis, YAxisImpl> yMap = {};

  GridCoordImpl(super.context, super.props) {
    layoutParams = LayoutParams.matchAll();
    each(props.xAxisList, (ele, p1) {
      var view = XAxisImpl(Direction.horizontal, this, context, ele, axisIndex: p1);
      addView(view);
      xMap[ele] = view;
    });
    each(props.yAxisList, (axis, p1) {
      var view = YAxisImpl(Direction.vertical, this, context, axis, axisIndex: p1);
      yMap[axis] = view;
      addView(view);
    });
  }

  @override
  void onDispose() {
    xMap.forEach((key, value) {
      value.dispose();
    });
    yMap.forEach((key, value) {
      value.dispose();
    });
    xMap.clear();
    yMap.clear();
    super.onDispose();
  }

  @override
  Size onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec) {
    var parentWidth = widthSpec.size;
    var parentHeight = heightSpec.size;

    ///赋值MaxStr
    xMap.forEach((key, value) {
      value.attrs.maxStr = getMaxStr(value.direction, value.axisIndex);
    });
    yMap.forEach((key, value) {
      value.attrs.maxStr = getMaxStr(value.direction, value.axisIndex);
    });

    var lp = layoutParams;
    double pw = lp.width.convert(parentWidth - layoutParams.hPadding);
    double ph = lp.height.convert(parentHeight - layoutParams.vPadding);
    double maxW = 0;
    double maxH = 0;
    var ws = MeasureSpec.exactly(pw);
    var hs = MeasureSpec.exactly(ph);
    for (var child in children) {
      child.measure(ws, hs);
      maxW = m.max(maxW, child.width);
      maxH = m.max(maxH, child.height);
    }
    return Size(parentWidth, parentHeight);
  }

  @override
  void onLayout(bool changed, double left, double top, double right, double bottom) {
    double topOffset = layoutParams.topPadding;
    double bottomOffset = layoutParams.bottomPadding;
    double leftOffset = layoutParams.leftPadding;
    double rightOffset = layoutParams.rightPadding;

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
    List<CoordChild> childList = getCoordChildList();

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

  ///布局X轴
  void layoutXAxis(List<CoordChild> childList, Rect contentBox, bool useViewPortExtreme, bool force) {
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
        var dim = GridAxisDim(true, axis.axisIndex);
        var rl = useViewPortExtreme
            ? child.getViewPortAxisExtreme(coordType, dim, axis.axisScale)
            : child.getAxisExtreme(coordType, dim);
        dl.addAll(rl);
      }
      extremeMap[axis] = dl;
    }
    scaleX = props.baseXScale;
    int? splitCount;
    double topOffset = contentBox.top;
    each(topList, (value, i) {
      var h = value.axisSize;
      var rect = Rect.fromLTWH(contentBox.left, topOffset - h, contentBox.width, h);
      var attrs = value.attrs.copy() as GridAxisAttr;
      attrs.scrollX = viewPort.scrollX;
      attrs.splitCount = splitCount;
      attrs.start = rect.bottomLeft;
      attrs.end = rect.bottomRight;
      attrs.rect = rect;
      topOffset -= (h + value.axis.offset);

      value.updateAttr(attrs, extremeMap[value] ?? []);
      value.layout(rect.left, rect.top, rect.right, rect.bottom);

      if (needAlignTick && i == 0) {
        splitCount = value.axisScale.tickCount - 1;
      }
    });

    double bottomOffset = contentBox.bottom;
    each(bottomList, (value, i) {
      var h = value.axisSize;
      var rect = Rect.fromLTWH(contentBox.left, bottomOffset, contentBox.width, h);
      var attrs = value.attrs.copy() as GridAxisAttr;
      attrs.scaleRatio = scaleX;
      attrs.scrollY = viewPort.scrollY;
      attrs.scrollX = viewPort.scrollX;
      attrs.splitCount = splitCount;
      attrs.start = rect.topLeft;
      attrs.end = rect.topRight;
      attrs.rect = rect;

      bottomOffset += (h + value.axis.offset);
      value.updateAttr(attrs, extremeMap[value] ?? []);
      value.layout(rect.left, rect.top, rect.right, rect.bottom);

      if (needAlignTick && splitCount == null && i == 0) {
        splitCount = value.axisScale.tickCount - 1;
      }
    });
  }

  void layoutYAxis(List<CoordChild> childList, Rect contentBox, bool useViewPortExtreme, bool force) {
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
        var dim = GridAxisDim(false, axis.axisIndex);
        var rl = useViewPortExtreme
            ? child.getViewPortAxisExtreme(coordType, dim, axis.axisScale)
            : child.getAxisExtreme(coordType, dim);
        dl.addAll(rl);
      }
      extremeMap[axis] = dl;
    }
    scaleY = props.baseYScale;
    int? splitCount;
    double rightOffset = contentBox.left;
    each(leftList, (value, i) {
      List<dynamic> dl = extremeMap[value] ?? [];
      if (i != 0) {
        rightOffset -= value.axis.offset;
      }
      double w = value.axisSize;
      var rect = Rect.fromLTRB(rightOffset - w, contentBox.top, rightOffset, contentBox.bottom);

      var attrs = value.attrs.copy() as GridAxisAttr;
      attrs.scaleRatio = scaleY;
      attrs.scrollY = viewPort.scrollY;
      attrs.scrollX = viewPort.scrollX;
      attrs.splitCount = splitCount;
      attrs.start = rect.bottomRight;
      attrs.end = rect.topRight;
      attrs.rect = rect;

      rightOffset -= w;
      if (!force && useViewPortExtreme && dl.length >= 2 && value.axisScale.isNum) {
        dl.sort();
        if (value.axisScale.domain.first == dl.first && value.axisScale.domain.last == dl.last) {
        } else {
          value.updateAttr(attrs, dl);
          value.layout(rect.left, rect.top, rect.right, rect.bottom);
        }
      } else {
        value.updateAttr(attrs, dl);
        value.layout(rect.left, rect.top, rect.right, rect.bottom);
      }

      if (needAlignTick && i == 0) {
        splitCount = value.axisScale.tickCount - 1;
      }
    });

    double leftOffset = contentBox.right;
    each(rightList, (value, i) {
      List<dynamic> dl = extremeMap[value] ?? [];
      if (i != 0) {
        leftOffset += value.axis.offset;
      }
      double w = value.axisSize;
      var rect = Rect.fromLTWH(leftOffset, contentBox.top, w, contentBox.height);
      var attrs = value.attrs.copy() as GridAxisAttr;
      attrs.scaleRatio = scaleY;
      attrs.scrollY = viewPort.scrollY;
      attrs.scrollX = viewPort.scrollX;
      attrs.splitCount = splitCount;
      attrs.start = rect.bottomLeft;
      attrs.end = rect.topLeft;
      attrs.rect = rect;

      leftOffset += w;

      value.updateAttr(attrs, dl);
      value.layout(rect.left, rect.top, rect.right, rect.bottom);
      if (needAlignTick && splitCount == null && i == 0) {
        splitCount = value.axisScale.tickCount - 1;
      }
    });
  }

  @override
  void onChildDataSetChange(bool layoutChild) {
    for (var view in children) {
      view.forceLayout();
    }
    onLayout(false, left, top, right, bottom);
  }

  @override
  void onRelayoutAxisByChild(bool xAxis, bool notifyInvalidate) {
    if (xAxis) {
      layoutXAxis(getCoordChildList(), contentBox, true, false);
    } else {
      layoutYAxis(getCoordChildList(), contentBox, true, false);
    }
    context.dispatchEvent(AxisChangeEvent(
        this,
        xAxis ? xMap.values.toList(growable: false) : yMap.values.toList(growable: false),
        xAxis ? Direction.horizontal : Direction.vertical));
    if (notifyInvalidate) {
      requestDraw();
    }
  }

  @override
  void onDraw(CCanvas canvas) {
    xMap.forEach((key, value) {
      value.draw(canvas);
    });
    yMap.forEach((key, value) {
      value.draw(canvas);
    });
  }

  void onDrawEnd(CCanvas canvas) {
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

    if (diff.dx != 0 && diff.dy != 0) {
      throw ChartError("只支持在一个方向滚动");
    }

    Offset old = viewPort.translation;
    Offset sc = viewPort.scroll(diff);

    if (sc.dx != old.dx || sc.dy != old.dy) {
      xMap.forEach((key, value) {
        value.attrs.scrollX = sc.dx;
        value.syncScroll(CoordType.grid, sc.dx, sc.dy);
      });
      yMap.forEach((key, value) {
        value.attrs.scrollY = sc.dy;
        value.syncScroll(CoordType.grid, sc.dx, sc.dy);
      });

      if (diff.dx != 0) {
        context
            .dispatchEvent(AxisScrollEvent(this, xMap.values.toList(growable: false), diff.dx, Direction.horizontal));
      } else {
        context.dispatchEvent(AxisScrollEvent(this, yMap.values.toList(growable: false), diff.dy, Direction.vertical));
      }
      requestDraw();
    }
  }

  @override
  void onScaleUpdate(Offset offset, double rotation, double scale, bool doubleClick) {
    if (!contentBox.contains(offset)) {
      return;
    }
    var sx = scaleX + scale * m.cos(rotation);
    if (sx < 0.001) {
      sx = 0.001;
    }
    if (sx > 100) {
      sx = 100;
    }
    bool hasChange = false;
    if (sx != scaleX) {
      hasChange = true;
      scaleX = sx;
      xMap.forEach((key, value) {
        var old = value.attrs.copy();
        value.attrs.scaleRatio = scaleX;
        value.onAttrsChange(old as GridAxisAttr);
      });
    }
    var sy = scaleY + scale * m.sin(rotation);
    if (sy < 0.001) {
      sy = 0.001;
    }
    if (sy > 100) {
      sy = 100;
    }
    if (sy != scaleY) {
      hasChange = true;
      scaleY = sy;
      yMap.forEach((key, value) {
        var old = value.attrs.copy();
        value.attrs.scaleRatio = sy;
        value.onAttrsChange(old as GridAxisAttr);
      });
    }
    if (hasChange) {
      ///TODO 缩放更新
      // context.dispatchEvent(AxisChangeEvent(this, [], null));
      requestDraw();
    }
  }

  Offset? _axisPointerOffset;

  @override
  void onHoverStart(Offset offset) {
    super.onHoverStart(offset);
    if (needInvalidateAxisPointer(false)) {
      _axisPointerOffset = offset.translate(viewPort.scrollX.abs(), viewPort.scrollY.abs());
      requestDraw();
    }
  }

  @override
  void onHoverMove(Offset offset, Offset last) {
    super.onHoverMove(offset, last);
    if (needInvalidateAxisPointer(false)) {
      _axisPointerOffset = offset.translate(viewPort.scrollX.abs(), viewPort.scrollY.abs());
      requestDraw();
    }
  }

  @override
  void onHoverEnd() {
    super.onHoverEnd();
    if (needInvalidateAxisPointer(false)) {
      _axisPointerOffset = null;
      requestDraw();
    }
  }

  @override
  void onClick(Offset offset) {
    if (needInvalidateAxisPointer(true)) {
      _axisPointerOffset = offset.translate(viewPort.scrollX.abs(), viewPort.scrollY.abs());
      if (!contentBox.contains(offset)) {
        _axisPointerOffset = null;
      }
      requestDraw();
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
  AxisType getAxisType(int axisIndex, bool isXAxis) {
    return (isXAxis ? getXAxis(axisIndex) : getYAxis(axisIndex)).axisType;
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

  @override
  double getAxisLength(int axisIndex, bool isXAxis) {
    var axis = isXAxis ? getXAxis(axisIndex) : getYAxis(axisIndex);
    return axis.getLength();
  }

  @override
  BaseScale<dynamic, num> getScale(int axisIndex, bool isXAxis) {
    if (isXAxis) {
      return getXAxis(axisIndex).axisScale;
    }
    return getYAxis(axisIndex).axisScale;
  }

  @override
  RangeInfo getAxisViewportDataRange(int axisIndex, bool isXAxis) {
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

  double computeSize(List<BaseGridAxisImpl> axisList, bool computeWidth) {
    double size = 0;
    each(axisList, (axis, i) {
      size += axis.axisSize;
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
      List<num> rv = value.axisScale.range;
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
      List<num> rv = value.axisScale.range;
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
  List<double> getAxisLayoutOffset(bool xAxis) {
    if (xAxis) {
      //X 轴布局
      GridAxis? left;
      GridAxis? right;
      for (var axis in props.yAxisList) {
        var yAxisImpl = yMap[axis]!;
        var yAxis = yAxisImpl.axis;
        if (!yAxis.show) {
          continue;
        }
        if (yAxisImpl.attrs.rect.width <= 0) {
          continue;
        }
        if (axis.position != Align2.end && left == null) {
          left = yAxis;
        } else if (axis.position == Align2.end && right == null) {
          right = yAxis;
        }
        if (left != null && right != null) {
          break;
        }
      }
      var ls = left?.axisLine;
      var rs = right?.axisLine;
      double l = ls == null ? 0 : (ls.show ? ls.width : 0);
      double r = rs == null ? 0 : (rs.show ? rs.width : 0);
      return [l, r];
    }

    //Y 轴布局
    GridAxis? top;
    GridAxis? bottom;
    for (var axis in props.xAxisList) {
      var xAxisImpl = xMap[axis]!;
      var xAxis = xAxisImpl.axis;
      if (!xAxis.show) {
        continue;
      }
      if (xAxisImpl.attrs.rect.height <= 0) {
        continue;
      }
      if (axis.position == Align2.start && top == null) {
        top = xAxis;
      } else if (axis.position != Align2.start && bottom == null) {
        bottom = xAxis;
      }
      if (top != null && bottom != null) {
        break;
      }
    }
    var ts = top?.axisLine;
    var bs = bottom?.axisLine;
    double t = ts == null ? 0 : (ts.show ? ts.width : 0);
    double b = bs == null ? 0 : (bs.show ? bs.width : 0);

    return [t, b];
  }

  @override
  bool get freeDrag => false;
}

abstract class GridCoord extends CoordLayout<Grid> {
  GridCoord(super.context, super.props);

  ///获取指定坐标轴在当前窗口显示的数据范围
  RangeInfo getAxisViewportDataRange(int axisIndex, bool isXAxis);

  ///该方法适用于Bar
  Rect dataToRect(int xAxisIndex, dynamic x, int yAxisIndex, dynamic y);

  dynamic pxToData(int axisIndex, bool xAxis, num position);

  ///该方法适用于Line
  List<Offset> dataToPoint(int axisIndex, dynamic data, bool xAxis);

  GridAxis getAxis(int axisIndex, bool isXAxis);

  AxisType getAxisType(int axisIndex, bool isXAxis);

  double getLeftFirstAxisWidth();

  double getRightFirstAxisWidth();

  double getTopFirstAxisHeight();

  double getBottomFirstAxisHeight();

  ///获取坐标轴布局偏移量
  List<double> getAxisLayoutOffset(bool xAxis);

  ///获取比例尺
  BaseScale getScale(int axisIndex, bool isXAxis);

  double getAxisLength(int axisIndex, bool isXAxis);

  ///=====下面的方法由子视图回调
  ///当子视图的数据集发生改变时需要重新布局确定坐标系
  void onChildDataSetChange(bool layoutChild);

  ///当子视图需要实现动态坐标轴时回调该方法
  void onRelayoutAxisByChild(bool xAxis, bool notifyInvalidate);

  @override
  set translationX(double tx) => viewPort.scrollX = tx;

  @override
  double get translationX => viewPort.scrollX;

  @override
  set translationY(double ty) => viewPort.scrollY = ty;

  @override
  double get translationY => viewPort.scrollY;

  DynamicText getMaxStr(Direction direction, int axisIndex) {
    DynamicText maxStr = DynamicText.empty;
    Size size = Size.zero;
    bool isXAxis = direction == Direction.horizontal;
    var dim = GridAxisDim(isXAxis, axisIndex);
    for (var ele in getCoordChildList()) {
      var text = ele.getAxisMaxText(coordType, dim);
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
}
