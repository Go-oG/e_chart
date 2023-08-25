
import 'package:e_chart/src/charts/point/point_view.dart';

import '../../core/index.dart';
import '../../functions.dart';
import '../../model/enums/coordinate.dart';
import 'point_data.dart';
import '../../symbol/chart_symbol.dart';

class PointSeries extends RectSeries {
  List<PointGroup> data;
  Fun3<PointData,PointGroup, ChartSymbol> symbolFun;

  PointSeries(
    this.data, {
    required this.symbolFun,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.gridIndex,
    super.polarIndex = 0,
    super.calendarIndex = 0,
    super.coordType = CoordType.grid,
    super.tooltip,
    super.animation,
    super.backgroundColor,
    super.id,
    super.clip,
    super.z,
  }) : super(radarIndex: -1, parallelIndex: -1);

  @override
  ChartView? toView() {
    return PointView(this);
  }

}
