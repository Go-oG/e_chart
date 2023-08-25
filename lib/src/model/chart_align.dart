import 'package:e_chart/src/model/text_info.dart';
import 'package:flutter/painting.dart';

import '../component/style/index.dart';
import '../utils/align_util.dart';
import 'enums/direction.dart';

class ChartAlign {
  final Alignment align;
  final bool inside;

  const ChartAlign({this.align = Alignment.center, this.inside = true});

  TextDrawInfo convert(Rect rect, LabelStyle style, Direction direction) {
    double x = rect.center.dx + align.x * rect.width / 2;
    double y = rect.center.dy + align.y * rect.height / 2;

    if (!inside) {
      double lineWidth = (style.guideLine?.length ?? 0).toDouble();
      List<num> lineGap = (style.guideLine?.gap ?? [0, 0]);
      if (direction == Direction.vertical) {
        int dir = align.x > 0 ? 1 : -1;
        x += dir * (lineWidth + lineGap[0]);
      } else {
        int dir = align.y > 0 ? 1 : -1;
        y += dir * (lineWidth + lineGap[1]);
      }
    }
    Offset offset = Offset(x, y);
    Alignment textAlign = toInnerAlign(align);
    if (!inside) {
      textAlign = Alignment(-textAlign.x, -textAlign.y);
    }
    return TextDrawInfo(offset, align: textAlign);
  }
}
