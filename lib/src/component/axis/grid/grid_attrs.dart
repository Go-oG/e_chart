import '../../../model/data.dart';
import '../axis_attrs.dart';
import '../base/line/line_attrs.dart';

class GridAxisAttr extends LineAxisAttrs {
  DynamicText maxStr;

  GridAxisAttr(
    super.axisIndex,
    super.rect,
    super.start,
    super.end,
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
      maxStr,
      scaleRatio: scaleRatio,
      scrollX: scrollX,
      scrollY: scrollY,
      splitCount: splitCount,
    );
  }
}
