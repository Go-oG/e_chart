import 'dart:ui';

import 'package:e_chart/e_chart.dart';

import '../../../../core/disposable.dart';

class LinePainter extends Disposable with ExtProps {
  final int index;
  final int maxIndex;
  final Offset start;
  final Offset end;

  LinePainter(this.index, this.maxIndex, this.start, this.end);
}
