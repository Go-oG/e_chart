import 'package:flutter/material.dart';

import '../../animation/animator_props.dart';
import '../../coord/parallel/parallel_child.dart';
import '../../core/view.dart';
import '../../model/dynamic_data.dart';
import 'layout.dart';
import 'parallel_series.dart';

//平行坐标系
class ParallelView extends ChartView implements ParallelChild {
  final ParallelSeries series;
  late final LayoutHelper _layout;
  List<ParallelDataLine> _result = [];

  ParallelView(this.series) {
    _layout = LayoutHelper(this);
  }

  @override
  void onAttach() {
    super.onAttach();
    AnimatorProps? info = series.animation;
    // if (info != null) {
    //   ChartDoubleTween tween = ChartDoubleTween.fromAnimator(info);
    //   tween.addListener(() {
    //
    //     invalidate();
    //   });
    //   tween.start(context.tickerProvider);
    // }
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    _result = _layout.layout(left, top, width, height);
  }

  @override
  void onDraw(Canvas canvas) {
    _drawData(canvas);
  }

  void _drawData(Canvas canvas) {
    canvas.save();
    for (var ele in _result) {
      if (ele.style == null) {
        continue;
      }
      if (ele.path == null) {
        if (ele.offsetList.length == 1) {
          ele.style?.drawPolygon(canvas, mPaint, ele.offsetList);
        }
        return;
      }
      ele.style?.drawPath(canvas, mPaint, ele.path!);
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
