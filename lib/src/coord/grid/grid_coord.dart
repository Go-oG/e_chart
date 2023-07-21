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

  ///获取比例尺
  BaseScale getScale(int axisIndex, bool isXAxis);

  double getAxisLength(int axisIndex, bool isXAxis);

  List<GridChild> getGridChildList();
}

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
      xMap[ele] = XAxisImpl(context, this, ele, axisIndex: p1);
    });
    each(props.yAxisList, (axis, p1) {
      yMap[axis] = YAxisImpl(context, this, axis, axisIndex: p1);
    });
  }

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    Size size = Size(parentWidth, parentHeight);
    double w = parentWidth - props.padding.horizontal;
    double h = parentHeight - props.padding.vertical;

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
    double topOffset = props.padding.top;
    double bottomOffset = props.padding.bottom;
    double leftOffset = props.padding.left;
    double rightOffset = props.padding.right;

    num topEnd = 0;
    num bottomEnd = 0;
    xMap.forEach((key, value) {
      if (Align2.start == value.axis.position) {
        topOffset += value.axisInfo.bound.height + value.axis.offset;
        topEnd = value.axis.offset;
      } else {
        bottomOffset += value.axisInfo.bound.height + value.axis.offset;
        bottomEnd = value.axis.offset;
      }
    });
    topOffset -= topEnd;
    bottomOffset -= bottomEnd;

    num leftEnd = 0;
    num rightEnd = 0;
    yMap.forEach((key, value) {
      var v = value.axisInfo.bound.width + value.axis.offset;
      if (Align2.end == value.axis.position) {
        rightOffset += v;
        rightEnd += value.axis.offset;
      } else {
        leftOffset += v;
        leftEnd += value.axis.offset;
      }
    });
    rightOffset -= rightEnd;
    leftOffset -= leftEnd;

    double axisWith = width - (rightOffset + leftOffset);
    double axisHeight = height - (topOffset + bottomOffset);
    contentBox = Rect.fromLTWH(leftOffset, topOffset, axisWith, axisHeight);
    List<GridChild> childList = getGridChildList();

    ///布局X轴
    layoutXAxis(childList, contentBox);

    ///布局Y轴
    layoutYAxis(childList, contentBox);
    for (var view in children) {
      view.layout(contentBox.left, contentBox.top, contentBox.right, contentBox.bottom);
    }
  }

  void layoutXAxis(List<GridChild> childList, Rect contentBox) {
    List<XAxisImpl> topList = [];
    List<XAxisImpl> bottomList = [];
    for (var ele in props.xAxisList) {
      if (ele.position == Align2.start) {
        topList.add(xMap[ele]!);
      } else {
        bottomList.add(xMap[ele]!);
      }
    }
    double topOffset = contentBox.top;
    for (var value in topList) {
      var axisInfo = value.axisInfo;
      List<DynamicData> dl = [];
      for (var child in childList) {
        dl.addAll(child.getAxisExtreme(value.axisIndex, true));
      }
      var h = axisInfo.bound.height;
      Rect rect = Rect.fromLTWH(contentBox.left, topOffset - h, contentBox.width, h);
      var layoutAttrs = LineAxisAttrs(scaleXFactor, scrollXOffset, rect, rect.bottomLeft, rect.bottomRight);
      topOffset -= (h + value.axis.offset);
      value.doLayout(layoutAttrs, dl);
    }
    double bottomOffset = contentBox.bottom;
    for (var value in bottomList) {
      var axisInfo = value.axisInfo;
      List<DynamicData> dl = [];
      for (var child in childList) {
        dl.addAll(child.getAxisExtreme(value.axisIndex, true));
      }
      var h = axisInfo.bound.height;
      Rect rect = Rect.fromLTWH(contentBox.left, bottomOffset, contentBox.width, h);
      var layoutAttrs = LineAxisAttrs(
        scaleXFactor,
        scrollXOffset,
        rect,
        rect.topLeft.translate(0, -1),
        rect.topRight.translate(0, -1),
      );
      bottomOffset += (h + value.axis.offset);
      value.doLayout(layoutAttrs, dl);
    }

    final w = contentBox.width;
    double maxWidth = w;
    for (var axis in [...topList, ...bottomList]) {
      if (axis.scale.isCategory) {
        int c = axis.scale.domain.length;
        num diff = maxWidth / c;
        if (diff < 48) {
          maxWidth = c * 48;
        }
      } else if (axis.scale.isTime) {
        int c = axis.scale.tickCount;
        if (c < 0) {
          continue;
        }
        if (maxWidth / c < 16) {
          maxWidth = c * 16;
        }
      } else {
        var scale = axis.scale as LinearScale;
        int c = (scale.step * scale.tickCount).toInt();
        if (c < 0) {
          continue;
        }
        if (maxWidth / c < 16) {
          maxWidth = c * 16;
        }
      }
    }
    logPrint("maxWidth:$maxWidth W:$w");
    if (maxWidth > w) {
      double k = maxWidth / w;
      for (var axis in [...topList, ...bottomList]) {
        axis.onAttrsChange(axis.attrs.copyWith(scaleRatio: k));
      }
    }
  }

  void layoutYAxis(List<GridChild> childList, Rect contentBox) {
    List<YAxisImpl> leftList = [];
    List<YAxisImpl> rightList = [];
    for (var ele in props.yAxisList) {
      if (ele.position == Align2.start) {
        leftList.add(yMap[ele]!);
      } else {
        rightList.add(yMap[ele]!);
      }
    }
    double rightOffset = contentBox.left;
    each(leftList, (value, i) {
      List<DynamicData> dl = [];
      for (var ele in childList) {
        dl.addAll(ele.getAxisExtreme(value.axisIndex, false));
      }
      LineAxisAttrs layoutProps;
      if (i != 0) {
        rightOffset -= value.axis.offset;
      }
      double w = value.axisInfo.bound.width;
      Rect rect = Rect.fromLTRB(rightOffset - w, contentBox.top, rightOffset, contentBox.bottom);
      layoutProps = LineAxisAttrs(scaleYFactor, scrollYOffset, rect, rect.bottomRight, rect.topRight);
      rightOffset -= w;
      value.doLayout(layoutProps, dl);
    });

    double leftOffset = contentBox.right;
    each(rightList, (value, i) {
      List<DynamicData> dl = [];
      for (var ele in childList) {
        dl.addAll(ele.getAxisExtreme(value.axisIndex, false));
      }
      LineAxisAttrs layoutProps;
      double w = value.axisInfo.bound.width;
      if (i != 0) {
        leftOffset += value.axis.offset;
      }
      Rect rect = Rect.fromLTWH(leftOffset, contentBox.top, w, contentBox.height);
      layoutProps = LineAxisAttrs(scaleYFactor, scrollYOffset, rect, rect.bottomLeft, rect.topLeft);
      leftOffset += w;
      value.doLayout(layoutProps, dl);
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
    if (sx != scrollXOffset) {
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
      scrollYOffset = sy;
      yMap.forEach((key, value) {
        value.attrs.scroll = sy;
        value.onScrollChange(sy);
      });
    }

    invalidate();
  }

  @override
  void onScaleUpdate(Offset offset, double rotation, double scale, double hScale, double vScale, bool doubleClick) {
    if (!contentBox.contains(offset)) {
      return;
    }
    var sx = scaleXFactor + hScale;
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
    xMap.forEach((key, value) {
      // value.attrs.scroll = sx;
      // value.onScrollChange(sx);
    });
    invalidate();
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
