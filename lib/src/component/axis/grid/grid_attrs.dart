import 'dart:ui';

import '../../../model/data.dart';
import '../axis_attrs.dart';
import '../line/line_attrs.dart';

class GridAxisAttr extends LineAxisAttrs {
  Rect coordRect;
  Rect contentBox;
  DynamicText maxStr;

  GridAxisAttr(
    super.axisIndex,
    super.rect,
    super.start,
    super.end,
    this.coordRect,
    this.contentBox,
    this.maxStr, {
    super.scaleRatio,
    super.scrollX,
    super.scrollY,
    super.splitCount,
  });

  @override
  AxisAttrs copy() {
    return GridAxisAttr(
      axisIndex,
      rect,
      start,
      end,
      coordRect,
      contentBox,
      maxStr,
      scaleRatio: scaleRatio,
      scrollX: scrollX,
      scrollY: scrollY,
      splitCount: splitCount,
    );
  }
}
