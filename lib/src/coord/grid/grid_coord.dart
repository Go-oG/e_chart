import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

abstract class GridCoord extends Coord<GridConfig> {
  GridCoord(super.props);

  ///该方法适用于Bar
  Rect dataToRect(int xAxisIndex, DynamicData x, int yAxisIndex, DynamicData y);

  ///该方法适用于Line
  Offset dataToPoint(int xAxisIndex, DynamicData x, int yAxisIndex, DynamicData y);

  GridAxis getAxis(int axisIndex, bool isXAxis);

  ///获取平移量(滚动量)
  Offset getTranslation();

  Offset getScaleFactor();

  List<GridChild> getGridChildList();
}

///实现二维坐标系
class GridCoordImpl extends GridCoord {
  final Map<XAxis, XAxisImpl> xMap = {};
  final Map<YAxis, YAxisImpl> yMap = {};
  Rect contentBox = Rect.zero;

  double scaleXFactor = 1;
  double scaleYFactor = 1;
  double scrollXOffset = 0;
  double scrollYOffset = 0;

  GridCoordImpl(super.props);

  @override
  void onCreate() {
    super.onCreate();
    xMap.clear();
    yMap.clear();
    each(props.xAxisList, (ele, p1) {
      xMap[ele] = XAxisImpl(this, context, ele, axisIndex: p1);
    });
    each(props.yAxisList, (axis, p1) {
      yMap[axis] = YAxisImpl(this, context, axis, axisIndex: p1);
    });
  }

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    Size size = super.onMeasure(parentWidth, parentHeight);
    xMap.forEach((key, value) {
      value.doMeasure(parentWidth, parentHeight);
    });
    yMap.forEach((key, value) {
      value.doMeasure(parentWidth, parentHeight);
    });

    return size;
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    double topPadding = props.padding.top;
    double bottomPadding = props.padding.bottom;
    double leftPadding = props.padding.left;
    double rightPadding = props.padding.right;

    xMap.forEach((key, value) {
      if (Align2.start == value.axis.position) {
        topPadding += value.axisInfo.bound.height + value.axis.offset;
      } else {
        bottomPadding += value.axisInfo.bound.height + value.axis.offset;
      }
    });

    yMap.forEach((key, value) {
      var v = value.axisInfo.bound.width + value.axis.offset;
      if (Align2.end == value.axis.position) {
        rightPadding += v;
      } else {
        leftPadding += v;
      }
    });

    double axisWith = width - (rightPadding + leftPadding);
    double axisHeight = height - (topPadding + bottomPadding);
    contentBox = Rect.fromLTWH(leftPadding, topPadding, axisWith, axisHeight);

    ///布局X轴
    double topOffset = topPadding;
    double bottomOffset = height - bottomPadding;

    List<GridChild> childList = getGridChildList();

    xMap.forEach((key, value) {
      var axisInfo = value.axisInfo;
      List<DynamicData> dl = [];
      for (var child in childList) {
        dl.addAll(child.getAxisExtreme(value.axisIndex, true));
      }

      LineAxisAttrs layoutProps;
      var h = axisInfo.bound.height;
      if (value.axis.position == Align2.start) {
        Rect rect = Rect.fromLTWH(leftPadding, topOffset, axisWith, h);
        layoutProps = LineAxisAttrs(rect, rect.topLeft, rect.topRight);
        topOffset -= (h + value.axis.offset);
      } else {
        Rect rect = Rect.fromLTWH(leftPadding, bottomOffset, axisWith, h);
        layoutProps = LineAxisAttrs(rect, rect.topLeft, rect.topRight);
        bottomOffset += (h + value.axis.offset);
      }
      value.doLayout(layoutProps, dl);
    });

    ///布局Y轴
    double leftOffset = leftPadding;
    double rightOffset = width - rightPadding;
    yMap.forEach((key, value) {
      List<DynamicData> dl = [];
      for (var ele in childList) {
        dl.addAll(ele.getAxisExtreme(value.axisIndex, false));
      }
      LineAxisAttrs layoutProps;
      var w = value.axisInfo.bound.width + value.axis.offset;
      if (value.axis.position == Align2.start) {
        Rect rect = Rect.fromLTWH(leftOffset - w, topPadding, w, axisHeight);
        layoutProps = LineAxisAttrs(rect, rect.bottomRight, rect.topRight);
        leftOffset -= w;
      } else {
        Rect rect = Rect.fromLTWH(rightOffset, topPadding, w, axisHeight);
        layoutProps = LineAxisAttrs(rect, rect.bottomLeft, rect.topLeft);
        rightOffset += w;
      }
      value.doLayout(layoutProps, dl);
    });
    for (var view in children) {
      view.layout(leftPadding, topPadding, width - rightPadding, height - bottomPadding);
    }
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
  Offset getScaleFactor() {
    return Offset(scaleXFactor, scaleYFactor);
  }

  @override
  Offset getTranslation() {
    return Offset(scrollXOffset, scrollYOffset);
  }

  @override
  void onDragMove(Offset offset, Offset diff) {
    if (!contentBox.contains(offset)) {
      return;
    }
    scrollXOffset += diff.dx;
    scrollYOffset += diff.dy;
    xMap.forEach((key, value) {
      value.updateScrollOffset(scrollXOffset);
    });
    invalidate();
  }

  @override
  void onScaleUpdate(Offset offset, double rotation, double scale, double hScale, double vScale, bool doubleClick) {
    if (!contentBox.contains(offset)) {
      return;
    }
    scaleXFactor += hScale;
    scaleYFactor += vScale;
    xMap.forEach((key, value) {
      value.updateScaleFactor(scaleXFactor);
    });
    yMap.forEach((key, value) {
      value.updateScaleFactor(scaleYFactor);
    });
    invalidate();
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
}
