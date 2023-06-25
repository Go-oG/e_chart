import 'package:flutter/material.dart';

import '../../component/axis/base_axis.dart';
import '../../functions.dart';
import '../../model/enums/align2.dart';
import '../../style/area_style.dart';
import '../../style/line_style.dart';

///极坐标-径向轴
class RadiusAxis extends BaseAxis {
  final Align2 nameLocation;
  final num offsetAngle;
  final num nameRotate;

  final Fun3<double, dynamic, AreaStyle>? itemStyleFun;
  final Fun3<int, int, LineStyle>? axisStyleFun;

  final LineStyle? tipLineStyle;

  const RadiusAxis({
    this.nameLocation = Align2.end,
    this.offsetAngle = 0,
    this.nameRotate = 0,
    this.itemStyleFun,
    this.axisStyleFun,
    this.tipLineStyle=const LineStyle(color: Colors.black54,dash: [2,6]),
    super.show,
    super.name,
    super.nameGap = 15,
    super.nameAlign,
    super.nameStyle,
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
