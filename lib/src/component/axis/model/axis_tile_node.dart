import 'package:flutter/rendering.dart';

import '../../../model/dynamic_text.dart';
import '../../../model/text_position.dart';

///标识坐标轴的Title
class AxisTitleNode {
  final DynamicText? label;
  TextDrawConfig config = TextDrawConfig(Offset.zero, align: Alignment.center);

  AxisTitleNode(this.label);
}
