import 'dart:ui';
import 'package:e_chart/e_chart.dart';

class HexbinNode extends DataNode<HexAttr, ItemData> {
  HexbinNode(super.data, super.dataIndex, super.groupIndex, super.attr);
}

class HexAttr {
  static final HexAttr zero = HexAttr.all(Hex(0, 0, 0), PositiveShape(count: 0), Offset.zero);
  final Hex hex;
  late PositiveShape shape;
  late Offset center;
  double alpha = 1;

  HexAttr(this.hex);

  HexAttr.all(this.hex, this.shape, this.center);

  HexAttr copy({double? alpha}) {
    var attr = HexAttr.all(hex, shape, center);
    attr.alpha = alpha ?? this.alpha;
    return attr;
  }
}
