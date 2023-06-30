import 'package:e_chart/src/component/axis/axis_label.dart';
import 'package:flutter/material.dart';

import '../../functions.dart';
import '../../model/dynamic_data.dart';
import '../../style/line_style.dart';
import '../tick/main_tick.dart';

//坐标轴样式相关的配置
class AxisLine {
  bool show;
  AxisLabel? label;
  AxisSymbol symbol; //控制是否显示箭头
  Size symbolSize;
  Offset symbolOffset;
  LineStyle style;
  MainTick tick = MainTick();
  Fun3<DynamicData, DynamicData, LineStyle?>? styleFun;
  Fun3<DynamicData, DynamicData, MainTick?>? tickFun;

  AxisLine({
    this.show = true,
    this.label,
    this.symbol = AxisSymbol.none,
    this.symbolSize = const Size(10, 15),
    this.symbolOffset = Offset.zero,
    MainTick? tick,
    this.style = const LineStyle(color: Colors.black87, smooth: false, width: 1),
    this.styleFun,
    this.tickFun,
  }) {
    if (tick != null) {
      this.tick = tick;
    }
  }
}

enum AxisSymbol { none, single, double }
