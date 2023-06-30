import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

abstract class GridCoord extends RectCoord<GridConfig> {
  GridCoord(super.props);

  Rect dataToPosition(int xAxisIndex, DynamicData x, int yAxisIndex, DynamicData y);

  ///获取平移量
  Offset getTranslation(int xAxisIndex, int yAxisIndex);

  Offset getScaleFactor(int xAxisIndex, int yAxisIndex);
}

///实现二维坐标系
class GridCoordImpl extends GridCoord {
  final Map<XAxis, XAxisImpl> xMap = {};
  final Map<YAxis, YAxisImpl> yMap = {};
  Rect contentBox = Rect.zero;

  GridCoordImpl(super.props) {
    for (var ele in props.xAxisList) {
      xMap[ele] = XAxisImpl(ele);
    }
    for (var ele in props.yAxisList) {
      yMap[ele] = YAxisImpl(ele);
    }
  }

  @override
  void addView(ChartView view, {int index = -1}) {
    super.addView(view, index: index);
    if (view is GridChild) {
      var childView = view as GridChild;
      int xIndex = childView.xAxisIndex;
      getXAxis(xIndex).addChild(childView);
      int yIndex = childView.yAxisIndex;
      getYAxis(yIndex).addChild(childView);
    }
  }

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    Size size = super.onMeasure(parentWidth, parentHeight);
    xMap.forEach((key, value) {
      value.measure(parentWidth, parentHeight);
    });
    yMap.forEach((key, value) {
      value.measure(parentWidth, parentHeight);
    });
    return size;
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    double topMargin = 0;
    double bottomMargin = 0;

    double leftMargin = 0;
    double rightMargin = 0;

    xMap.forEach((key, value) {
      if (Align2.start == value.axis.position) {
        topMargin += value.axisInfo.bound.height + value.axis.offset;
      } else {
        bottomMargin += value.axisInfo.bound.height + value.axis.offset;
      }
    });

    yMap.forEach((key, value) {
      var v = value.axisInfo.bound.width + value.axis.offset;
      if (Align2.end == value.axis.position) {
        rightMargin += v;
      } else {
        leftMargin += v;
      }
    });

    double axisWith = width - (rightMargin + leftMargin);
    double axisHeight = height - (topMargin + bottomMargin);
    contentBox = Rect.fromLTWH(leftMargin, topMargin, axisWith, axisHeight);

    ///布局X轴
    double topOffset = topMargin;
    double bottomOffset = height - bottomMargin;
    for (var axis in props.xAxisList) {
      var value = xMap[axis]!;
      List<DynamicData> dl = [];
      for (var ele in value.children) {
        dl.addAll(ele.xDataSet);
      }
      LineProps layoutProps;
      var h = value.axisInfo.bound.height;
      if (value.axis.position == Align2.start) {
        Rect rect = Rect.fromLTWH(leftMargin, topOffset, axisWith, h);
        layoutProps = LineProps(rect, rect.topLeft, rect.topRight);
        topOffset -= (value.axisInfo.bound.height + value.axis.offset);
      } else {
        Rect rect = Rect.fromLTWH(leftMargin, bottomOffset, axisWith, h);
        layoutProps = LineProps(rect, rect.topLeft, rect.topRight);
        bottomOffset += (h + value.axis.offset);
      }
      value.layout(layoutProps, dl);
    }

    ///布局Y轴
    double leftOffset = leftMargin;
    double rightOffset = width - rightMargin;
    for (var axis in props.yAxisList) {
      var value = yMap[axis]!;
      List<DynamicData> dl = [];
      for (var ele in value.children) {
        dl.addAll(ele.yDataSet);
      }
      LineProps layoutProps;
      var w = value.axisInfo.bound.width;
      if (value.axis.position == Align2.start) {
        Rect rect = Rect.fromLTWH(leftOffset - w, topMargin, w, axisHeight);
        layoutProps = LineProps(rect, rect.topRight, rect.bottomRight);
        leftOffset -= (w + value.axis.offset);
      } else {
        Rect rect = Rect.fromLTWH(rightOffset, topMargin, w, axisHeight);
        layoutProps = LineProps(rect, rect.topLeft, rect.bottomLeft);
        rightOffset += (w + value.axis.offset);
      }
      value.layout(layoutProps, dl);
    }
    for (var view in children) {
      //  view.layout(leftMargin, topMargin, view.width - rightMargin, view.height - bottomMargin);
      view.layout(leftMargin, topMargin, width - rightMargin, height - bottomMargin);
    }
  }

  @override
  void onDraw(Canvas canvas) {
    xMap.forEach((key, value) {
      value.draw(canvas, mPaint);
    });
    yMap.forEach((key, value) {
      logPrint("Y轴${value.axisInfo.bound} ${value.axisInfo.start}  ${value.axisInfo.end}");
      value.draw(canvas, mPaint);
    });
  }

  @override
  Rect dataToPosition(int xAxisIndex, DynamicData x, int yAxisIndex, DynamicData y) {
    List<num> dx = getXAxis(xAxisIndex).dataToPoint(x);
    List<num> dy = getYAxis(yAxisIndex).dataToPoint(y);
    double l = dx[0].toDouble();
    double t = dy[0].toDouble();
    double r = dx.length >= 2 ? dx[1].toDouble() : l + 1;
    double b = dy.length >= 2 ? dy[1].toDouble() : t + 1;
    return Rect.fromLTRB(l, t, r, b);
  }

  @override
  Offset getScaleFactor(int xAxisIndex, int yAxisIndex) {
    var x = getXAxis(xAxisIndex);
    var y = getYAxis(yAxisIndex);
    return Offset(x.scaleFactor, y.scaleFactor);
  }

  @override
  Offset getTranslation(int xAxisIndex, int yAxisIndex) {
    var x = getXAxis(xAxisIndex);
    var y = getYAxis(yAxisIndex);
    return Offset(x.scrollOffset, y.scrollOffset);
  }

  @override
  void onDragMove(Offset offset, Offset diff) {
    if (!contentBox.contains(offset)) {
      return;
    }
    xMap.forEach((key, value) {
      value.scrollOffset = value.scrollOffset + diff.dx;
    });

    invalidate();

    // _yMap.forEach((key, value) {
    //   value.scrollOffset=value.scrollOffset+diff.dy;
    // });
  }

  @override
  void onScaleUpdate(Offset offset, double rotation, double scale, double hScale, double vScale, bool doubleClick) {
    if (!contentBox.contains(offset)) {
      return;
    }
    Set<GridChild> childSet = {};
    xMap.forEach((key, value) {
      value.scaleFactor = value.scaleFactor + hScale;
      childSet.addAll(value.children);
    });
    yMap.forEach((key, value) {
      value.scaleFactor = value.scaleFactor + vScale;
      childSet.addAll(value.children);
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
}
