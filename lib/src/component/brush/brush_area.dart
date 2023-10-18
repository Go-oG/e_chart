import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class BrushArea {
  final BrushType type;
  final List<Offset> offsetList;
  late final Path path;
  late final Rect bounds;

  BrushArea(this.type,this.offsetList) {
    path = Path();
    each(offsetList, (offset, i) {
      if (i == 0) {
        path.moveTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    });
    if (offsetList.length > 2) {
      path.close();
    }
    bounds=path.getBounds();
  }
}
