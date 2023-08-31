import 'package:e_chart/e_chart.dart';

class ParallelTheme extends BorderTheme {
  LineStyle? getItemStyle(Context context,int index) {
    if (width <= 0) {
      width = 1;
    }
    return LineStyle(
      color: context.option.theme.getColor(index),
      width: width,
      dash: dash,
      shadow: shadow,
      shader: shader,
      smooth: smooth,
      align: align,
    );
  }
}
