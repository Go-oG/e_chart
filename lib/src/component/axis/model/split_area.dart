import 'package:e_chart/e_chart.dart';

class SplitArea extends ChartNotifier2 {
  bool show;
  int interval;
  AreaStyle? style;
  Fun3<int, int, AreaStyle>? splitAreaFun;

  SplitArea({
    this.show = false,
    this.interval = -1,
    this.style,
    this.splitAreaFun,
  });

  AreaStyle getStyle(int index, int maxIndex, AxisTheme theme) {
    if (!show) {
      return AreaStyle.empty;
    }
    AreaStyle? style;
    if (splitAreaFun != null) {
      style = splitAreaFun?.call(index, maxIndex);
    } else {
      if (this.style != null) {
        style = this.style;
      } else {
        style = theme.getSplitAreaStyle(index);
      }
    }
    return style ?? AreaStyle.empty;
  }



}
