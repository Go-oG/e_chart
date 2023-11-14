import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///层次结构通用抽象布局者
abstract class HierarchyLayout<T, S extends ChartSeries> extends Disposable {
  ///该方法会被多次调用
  ///每次布局可能只需要布局其子节点，或者布局全部
  void onLayout(T data, covariant HierarchyOption<S> params);
}

class HierarchyOption<S extends ChartSeries> {
  final S series;
  final double width;
  final double height;

  final Rect boxBound;
  final Rect globalBoxBound;

  HierarchyOption(
    this.series,
    this.width,
    this.height,
    this.boxBound,
    this.globalBoxBound,
  );
}
