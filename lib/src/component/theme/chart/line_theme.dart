import '../../../style/label.dart';
import '../../../style/line_style.dart';
import '../../../symbol/chart_symbol.dart';
import '../../../symbol/circle_symbol.dart';
import '../theme.dart';
///折线图主题
class LineTheme {
  num lineWidth = 2;
  List<num> dashList = [];
  bool fill = false;
  double opacity = 0.5;
  ChartSymbol symbol = CircleSymbol();
  bool showSymbol = false;
  bool smooth = false;

  LineStyle getLineStyle(ChartTheme theme, int index) {
    return LineStyle(color: theme.getColor(index), width: lineWidth, dash: dashList, smooth: smooth);
  }
}
