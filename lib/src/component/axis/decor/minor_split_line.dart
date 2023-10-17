import 'package:e_chart/e_chart.dart';

class MinorSplitLine extends ChartNotifier2 {
  bool show;
  LineStyle? style;
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

  LineStyle? getSplitLineStyle(int index, int maxIndex, AxisTheme theme) {
    if (!show) {
      return null;
    }
    LineStyle? style;
    if (splitLineFun != null) {
      style = splitLineFun?.call(index, maxIndex);
    } else {
      if (this.style != null) {
        style = this.style;
      } else {
        style = theme.getSplitLineStyle(index);
      }
    }
    return style;
  }
}
