import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class PointNode with ViewStateProvider {
  final PointData data;
  Rect rect = Rect.zero;

  PointNode(this.data);
}
