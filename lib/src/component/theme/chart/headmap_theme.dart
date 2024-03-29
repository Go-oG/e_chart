import 'dart:ui';

import '../../../style/label.dart';
import '../../../style/line_style.dart';
import '../theme.dart';
class HeadMapTheme {
  num borderWidth = 0;
  Color borderColor = const Color(0xFFEEEEEE);

  LineStyle? getBorderStyle() {
    if (borderWidth > 0) {
      return LineStyle(color: borderColor, width: borderWidth);
    }
    return null;
  }

  LabelStyle labelStyle = const LabelStyle();
}