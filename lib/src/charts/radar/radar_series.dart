//雷达图
import '../../functions.dart';
import '../../model/enums/coordinate.dart';
import '../../model/group_data.dart';
import '../../style/area_style.dart';
import '../../style/label.dart';
import '../../style/symbol/symbol.dart';
import '../../core/series.dart';

class RadarSeries extends RectSeries {
  List<GroupData> data;
  int splitNumber;
  Fun2<GroupData, AreaStyle> areaStyleFun;
  Fun2<GroupData, LabelStyle>? labelStyleFun;
  Fun4<ItemData, int, GroupData, ChartSymbol?>? symbolFun;
  num nameGap;

  RadarSeries(
    this.data, {
    required this.splitNumber,
    required this.areaStyleFun,
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
    super.enableClick,
    super.enableHover,
    super.enableDrag,
    super.enableScale,
    super.clip,
    super.backgroundColor,
    super.id,
    super.z,
  }) : super(
          coordSystem: CoordSystem.radar,
          parallelIndex: -1,
          xAxisIndex: -1,
          yAxisIndex: -1,
          calendarIndex: -1,
          polarAxisIndex: -1,
        );
}
