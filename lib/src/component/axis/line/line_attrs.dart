import 'dart:ui';

import 'package:e_chart/src/component/axis/axis_attrs.dart';
import 'package:e_chart/src/ext/offset_ext.dart';

class LineAxisAttrs extends AxisAttrs {
  Rect rect;

  //轴线的起始和结束位置
  Offset start;
  Offset end;

  ///存储文字的最大宽度和高度
  Size textStartSize;
  Size textEndSize;

  LineAxisAttrs(
    this.rect,
    this.start,
    this.end, {
    this.textStartSize = Size.zero,
    this.textEndSize = Size.zero,
  });

  double get distance => start.distance2(end);
}
