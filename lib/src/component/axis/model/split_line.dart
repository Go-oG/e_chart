import 'package:e_chart/e_chart.dart';

///坐标轴在grid区域中的分隔线
class SplitLine extends ChartNotifier2 {
  bool show;
  int interval;

  LineStyle? style;
  Fun3<int, int, LineStyle>? styleFun;

  LineStyle? minorStyle;
  Fun3<int, int, LineStyle>? minorStyleFun;

  SplitLine({
    this.show = false,
    this.interval = -1,
    this.style,
    this.styleFun,
    this.minorStyle,
    this.minorStyleFun,
  });

  LineStyle getStyle(int index, int maxIndex, AxisTheme theme) {
    if (!show) {
      return LineStyle.empty;
    }
    LineStyle? style;
    if (styleFun != null) {
      style = styleFun?.call(index, maxIndex);
    } else {
      if (this.style != null) {
        style = this.style;
      } else {
        style = theme.getSplitLineStyle(index);
      }
    }
    return style ?? LineStyle.empty;
  }

  bool get isEnable {
    if (!show) {
      return false;
    }
    if (styleFun != null || minorStyleFun != null) {
      return true;
    }

    if (style != null && style!.canDraw) {
      return true;
    }
    if (minorStyle != null && minorStyle!.canDraw) {
      return true;
    }
    return false;
  }

  LineStyle getMinorStyle(int index, int maxIndex, AxisTheme theme) {
    if (!show) {
      return LineStyle.empty;
    }
    LineStyle? style;
    if (minorStyleFun != null) {
      style = minorStyleFun?.call(index, maxIndex);
    } else {
      if (minorStyle != null) {
        style = minorStyle;
      } else {
        style = theme.getSplitLineStyle(index);
      }
    }
    return style ?? LineStyle.empty;
  }
}
