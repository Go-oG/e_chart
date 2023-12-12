import '../../../model/data.dart';
import '../../index.dart';

class GridAxisAttr extends LineAxisAttrs {
  DynamicText maxStr;

  GridAxisAttr(
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
