import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class CandlestickNode with ViewStateProvider{
  final CandleStickData data;
  late Path path;
  late Path areaPath;

  CandlestickNode(this.data);

}