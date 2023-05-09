import 'package:flutter/material.dart';

import '../../component/axis/axis_pointer.dart';
import '../../component/axis/base_axis.dart';
import '../../style/line_style.dart';

///极坐标-角度轴
class AngleAxis extends BaseAxis {
  /// 起始刻度的角度，默认为90度(圆心的正上方为0度)
  final num offsetAngle;
  final num sweepAngle;
  final num radiusOffset;

  ///是否顺时针
  final bool clockwise;

  final AxisPointer axisPointer;
  final LineStyle? subAxisStyle;
  final LineStyle? tipLineStyle;

  const AngleAxis({
    this.offsetAngle = 0,
    this.sweepAngle = 360,
    this.radiusOffset = 0,
    this.clockwise = true,
    this.axisPointer = const AxisPointer(),
    this.subAxisStyle = const LineStyle(color: Colors.black45),
    this.tipLineStyle = const LineStyle(color: Colors.black54, dash: [2, 6]),
    super.show,
    super.name,
    super.type = AxisType.value,
    super.min,
    super.max,
    super.splitNumber,
    super.start0,
    super.logBase,
    super.interval,
    super.maxInterval,
    super.minInterval,
    super.categoryList,
    super.timeRange,
    super.timeSplitType,
    super.silent,
    super.axisLine,
    super.formatFun,
    super.nameAlign,
    super.nameGap,
    super.nameStyle,
  }) : super(inverse: false);
}
