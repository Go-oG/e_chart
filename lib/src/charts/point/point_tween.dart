import 'dart:ui';

import 'package:e_chart/src/charts/point/point_node.dart';

import '../../animation/chart_tween.dart';

class PointSizeTween extends ChartTween<PointSize> {
  PointSizeTween(super.begin, super.end, {super.allowCross, super.props});

  @override
  PointSize convert(double animatorPercent) {
    PointSize size = PointSize();
    if (begin.offset == end.offset) {
      size.offset = end.offset;
    } else {
      size.offset = Offset.lerp(begin.offset, end.offset, animatorPercent)!;
    }
    if (begin.size == end.size) {
      size.size = end.size;
    } else {
      size.size = Size.lerp(begin.size, end.size, animatorPercent)!;
    }
    return size;
  }
}