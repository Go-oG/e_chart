import 'package:e_chart/e_chart.dart';

///轴名字配置
class AxisName extends ChartNotifier2{


  DynamicText name;
  Align2 align;
  num nameGap;
  LabelStyle labelStyle;
  num rotate;

  AxisName(
    this.name, {
    this.align = Align2.end,
    this.nameGap = 8,
    this.labelStyle = const LabelStyle(),
    this.rotate = 0,
  });
}
