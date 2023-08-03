import 'dart:ui';

import '../../functions.dart';
import '../../model/enums/coordinate.dart';
import 'point_data.dart';
import '../../core/series.dart';
import '../../symbol/chart_symbol.dart';
import 'point_node.dart';

class PointSeries extends RectSeries {
  List<PointData> data;
  Fun2<PointNode, ChartSymbol> symbolStyle;
  Fun3<PointNode, Offset, bool>? includeFun;

  PointSeries(
    this.data, {
    required this.symbolStyle,
    this.includeFun,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.gridIndex,
    super.polarIndex = 0,
    super.calendarIndex = 0,
    super.coordSystem = CoordSystem.grid,
    super.tooltip,
    super.animation,
    super.backgroundColor,
    super.id,
    super.clip,
    super.z,
  }) : super(
          radarIndex: -1,
          parallelIndex: -1,
        );
}
