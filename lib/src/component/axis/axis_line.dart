import 'package:flutter/material.dart';

import '../../functions.dart';
import '../../model/dynamic_data.dart';
import '../../style/line_style.dart';
import '../tick/main_tick.dart';

//轴线
class AxisLine {
  final bool show;
  final AxisSymbol symbol; //控制是否显示箭头
  final Size symbolSize;
  final Offset symbolOffset;

  final LineStyle style;
  final StyleFun2<DynamicData, DynamicData, LineStyle>? styleFun;

  ///Tick 相关
  final MainTick? tick;
  final StyleFun2<DynamicData, DynamicData, MainTick>? tickFun;

  const AxisLine({
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
