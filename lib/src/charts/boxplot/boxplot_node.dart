import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class BoxplotNode with ViewStateProvider{
  final BoxplotData data;

  BoxplotNode(this.data);

  late Path path;
  late Path areaPath;

}