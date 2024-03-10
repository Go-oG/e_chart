import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class ChartTitle extends ChartNotifier2 {
  bool show = false;
  Align2 mainAlign = Align2.start;
  Align2 crossAlign = Align2.start;

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

  ChartTitle();

  @override
  void dispose() {
    textStyle = LabelStyle.empty;
    subTextStyle = LabelStyle.empty;
    decoration = const BoxDecoration();
    super.dispose();
  }

}
