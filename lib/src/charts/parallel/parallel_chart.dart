import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import 'layout.dart';

//平行坐标系
class ParallelView extends SeriesView<ParallelSeries> implements ParallelChild {
  final ParallelLayout _layout = ParallelLayout();

  ParallelView(super.series);

  @override
  void onUpdateDataCommand(covariant Command c) {
    super.onUpdateDataCommand(c);
    _layout.findParallelCoord().onReceiveCommand(Command.updateData);
    _layout.doLayout(context, series, series.data, selfBoxBound, LayoutType.update);
  }

  @override
  void onStart() {
    super.onStart();
    _layout.addListener(invalidate);
  }

  @override
  void onStop() {
    _layout.clearListener();
    super.onStop();
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    _layout.doLayout(context, series, series.data, selfBoxBound, LayoutType.layout);
  }

  @override
  void onDraw(Canvas canvas) {
    _drawData(canvas);
  }

  void _drawData(Canvas canvas) {
    canvas.save();
    for (var ele in _layout.nodeList) {
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
  List<DynamicData> getDimDataSet(int dim) {
    List<DynamicData> list = [];
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
}
