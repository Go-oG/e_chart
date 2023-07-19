import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class CandlestickGroupNode{
  final CandleStickGroup data;
  List<CandlestickNode> nodeList;
  CandlestickGroupNode(this.data,this.nodeList);
}


class CandlestickNode with ViewStateProvider{
  final CandleStickGroup parent;
  final CandleStickData data;

  late Path path;
  late Path areaPath;

  CandlestickNode(this.parent,this.data);

}