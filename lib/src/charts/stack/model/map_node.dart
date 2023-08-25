import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class StackAnimationNode with ExtProps {
  static final none = StackAnimationNode();
  final Rect? rect;
  final Offset? offset;
  final Arc? arc;
  StackAnimationNode({this.rect, this.offset, this.arc});
}
