import 'package:e_chart/e_chart.dart';

///记录每个坐标轴的基础属性
class AxisAttrs extends Disposable {
  //缩放比例
  double scaleRatio;

  ///强制分割的TickCount
  int? splitCount;

  ///滚动偏移量
  double scrollX;
  double scrollY;

  AxisAttrs({
    this.splitCount,
    this.scaleRatio = 1,
    this.scrollX = 0,
    this.scrollY = 0,
  });

  AxisAttrs copy() {
    return AxisAttrs(
      splitCount: splitCount,
      scaleRatio: scaleRatio,
      scrollX: scrollX,
      scrollY: scrollY,
    );
  }
}
