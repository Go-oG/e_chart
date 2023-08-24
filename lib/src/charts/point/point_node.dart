import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class PointNode extends DataNode<PointSize, PointData> {
  final PointGroup group;
  ChartSymbol symbol;

  PointNode(this.symbol, this.group, super.data, super.dataIndex, super.groupIndex, super.attr);

  bool internal(Offset offset) {
    return symbol.internal2(attr.offset,attr.size,offset);
  }
}

class PointSize {
  Offset offset = Offset.zero;
  Size size = Size.zero;

  PointSize();

  PointSize.all(this.offset, this.size);

  @override
  String toString() {
    return "$runtimeType offset:$offset size:$size";
  }
}
