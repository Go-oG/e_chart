import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/component/brush/brush.dart';

import 'brush_area.dart';

///框选实现
class BrushView extends ChartView {
  final Brush brush;
  final List<BrushArea> brushList = [];

  BrushView(this.brush);

  @override
  void onStart() {
    brush.addListener(() {
      if (brush.value.code == Brush.clearCommand.code) {
        brushList.clear();
      }
    });
    super.onStart();
  }

  @override
  void onStop() {
    brush.clearListener();
    super.onStop();
  }

  @override
  void onDestroy() {
    brushList.clear();
    super.onDestroy();
  }

  @override
  void onDraw(Canvas canvas) {}



}
