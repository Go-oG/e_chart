import 'dart:ui';

import '../../symbol/chart_symbol.dart';
import '../../symbol/circle_symbol.dart';

class GraphTheme {
  num borderWidth = 0;
  Color borderColor = const Color(0xFFCCCCCC);
  num lineWidth = 1;
  Color lineColor = const Color(0xFFAAAAAA);
  bool lineSmooth = false;
  ChartSymbol symbol = CircleSymbol();
  List<Color> colors = [
    const Color(0xFF5470c6),
    const Color(0xFF91cc75),
    const Color(0xFFfac858),
    const Color(0xFFee6666),
    const Color(0xFF73c0de),
    const Color(0xFF3ba272),
    const Color(0xFFfc8452),
    const Color(0xFF9a60b4),
    const Color(0xFFea7ccc),
  ];
  Color labelColor = const Color(0xFFEEEEEE);
}