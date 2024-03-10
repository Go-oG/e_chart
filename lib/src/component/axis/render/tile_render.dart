import 'package:e_chart/e_chart.dart';
import 'package:flutter/rendering.dart';

///标识坐标轴的Title
class AxisTitleRender extends ElementRender {
  AxisName? name;
  late TextDraw label;

  AxisTitleRender(this.name) {
    label = TextDraw(name?.name ?? DynamicText.empty, LabelStyle.empty, Offset.zero, align: Alignment.center);
  }

  @override
  void dispose() {
    super.dispose();
    label.dispose();
    label = TextDraw.empty;
    name = null;
  }

  @override
  void draw(CCanvas canvas, Paint paint) {
    label.draw(canvas, paint);
  }
}
