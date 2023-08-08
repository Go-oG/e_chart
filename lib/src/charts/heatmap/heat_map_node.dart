import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class HeatMapNode extends DataNode<Rect, HeatMapData> {
  HeatMapNode(HeatMapData data,int dataIndex) : super(data,dataIndex,-1, Rect.zero);
}
