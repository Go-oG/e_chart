import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import 'parallel_helper.dart';

//平行坐标系
class ParallelView extends CoordChildView<ParallelSeries, ParallelHelper> implements ParallelChild {
  ParallelView(super.series);

  @override
  void onDraw(Canvas canvas) {
    _drawData(canvas);
  }

  void _drawData(Canvas canvas) {
    canvas.save();
    for (var ele in layoutHelper.nodeList) {
      List<Offset> ol = [];
      LineStyle style = series.styleFun.call(ele.data);
      for (var offset in ele.offsetList) {
        if (offset == null) {
          style.drawPolygon(canvas, mPaint, ol);
          ol = [];
        } else {
          ol.add(offset);
        }
      }
      style.drawPolygon(canvas, mPaint, ol);
      ol = [];
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
  ParallelHelper buildLayoutHelper() {
    return ParallelHelper(context, series);
  }
}
