import 'package:flutter/material.dart';

import '../../functions.dart';
import '../../model/dynamic_data.dart';
import '../../style/line_style.dart';
import '../tick/main_tick.dart';

//轴线
class AxisLine {
   bool show;
   AxisSymbol symbol; //控制是否显示箭头
   Size symbolSize;
   Offset symbolOffset;

   LineStyle style;
   Fun3<DynamicData, DynamicData, LineStyle?>? styleFun;

  ///Tick 相关
   MainTick? tick;
   Fun3<DynamicData, DynamicData, MainTick?>? tickFun;

   AxisLine({
    this.show = true,
    this.symbol = AxisSymbol.none,
    this.symbolSize = const Size(10, 15),
    this.symbolOffset = Offset.zero,
    this.tick,
    this.style = const LineStyle(color: Colors.black45, smooth: false),
    this.styleFun,
    this.tickFun,
  });
}

enum AxisSymbol { none, single, double }
