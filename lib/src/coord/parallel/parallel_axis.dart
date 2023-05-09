import 'package:flutter/material.dart';

import '../../component/axis/base_axis.dart';

///平行坐标系坐标轴
@immutable
class ParallelAxis extends BaseAxis {
  final int parallelIndex;
  final bool realTime;

  const ParallelAxis({
    this.parallelIndex = 0,
    this.realTime = true,
    super.nameAlign,
    super.nameStyle,
    super.nameGap,
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
    super.inverse,
    super.categoryList,
    super.timeRange,
    super.timeSplitType,
    super.silent,
    super.axisLine,
    super.formatFun,
  });
}
