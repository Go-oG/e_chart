import 'package:flutter/material.dart';

import '../../model/enums/align2.dart';
import '../style/label.dart';

class ChartTitle {
  bool show = false;

  Align2 position = Align2.start;
  Align2 align=Align2.start;
  Offset offset = const Offset(8, 8);

  String text = '';
  String subText = '';

  num gap = 10;
  bool triggerEvent = false;

  Align2 textAlign = Align2.center;
  Align2 textVerticalAlign = Align2.center;

  EdgeInsets padding = const EdgeInsets.all(5);

  LabelStyle textStyle = const LabelStyle();
  LabelStyle subTextStyle = const LabelStyle();

  Decoration decoration = const BoxDecoration();
  VoidCallback? textClick;
  VoidCallback? subTextClick;
}
