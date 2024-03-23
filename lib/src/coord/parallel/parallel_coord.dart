import 'dart:math';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///平行坐标系
class ParallelCoordImpl extends ParallelCoord {
  final Map<ParallelAxis, ParallelAxisImpl> axisMap = {};

  ParallelCoordImpl(super.context, super.props);

  void initAxis() {
    axisMap.clear();

    ///翻转方向
    var direction = props.direction == Direction.vertical ? Direction.horizontal : Direction.vertical;
    for (int i = 0; i < props.axisList.length; i++) {
      var ele = props.axisList[i];
      axisMap[ele] = ParallelAxisImpl(context, ele, direction, axisIndex: i);
    }
  }

  @override
  void onCreate() {
    super.onCreate();
    initAxis();
  }

  @override
  void onDispose() {
    axisMap.forEach((key, value) {
      value.dispose();
    });
    axisMap.clear();
    super.onDispose();
  }

  @override
  bool get enableScale => false;

  ///找到离点击点最近的轴
  ParallelAxisImpl? findMinDistanceAxis(Offset offset) {
    ParallelAxisImpl? node;
    num distance = 0;
    for (var ele in axisMap.values) {
      if (node == null) {
        node = ele;
        if (props.direction == Direction.horizontal) {
          distance = (node.attrs.rect.left - offset.dx).abs();
        } else {
          distance = (node.attrs.rect.top - offset.dy).abs();
        }
      } else {
        double tmp;
        if (props.direction == Direction.horizontal) {
          tmp = (ele.attrs.rect.left - offset.dx).abs();
        } else {
          tmp = (ele.attrs.rect.top - offset.dy).abs();
        }
        if (tmp < distance) {
          distance = tmp;
          node = ele;
        }
      }
    }
    return node;
  }

  bool isFirstAxis(BaseAxisRender node) {
    bool hasCheck = false;
    for (var axis in props.axisList) {
      var node2 = axisMap[axis]!;
      if (node == node2) {
        return !hasCheck;
      }
    }
    return false;
  }

  bool isLastAxis(BaseAxisRender node) {
    bool hasCheck = false;
    for (int i = props.axisList.length - 1; i >= 0; i--) {
      var node2 = axisMap[props.axisList[i]]!;

      if (node == node2) {
        return !hasCheck;
      }
    }
    return false;
  }

  @override
  void onLayout(bool changed, double left, double top, double right, double bottom) {
    final double leftOffset = layoutParams.leftPadding;
    final double topOffset = layoutParams.topPadding;
    final double rightOffset = layoutParams.rightPadding;
    final double bottomOffset = layoutParams.bottomPadding;

    double w = width - leftOffset - rightOffset;
    double h = height - topOffset - bottomOffset;
    contentBox = Rect.fromLTWH(leftOffset, topOffset, w, h);

    bool horizontal = props.direction == Direction.horizontal;
    double size = (horizontal ? w : h);

    int expandCount = 0;
    int unExpandCount = 0;
    axisMap.forEach((key, value) {
      if (value.expand) {
        expandCount += 1;
      } else {
        unExpandCount += 1;
      }
    });

    num unExpandAllSize = props.expandWidth * unExpandCount;
    num remainSize = size - unExpandAllSize;
    double interval;
    if (expandCount > 0) {
      interval = remainSize / expandCount;
    } else {
      interval = 0;
    }
    double offsetP = horizontal ? leftOffset : topOffset;

    ///计算在不同布局方向上前后占用的最大高度或者宽度
    List<Size> textSize = measureAxisNameTextMaxSize(axisMap.keys, props.direction, max(interval, props.expandWidth));

    for (var axis in props.axisList) {
      var axisImpl = axisMap[axis]!;
      double tmpLeft;
      double tmpTop;
      double tmpRight;
      double tmpBottom;
      if (horizontal) {
        tmpLeft = offsetP;
        tmpRight = tmpLeft + (axisImpl.expand ? interval : props.expandWidth);
        tmpTop = topOffset;
        tmpBottom = h;
        offsetP += (tmpRight - tmpLeft);
      } else {
        tmpLeft = leftOffset;
        tmpTop = offsetP;
        tmpRight = width - rightOffset;
        tmpBottom = tmpTop + (axisImpl.expand ? interval : props.expandWidth);
        offsetP += (axisImpl.expand ? interval : props.expandWidth);
      }

      ///处理轴内部
      Rect rect = Rect.fromLTRB(tmpLeft, tmpTop, tmpRight, tmpBottom);
      var dataSet = collectChildDimData(AxisDim(axisImpl.axisIndex));

      Offset start, end;
      if (props.direction == Direction.horizontal) {
        start = rect.bottomLeft.translate(0, -textSize[1].height);
        end = rect.topLeft.translate(0, textSize[0].height);
      } else {
        start = rect.topLeft.translate(textSize[0].width, 0);
        end = rect.topRight.translate(-textSize[1].width, 0);
      }

      var attrs = axisImpl.attrs.copy();
      attrs.start = start;
      attrs.end = end;
      attrs.textStartSize = textSize[0];
      attrs.textEndSize = textSize[1];
      attrs.rect = rect;
      axisImpl.doLayout(attrs, dataSet);
    }

    for (var ele in children) {
      ele.layout(0, 0, width, height);
    }
  }

  @override
  void onDraw(CCanvas canvas) {
    for (var ele in axisMap.entries) {
      ele.value.draw(canvas, mPaint);
    }
  }

  ///找到当前点击的
  BaseAxisRender? findClickAxis(Offset offset) {
    BaseAxisRender? node;
    for (var ele in axisMap.entries) {
      List<Offset> ol;
      if (props.direction == Direction.horizontal) {
        ol = [ele.value.attrs.rect.topLeft, ele.value.attrs.rect.bottomLeft];
      } else {
        ol = [ele.value.attrs.rect.topLeft, ele.value.attrs.rect.topRight];
      }
      if (offset.inLine(ol[0], ol[1])) {
        node = ele.value;
        break;
      }
    }
    return node;
  }

  @override
  ParallelPosition dataToPosition(int dimIndex, dynamic data) {
    checkDataType(data);
    ParallelAxisImpl node = axisMap[props.axisList[dimIndex]]!;
    return ParallelPosition(node.dataToPoint(data));
  }

  @override
  double getMaxXScroll() {
    return 0;
  }

  @override
  double getMaxYScroll() {
    return 0;
  }
}

abstract class ParallelCoord extends CoordLayout<Parallel> {
  ParallelCoord(super.context, super.props);

  ParallelPosition dataToPosition(int dimIndex, dynamic data);

  Direction get direction => props.direction;

  int getAxisCount() => props.axisList.length;
}

class ParallelPosition {
  ///当为类目轴时其返回一个范围
  final List<Offset> points;

  ParallelPosition(this.points);

  Offset get center {
    if (points.length <= 1) {
      return points[0];
    }
    Offset p1 = points[0];
    Offset p2 = points[1];
    return Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
  }
}
