import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class PointNode extends DataNode<Offset, PointData> {
  ChartSymbol? symbol;
  PointNode(super.data, super.dataIndex, super.groupIndex, super.attr);

  bool internal(Offset offset){
    return symbol?.internal(offset)??false;
  }
}
