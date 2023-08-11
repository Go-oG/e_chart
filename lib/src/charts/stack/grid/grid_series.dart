import 'package:e_chart/e_chart.dart';

class GridSeries<T extends StackItemData, G extends StackGroupData<T>> extends StackSeries<T, G> {
  GridSeries(
    super.data, {
    super.direction = Direction.vertical,
    super.dynamicRange,
    super.realtimeSort,
    super.dynamicLabel,
    super.selectedMode,
    super.animatorStyle,
    super.legendHoverLink,
    super.sort,
    super.sortCount,
    super.corner,
    super.columnGap,
    super.groupGap,
    super.innerGap,
    super.labelAlignFun,
    super.groupStyleFun,
    super.labelStyle,
    super.lineStyleFun,
    super.areaStyleFun,
    super.labelFormatFun,
    super.labelStyleFun,
    super.markLine,
    super.markPoint,
    super.markPointFun,
    super.markLineFun,
    super.animation,
    super.backgroundColor,
    super.clip,
    super.coordSystem,
    super.gridIndex,
    super.polarIndex,
    super.id,
    super.tooltip,
    super.z,
  });

  @override
  DataHelper<T, G, StackSeries<StackItemData, StackGroupData<StackItemData>>> buildHelper() {
    if (realtimeSort && data.isNotEmpty) {
      if (data.length > 1) {
        throw ChartError("当启用了实时排序后，只支持一个数据组");
      }
      G group = data.first;
      int c = sortCount ?? -1;
      if (c <= 0) {
        c = group.data.length;
      }
      if (c > group.data.length) {
        c = group.data.length;
      }
      group.data.sort((a, b) {
        num ai = a == null ? (sort == Sort.desc ? double.maxFinite : double.minPositive) : (isVertical ? a.y : a.x);
        num bi = b == null ? (sort == Sort.desc ? double.maxFinite : double.minPositive) : (isVertical ? b.y : b.x);
        if (sort == Sort.desc) {
          return bi.compareTo(ai);
        } else {
          return ai.compareTo(bi);
        }
      });
      if (c != group.data.length) {
        group.data.removeRange(c, group.data.length);
      }
      return DataHelper(this, [group], direction, true, sort);
    }
    return super.buildHelper();
  }
}
