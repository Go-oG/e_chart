import 'package:flutter/material.dart';

import '../../model/enums/align.dart';
import '../../model/enums/align2.dart';

class ChartTitle {
  String? id;
  bool show = false;
  ChartAlign position = ChartAlign.topLeft;
  String text = '';
  TextStyle textStyle = const TextStyle();
  VoidCallback? textClick;
  String subText = '';
  TextStyle subTextStyle = const TextStyle();
  VoidCallback? subTextClick;
  num itemGap = 10;
  bool triggerEvent = false;

  Align2 textAlign = Align2.center;
  Align2 textVerticalAlign = Align2.center;

  EdgeInsetsGeometry padding = const EdgeInsets.all(5);
  EdgeInsetsGeometry margin = EdgeInsets.zero;
  Decoration decoration = const BoxDecoration();

}
