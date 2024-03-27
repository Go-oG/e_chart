import 'package:e_chart/e_chart.dart';

///折线图主题
class LineTheme {
  num lineWidth = 2;
  List<num> dashList = [];
  bool fill = false;
  double opacity = 0.5;
  ChartSymbol symbol = EmptySymbol();
  bool showSymbol = true;
  num smooth = 0;

  LineStyle getLineStyle(ChartTheme theme, int index) {
    return LineStyle(color: theme.getColor(index), width: lineWidth, dash: dashList, smooth: smooth);
  }
}
