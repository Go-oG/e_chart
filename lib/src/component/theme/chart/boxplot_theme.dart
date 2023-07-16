import '../../../style/line_style.dart';
import '../theme.dart';
class BoxplotTheme {
  num borderWidth = 1;

  LineStyle getBorderStyle(ChartTheme theme, int index) {
    if (borderWidth <= 0) {
      borderWidth = 1;
    }
    return LineStyle(color: theme.getColor(index), width: borderWidth);
  }
}

