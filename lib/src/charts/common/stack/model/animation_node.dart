import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class StackAnimatorNode with ExtProps {
  static final none = StackAnimatorNode();
  final Rect? rect;
  final Offset? offset;
  final Arc? arc;

  StackAnimatorNode({this.rect, this.offset, this.arc});

  @override
  String toString() {
    return "R:$rect";
  }
}
