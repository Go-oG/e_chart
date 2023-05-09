import 'dart:ui';

import '../coord_layout.dart';

///用于包装child
class SingleLayout extends CoordinateLayout {
  SingleLayout();

  @override
  dataToPoint(covariant x, covariant y) {
    return Offset.zero;
  }
}
