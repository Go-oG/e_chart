import 'dart:ui';

import '../../../shape/arc.dart';

class MapNode {
  final Rect rect;
  final Offset offset;
  final Arc arc;

  const MapNode(this.rect, this.offset, this.arc);
}
