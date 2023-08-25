import 'dart:ui';
import 'package:e_chart/e_chart.dart';

class HexbinNode extends DataNode<HexAttr, ItemData> {
  HexbinNode(super.data, super.dataIndex, super.groupIndex, super.attr);
}

class HexAttr {
  //Hex 坐标
  Hex hex = Hex(0, 0, 0);

  PositiveShape shape = PositiveShape(count: 0);
  Offset center = Offset.zero;
}
