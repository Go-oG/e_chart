//雷达图
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/radar/radar_view.dart';


class RadarSeries extends RectSeries {
  List<GroupData> data;
  int splitNumber;
  Fun2<GroupData, AreaStyle?>? areaStyleFun;
  Fun2<GroupData, LineStyle?>? lineStyleFun;
  Fun2<GroupData, LabelStyle>? labelStyleFun;
  Fun4<ItemData, int, GroupData, ChartSymbol?>? symbolFun;
  num nameGap;

  RadarSeries(
    this.data, {
    required this.splitNumber,
    this.areaStyleFun,
    this.symbolFun,
    this.labelStyleFun,
    this.nameGap = 0,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.radarIndex = 0,
    super.tooltip,
    super.animation,
    super.clip,
    super.backgroundColor,
    super.id,
    super.z,
  }) : super(coordType: CoordType.radar, parallelIndex: -1, gridIndex: -1, calendarIndex: -1, polarIndex: -1);

  @override
  ChartView? toView() {
    return RadarView(this);
  }
}
