import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import 'parallel_helper.dart';

//平行坐标系
class ParallelView extends CoordChildView<ParallelSeries, ParallelHelper> implements ParallelChild {
  ParallelView(super.series);

  @override
  void onDraw(CCanvas canvas) {
    var direction = layoutHelper.findParallelCoord().direction;
    Rect clipRect;
    var ap = layoutHelper.animationProcess;
    if (direction == Direction.horizontal) {
      clipRect = Rect.fromLTWH(0, 0, width * ap, height);
    } else {
      clipRect = Rect.fromLTWH(0, 0, width, height * ap);
    }
    canvas.save();
    canvas.clipRect(clipRect);
    var nodeList = layoutHelper.nodeList;
    for (var ele in nodeList) {
      ele.onDraw(canvas, mPaint);
    }
    for (var ele in nodeList) {
      ele.onDrawSymbol(canvas, mPaint);
    }
    canvas.restore();
  }

  @override
  List<dynamic> getDimDataSet(int dim) {
    List<dynamic> list = [];
    for (var group in series.data) {
      if (dim < group.data.length) {
        var data = group.data[dim];
        list.add(data);
      }
    }
    return list;
  }

  @override
  int get parallelIndex => series.parallelIndex;

  @override
  ParallelHelper buildLayoutHelper(var oldHelper) {
    oldHelper?.clearRef();
    return ParallelHelper(context, this, series);
  }
}
