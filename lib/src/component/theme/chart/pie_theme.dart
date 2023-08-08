
import 'dart:ui';

import '../../../style/line_style.dart';

class PieTheme {
  num borderWidth = 0;
  Color borderColor = const Color(0xFFCCCCCC);
  List<num> dashList = [];

  LineStyle? getBorderStyle() {
    if (borderWidth <= 0) {
      return null;
    }
    return LineStyle(color: borderColor, width: borderWidth, dash: dashList);
  }
}
