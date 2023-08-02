import 'package:flutter/material.dart';

import '../../functions.dart';
import '../../model/enums/align2.dart';
import '../../model/enums/direction.dart';
import '../../model/enums/sort.dart';
import '../../model/data.dart';
import '../../model/string_number.dart';
import '../../style/area_style.dart';
import '../../style/label.dart';
import '../../style/line_style.dart';
import '../../core/series.dart';
import 'funnel_node.dart';

class FunnelAlign {
  final Alignment align;
  final bool inside;

  const FunnelAlign({this.align = Alignment.center, this.inside = true});
}

class FunnelSeries extends RectSeries {
  List<ItemData> dataList;
  double? maxValue;
  SNumber? itemHeight;
  FunnelAlign labelAlign;
  Direction direction;
  Sort sort;
  double gap;
  Align2 align;
  Fun2<FunnelNode, AreaStyle>? areaStyleFun;
  Fun2<FunnelNode, LineStyle?>? borderStyleFun;

  Fun2<FunnelNode, LabelStyle>? labelStyleFun;
  Fun2<FunnelNode, LineStyle>? labelLineStyleFun;

  FunnelSeries(
    this.dataList, {
    this.labelAlign = const FunnelAlign(),
    this.maxValue,
    this.direction = Direction.vertical,
    this.sort = Sort.empty,
    this.gap = 2,
    this.align = Align2.center,
    this.labelStyleFun,
    this.labelLineStyleFun,
    this.areaStyleFun,
    this.borderStyleFun,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.animation,
    super.enableClick,
    super.enableHover,
    super.enableDrag,
    super.enableScale,
    super.backgroundColor,
    super.id,
    super.clip,
    super.tooltip,
    super.z,
  }) : super(
          coordSystem: null,
          calendarIndex: -1,
          parallelIndex: -1,
          polarIndex: -1,
          radarIndex: -1,
          gridIndex: -1,
        );
}
