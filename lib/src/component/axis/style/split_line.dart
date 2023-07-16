import '../../../functions.dart';
import '../../../style/index.dart';
import '../../theme/axis_theme.dart';

///坐标轴在grid区域中的分隔线
class SplitLine {
  bool show;
  int interval;
  LineStyle? style;

  Fun3<int, int, LineStyle?>? splitLineFun;

  SplitLine({
    this.show = false,
    this.interval = -1,
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
