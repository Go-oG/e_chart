import 'package:e_chart/e_chart.dart';

class MinorSplitLine {
  bool show;
  LineStyle style = const LineStyle();
  Fun3<int, int, LineStyle?>? splitLineFun;

  MinorSplitLine({
    this.show = false,
    LineStyle? style,
    this.splitLineFun,
  }) {
    if (style != null) {
      this.style = style;
    }
  }



}
