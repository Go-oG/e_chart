import 'dart:ui';

import '../../../style/line_style.dart';
import '../theme.dart';

class CandlestickTheme {
  num borderWidth = 1;
  Color borderColor = const Color(0xFFCCCCCC);

  LineStyle? getBorderStyle() {
    if (borderWidth <= 0) {
      return null;
    }
    return LineStyle(color: borderColor, width: borderWidth);
  }
}
