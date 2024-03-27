import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class AxisLabelDrawable extends Drawable {
  final int index;
  final int maxIndex;
  final TextDraw label;
  List<AxisLabelDrawable> minorLabel;

  AxisLabelDrawable(
    this.index,
    this.maxIndex,
    this.label, [
    this.minorLabel = const [],
  ]);

  @override
  void draw(CCanvas canvas, Paint paint) {
    label.draw(canvas, paint);
    each(minorLabel, (p0, p1) {
      p0.draw(canvas, paint);
    });
  }

  @override
  void dispose() {
    super.dispose();
    label.dispose();
    each(minorLabel, (p0, p1) {
      p0.dispose();
    });
    minorLabel = [];
  }
}
