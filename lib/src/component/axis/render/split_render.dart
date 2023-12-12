import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/core/render/element_render.dart';

class SplitAreaRender extends ElementRender {
  List<dynamic> data;
  Path path;
  AreaStyle style;

  SplitAreaRender(this.data, this.path, this.style);

  @override
  void draw(CCanvas canvas, Paint paint) {
    style.drawPath(canvas, paint, path);
  }

}
