import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class AnimatorNode with ExtProps {
  static final none = AnimatorNode();
  final Rect? rect;
  final Offset? offset;
  final Arc? arc;
  AnimatorNode({this.rect, this.offset, this.arc});
}
