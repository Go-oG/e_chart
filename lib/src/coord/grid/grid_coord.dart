import 'dart:math';
import 'package:flutter/material.dart';

import '../../component/axis/impl/line_axis_impl.dart';
import '../../core/view.dart';
import '../../model/dynamic_data.dart';
import '../../model/enums/align2.dart';
import '../../model/enums/direction.dart';
import '../rect_coord.dart';
import 'axis_grid_node.dart';
import 'axis_x.dart';
import 'axis_y.dart';
import 'grid_child.dart';
import 'grid_config.dart';

abstract class GridCoord extends RectCoord<GridConfig> {
  GridCoord(super.props);

  Offset dataToPoint(int xAxisIndex, DynamicData x, int yAxisIndex, DynamicData y);
}

///实现二维坐标系
class GridCoordImpl extends GridCoord {
  final Map<XAxis, GridAxisImpl> _xMap = {};
  final Map<YAxis, GridAxisImpl> _yMap = {};

  GridCoordImpl(super.props) {
    for (var ele in props.xAxisList) {
      var v = GridAxisImpl(ele, [], Direction.horizontal);
      _xMap[ele] = v;
    }
    for (var ele in props.yAxisList) {
      var v = GridAxisImpl(ele, [], Direction.vertical);
      _yMap[ele] = v;
    }
  }

  @override
  void addView(ChartView view, {int index = -1}) {
    super.addView(view, index: index);
    if (view is GridChild) {
      var childView = view as GridChild;
      int xIndex = childView.xAxisIndex;
      if (xIndex < 0 || xIndex >= props.xAxisList.length) {
        xIndex = 0;
      }
      _xMap[props.xAxisList[xIndex]]!.addChild(childView);

      int yIndex = childView.yAxisIndex;
      if (yIndex < 0 || yIndex >= props.yAxisList.length) {
        yIndex = 0;
      }
      _yMap[props.yAxisList[yIndex]]!.addChild(childView);
    }
  }

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    Size size = super.onMeasure(parentWidth, parentHeight);
    _xMap.forEach((key, value) {
      value.measure(parentWidth, parentHeight);
    });
    _yMap.forEach((key, value) {
      value.measure(parentWidth, parentHeight);
    });
    return size;
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    double topMargin = 0;
    double leftMargin = 0;
    double rightMargin = 0;
    double bottomMargin = 0;
    _xMap.forEach((key, value) {
      if (Align2.start == value.axis.position) {
        topMargin = max(topMargin, value.axisSize.rect.height);
      } else {
        bottomMargin = max(bottomMargin, value.axisSize.rect.height);
      }
    });

    _yMap.forEach((key, value) {
      if (Align2.end == value.axis.position) {
        rightMargin = max(rightMargin, value.axisSize.rect.width);
      } else {
        leftMargin = max(leftMargin, value.axisSize.rect.width);
      }
    });

    _xMap.forEach((key, value) {
      List<DynamicData> dl = [];
      for (var ele in value.children) {
        dl.addAll(ele.xDataSet);
      }
      LineProps layoutProps;
      if (value.axis.position == Align2.start) {
        Offset start = Offset(leftMargin, topMargin);
        Offset end = Offset(width - rightMargin, topMargin);
        layoutProps = LineProps(Rect.zero, start, end);
      } else {
        Offset start = Offset(leftMargin, height - bottomMargin);
        Offset end = Offset(width - rightMargin, height - bottomMargin);
        layoutProps = LineProps(Rect.zero, start, end);
      }
      value.layout(layoutProps, dl);
    });

    _yMap.forEach((key, value) {
      List<DynamicData> dl = [];
      for (var ele in value.children) {
        dl.addAll(ele.yDataSet);
      }
      LineProps layoutProps;
      if (value.axis.position == Align2.end) {
        Offset start = Offset(width - rightMargin, topMargin);
        Offset end = Offset(width - rightMargin, height - bottomMargin);
        layoutProps = LineProps(Rect.zero, start, end);
      } else {
        Offset start = Offset(0, topMargin);
        Offset end = Offset(0, height - bottomMargin);
        layoutProps = LineProps(Rect.zero, start, end);
      }
      value.layout(layoutProps, dl);
    });

    for (var element in children) {
      element.layout(leftMargin, topMargin, element.width - rightMargin, element.height - bottomMargin);
    }
  }

  @override
  Offset dataToPoint(int xAxisIndex, DynamicData x, int yAxisIndex, DynamicData y) {
    double dx = _xMap[props.xAxisList[xAxisIndex]]!.dataToPoint(x);
    double dy = _yMap[props.yAxisList[yAxisIndex]]!.dataToPoint(y);
    return Offset(dx, dy);
  }


}
