import 'package:dart_dagre/dart_dagre.dart';

import '../../../model/data.dart';
import 'item_data.dart';

class EdgeItemData extends BaseItemData {
  final GraphItemData source;
  final GraphItemData target;

  num minLen;
  num labelOffset;
  LabelPosition labelPos;
  num weight = 1;

  EdgeItemData(
    this.source,
    this.target, {
    this.labelOffset = 0,
    this.minLen = 1,
    this.weight = 1,
    this.labelPos = LabelPosition.center,
    super.id,
    super.label,
  });
}
