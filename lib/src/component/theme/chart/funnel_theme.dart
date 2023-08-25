import 'dart:ui';

import '../../style/label.dart';
import '../../style/line_style.dart';

class FunnelTheme {
  num borderWidth = 0;
  List<num> borderDash = [];
  Color borderColor = const Color(0xFFCCCCCC);

  LabelStyle labelStyle = const LabelStyle();
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

  LineStyle? getBorderStyle(){
    if(borderWidth<=0){return null;}
    return LineStyle(width: borderWidth,dash: borderDash,color: borderColor);
  }


}