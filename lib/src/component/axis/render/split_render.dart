import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class SplitAreaDrawable extends Drawable {
  late List<dynamic> data;
  Path path;
  AreaStyle style;

  SplitAreaDrawable(dynamic data, this.path, this.style) {
    if (data is List<dynamic>) {
      this.data = data;
    } else {
      this.data = [data];
    }
  }

  @override
  void draw(CCanvas canvas, Paint paint) {
    style.drawPath(canvas, paint, path);
  }
}
