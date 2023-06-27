import 'dart:math';

import 'package:e_chart/src/ext/offset_ext.dart';
import 'package:e_chart/src/ext/paint_ext.dart';
import 'package:flutter/material.dart';

import '../../component/axis/base_axis.dart';
import '../../component/axis/impl/base_axis_impl.dart';
import '../../component/axis/impl/line_axis_impl.dart';
import '../../model/dynamic_data.dart';
import '../../model/enums/direction.dart';
import '../rect_coord.dart';
import 'parallel_axis_node.dart';
import 'parallel_config.dart';
import 'parallel_axis.dart';
import 'parallel_child.dart';

abstract class ParallelCoord extends RectCoord<ParallelConfig> {
  ParallelCoord(super.props);

  Offset? dataToPoint(int dimIndex, DynamicData data);

  Direction get direction => props.direction;

  void onDataUpdate(){}

}

///平行坐标系
class ParallelCoordImpl extends ParallelCoord {
  final Map<ParallelAxis, ParallelAxisImpl> _axisMap = {};
  int _expandLeftIndex = -1;
  int _expandRightIndex = -1;

  ParallelCoordImpl(super.props) {
    _initData();
  }

  void _initData() {
    _axisMap.clear();
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
      ParallelAxisImpl node = ParallelAxisImpl(ele, direction, i);
      node.expanded = true;
      if (i >= _expandLeftIndex && i <= _expandRightIndex) {
        node.expanded = false;
      }
      _axisMap[ele] = node;
      if (node.show) {
        _axisMap[ele] = node;
      }
    }
  }

  ///找到离点击点最近的轴
  ParallelAxisImpl? findMinDistanceAxis(Offset offset) {
    ParallelAxisImpl? node;
    num distance = 0;
    for (var ele in _axisMap.values) {
      if (!ele.show) {
        continue;
      }
      if (node == null) {
        node = ele;
        if (props.direction == Direction.horizontal) {
          distance = (node.props.rect.left - offset.dx).abs();
        } else {
          distance = (node.props.rect.top - offset.dy).abs();
        }
      } else {
        double tmp;
        if (props.direction == Direction.horizontal) {
          tmp = (ele.props.rect.left - offset.dx).abs();
        } else {
          tmp = (ele.props.rect.top - offset.dy).abs();
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
      var node2 = _axisMap[axis]!;
      if (node2.show) {
        hasCheck = true;
      }
      if (node == node2) {
        return !hasCheck;
      }
    }
    return false;
  }

  bool isLastAxis(BaseAxisImpl node) {
    bool hasCheck = false;
    for (int i = props.axisList.length - 1; i >= 0; i--) {
      var node2 = _axisMap[props.axisList[i]]!;
      if (node2.show) {
        hasCheck = true;
      }
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
    bool horizontal = props.direction == Direction.horizontal;
    double size = (horizontal ? w : h);

    int expandCount = 0;
    int unExpandCount = 0;
    _axisMap.forEach((key, value) {
      if (value.show) {
        if (value.expanded) {
          expandCount += 1;
        } else {
          unExpandCount += 1;
        }
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
    List<Size> textSize = measureAxisNameTextMaxSize(_axisMap.keys, props.direction, max(interval, props.expandWidth));

    for (var axis in props.axisList) {
      var node = _axisMap[axis]!;
      if (!node.show) {
        continue;
      }
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
          dataSet.addAll(child.getDimDataSet(node.index));
        }
      }
      Offset start = rect.topLeft;
      Offset end = (props.direction == Direction.horizontal) ? rect.bottomLeft : rect.topRight;
      if (props.direction == Direction.horizontal) {
        start = start.translate(0, textSize[0].height);
        end = end.translate(0, -textSize[1].height);
      } else {
        start = start.translate(textSize[0].width, 0);
        end = end.translate(-textSize[1].width, 0);
      }

      LineProps layoutProps = LineProps(rect, start, end, textStartSize: textSize[0], textEndSize: textSize[1]);
      node.layout(layoutProps, dataSet);
    }

    for (var ele in children) {
      ele.layout(0, 0, width, height);
    }
  }

  @override
  void onDraw(Canvas canvas) {
    if (props.backgroundColor != null) {
      mPaint.reset();
      mPaint.color = props.backgroundColor!;
      mPaint.style = PaintingStyle.fill;
      canvas.drawRect(boxBounds, mPaint);
    }
    for (var ele in _axisMap.entries) {
      ele.value.draw(canvas, mPaint);
    }
  }

  ///找到当前点击的
  BaseAxisImpl? findClickAxis(Offset offset) {
    BaseAxisImpl? node;
    for (var ele in _axisMap.entries) {
      if (!ele.value.show) {
        continue;
      }
      List<Offset> ol;
      if (props.direction == Direction.horizontal) {
        ol = [ele.value.props.rect.topLeft, ele.value.props.rect.bottomLeft];
      } else {
        ol = [ele.value.props.rect.topLeft, ele.value.props.rect.topRight];
      }
      if (offset.inLine(ol[0], ol[1])) {
        node = ele.value;
        break;
      }
    }
    return node;
  }

  @override
  Offset? dataToPoint(int dimIndex, DynamicData data) {
    ParallelAxisImpl? node = _axisMap[props.axisList[dimIndex]];
    return node?.dataToPoint(data);
  }
}
