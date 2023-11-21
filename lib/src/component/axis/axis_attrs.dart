import 'package:e_chart/e_chart.dart';

class AxisAttrs extends Disposable {
  //缩放比例
  final double scaleRatio;

  ///强制分割的TickCount
  final int? splitCount;

  ///滚动偏移量
  double scroll;

  AxisAttrs(this.scaleRatio, this.scroll, {this.splitCount});
}
