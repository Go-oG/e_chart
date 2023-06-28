import 'package:flutter/material.dart';

import '../../style/index.dart';

enum AxisPointerType {
  //直线指示器
  line,
  //阴影指示器
  shadow,
  //十字准星指示器(实质是两个正交的轴)
  cross,
  none,
}

enum AxisPointerAxis {
  x,
  y,
  radius,
  angle,
  auto,
}

/// 坐标轴指示器
class AxisPointer {
  bool show;
  AxisPointerType type;
  AxisPointerAxis axis;

  //坐标轴指示器是否自动吸附到点上。默认自动判断
  bool? snap;

  //type==line 是有效
  LineStyle? lineStyle;

  //type==shadow 是有效
  BoxShadow? shadowStyle;

  //type==cross有效
  LineStyle? crossStyle;
  LabelStyle labelStyle;

  AxisPointer({
    this.show = false,
    this.type = AxisPointerType.none,
    this.axis = AxisPointerAxis.auto,
    this.snap,
    this.lineStyle,
    this.shadowStyle,
    this.crossStyle,
    this.labelStyle = const LabelStyle(),
  });
}
