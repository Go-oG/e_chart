import 'dart:math';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import 'parallel_helper.dart';

///平行坐标系
class ParallelView extends CoordChildView<ParallelSeries, ParallelHelper> implements CoordChild {
  ParallelView(super.context, super.series);

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
    var nodeList = layoutHelper.dataSet;
    for (var ele in nodeList) {
      ele.onDraw(canvas, mPaint);
    }
    for (var ele in nodeList) {
      ele.onDrawSymbol(canvas, mPaint);
    }
    canvas.restore();
  }

  @override
  CoordInfo getEmbedCoord() => CoordInfo(CoordType.parallel, max(0, series.parallelIndex));

  @override
  ParallelHelper buildLayoutHelper(var oldHelper) {
    if (oldHelper != null) {
      oldHelper.context = context;
      oldHelper.view = this;
      oldHelper.series = series;
      return oldHelper;
    }
    return ParallelHelper(context, this, series);
  }

  @override
  int getAxisDataCount(CoordType type, AxisDim dim) => 0;

  @override
  Iterable getAxisExtreme(CoordType type, AxisDim axisDim) {
    if (type != CoordType.parallel) {
      return [];
    }

    return series.getExtremeHelper().getExtreme("${axisDim.index}").getAllExtreme();
  }

  @override
  DynamicText getAxisMaxText(CoordType type, AxisDim axisDim) => DynamicText.empty;

  @override
  Iterable getViewPortAxisExtreme(CoordType type, AxisDim axisDim, BaseScale<dynamic, num> scale) =>
      getAxisExtreme(type, axisDim);

  @override
  dynamic getDimData(CoordType type, AxisDim dim, data) {
    if (type != CoordType.parallel) {
      return null;
    }
    return (data as ParallelData).data[dim.index].data;
  }
}
