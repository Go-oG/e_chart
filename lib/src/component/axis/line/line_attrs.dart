import 'dart:ui';

import 'package:e_chart/src/component/axis/axis_attrs.dart';
import 'package:e_chart/src/ext/offset_ext.dart';

///用于直线轴绘制
class LineAxisAttrs extends AxisAttrs {
  ///表示该直线轴在坐标系中的位置区域
  final Rect rect;
  ///表示轴线的起始和结束位置(其距离一定==rect.width或者rect.height)
  final Offset start;
  final Offset end;

  LineAxisAttrs(super.scaleRatio, super.scroll, this.rect, this.start, this.end,{super.splitCount});

  LineAxisAttrs copyWith({
    double? scaleRatio,
    double? scroll,
    Rect? rect,
    Offset? start,
    Offset? end,
    int? splitCount,
  }) {
    return LineAxisAttrs(
      scaleRatio ?? this.scaleRatio,
      scroll ?? this.scroll,
      rect ?? this.rect,
      start ?? this.start,
      end ?? this.end,
      splitCount: splitCount
    );
  }

  double get distance => start.distance2(end) * scaleRatio;
}
