import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/core/render/element_render.dart';

class SplitAreaRender extends ElementRender {
 late  List<dynamic> data;
  Path path;
  AreaStyle style;

  SplitAreaRender(dynamic data, this.path, this.style){
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
