import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class CandlestickGroupNode{
  final CandleStickGroup data;
  List<CandlestickNode> nodeList;
  CandlestickGroupNode(this.data,this.nodeList);
}


class CandlestickNode extends DataNode<List<Path>,CandleStickData>{
  final CandleStickGroup parent;
  late Path path;
  late Path areaPath;

  CandlestickNode(this.parent,CandleStickData data,int dataIndex,int groupIndex):super(data,dataIndex,groupIndex,[]);

}