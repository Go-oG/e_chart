import 'package:flutter/material.dart';

import '../../component/tooltip/tool_tip.dart';
import '../../model/string_number.dart';
import '../../style/area_style.dart';
import '../../style/line_style.dart';

///笛卡尔坐标系
///一个Grid 最多可以同时放置上下两个X轴，左右两个Y轴
class Grid {
  ///grid区域是否包含坐标轴的刻度标签
  final bool containLabel;
  final AreaStyle style;
  final ToolTip? toolTip;
  final SNumber leftMargin;
  final SNumber topMargin;
  final SNumber rightMargin;
  final SNumber bottomMargin;
  final SNumber? width;
  final SNumber? height;
  final String id;
  final bool show;

  const Grid({
    this.containLabel = false,
    this.style = const AreaStyle(
      color: Colors.transparent,
      border: LineStyle(color: Color(0xFFCCCCCC), width: 1),
    ),
    this.toolTip,
    this.leftMargin = const SNumber.number(0),
    this.topMargin = const SNumber.number(0),
    this.rightMargin = const SNumber.number(0),
    this.bottomMargin = const SNumber.number(0),
    this.width,
    this.height,
    this.id='',
    this.show=true,
  });
}
