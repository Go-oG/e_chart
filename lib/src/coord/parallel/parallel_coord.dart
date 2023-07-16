import 'dart:math';

import 'package:e_chart/src/ext/offset_ext.dart';
import 'package:flutter/material.dart';

import '../../component/index.dart';
import '../../model/dynamic_data.dart';
import '../../model/enums/direction.dart';
import '../coord.dart';
import 'parallel_axis_impl.dart';
import 'parallel_config.dart';
import 'parallel_axis.dart';
import 'parallel_child.dart';

///平行坐标系
class ParallelCoordImpl extends ParallelCoord {
  final Map<ParallelAxis, ParallelAxisImpl> axisMap = {};
  int _expandLeftIndex = -1;
  int _expandRightIndex = -1;
  Rect contentBox = Rect.zero;

  ParallelCoordImpl(super.props);

  void initAxis() {
    axisMap.clear();
    _expandLeftIndex = -1;
    _expandRightIndex = -1;
    if (props.expandable && props.expandStartIndex >= 0 && props.expandStartIndex < props.axisList.length) {
      _expandLeftIndex = props.expandStartIndex - props.expandCount ~/ 2;
      _expandRightIndex = props.expandStartIndex + props.expandCount ~/ 2;
      if (props.expandCount % 2 != 0) {
        if (props.expandStartIndex >= props.axisList.length / 2) {
          _expandRightIndex += 1;
        } else {
          _expandLeftIndex -= 1;
        }
      }
    }

    Direction direction = props.direction == Direction.vertical ? Direction.horizontal : Direction.vertical;
    for (int i = 0; i < props.axisList.length; i++) {
      var ele = props.axisList[i];
      ParallelAxisImpl node = ParallelAxisImpl(context, ele, direction, axisIndex: i);
      node.expanded = true;
      if (i >= _expandLeftIndex && i <= _expandRightIndex) {
        node.expanded = false;
      }
      axisMap[ele] = node;
    }
  }

  @override
  void onCreate() {
    super.onCreate();
    initAxis();
  }

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

  bool isFirstAxis(BaseAxisImpl node) {
    bool hasCheck = false;
    for (var axis in props.axisList) {
      var node2 = axisMap[axis]!;
      if (node == node2) {
        return !hasCheck;
      }
    }
    return false;
  }

  bool isLastAxis(BaseAxisImpl node) {
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
  void onLayout(double left, double top, double right, double bottom) {
    final double leftOffset = props.leftPadding.convert(width);
    final double topOffset = props.topPadding.convert(height);
    final double rightOffset = props.rightPadding.convert(height);
    final double bottomOffset = props.bottomPadding.convert(height);

    double w = width - leftOffset - rightOffset;
    double h = height - topOffset - bottomOffset;
    contentBox = Rect.fromLTWH(leftOffset, topOffset, w, h);

    bool horizontal = props.direction == Direction.horizontal;
    double size = (horizontal ? w : h);

    int expandCount = 0;
    int unExpandCount = 0;
    axisMap.forEach((key, value) {
      if (value.expanded) {
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
      var node = axisMap[axis]!;
      double tmpLeft;
      double tmpTop;
      double tmpRight;
      double tmpBottom;
      if (horizontal) {
        tmpLeft = offsetP;
        tmpRight = tmpLeft + (node.expanded ? interval : props.expandWidth);
        tmpTop = topOffset;
        tmpBottom = h;
        offsetP += (tmpRight - tmpLeft);
      } else {
        tmpLeft = leftOffset;
        tmpTop = offsetP;
        tmpRight = width - rightOffset;
        tmpBottom = tmpTop + (node.expanded ? interval : props.expandWidth);
        offsetP += (node.expanded ? interval : props.expandWidth);
      }

      ///处理轴内部
      Rect rect = Rect.fromLTRB(tmpLeft, tmpTop, tmpRight, tmpBottom);
      List<DynamicData> dataSet = [];
      for (var ele in children) {
        if (ele is ParallelChild) {
          var child = ele as ParallelChild;
          dataSet.addAll(child.getDimDataSet(node.axisIndex));
        }
      }

      Offset start,end ;
      if (props.direction == Direction.horizontal) {
        start=rect.bottomLeft.translate(0, -textSize[1].height);
        end=rect.topLeft.translate(0, textSize[0].height);
      } else {
        start = rect.topLeft.translate(textSize[0].width, 0);
        end = rect.topRight.translate(-textSize[1].width, 0);
      }
      LineAxisAttrs layoutProps = LineAxisAttrs(rect, start, end, textStartSize: textSize[0], textEndSize: textSize[1]);
      node.doLayout(layoutProps, dataSet);
    }

    for (var ele in children) {
      ele.layout(0, 0, width, height);
    }
  }

  @override
  void onDraw(Canvas canvas) {
    for (var ele in axisMap.entries) {
      ele.value.draw(canvas, mPaint, Rect.zero);
    }
  }

  ///找到当前点击的
  BaseAxisImpl? findClickAxis(Offset offset) {
    BaseAxisImpl? node;
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
  ParallelPosition dataToPosition(int dimIndex, DynamicData data) {
    ParallelAxisImpl node = axisMap[props.axisList[dimIndex]]!;
    return ParallelPosition(node.dataToPoint(data));
  }
}

abstract class ParallelCoord extends Coord<ParallelConfig> {
  ParallelCoord(super.props);

  ParallelPosition dataToPosition(int dimIndex, DynamicData data);

  Direction get direction => props.direction;
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
