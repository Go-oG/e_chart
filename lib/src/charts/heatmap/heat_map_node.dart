import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class HeatMapNode with ViewStateProvider{
  final HeatMapData data;

  Rect rect=Rect.zero;

  HeatMapNode(this.data);
}