//雷达图
import '../../functions.dart';
import '../../model/enums/coordinate.dart';
import '../../model/group_data.dart';
import '../../style/area_style.dart';
import '../../style/label.dart';
import '../../style/symbol/symbol.dart';
import '../series.dart';

class RadarSeries extends RectSeries {
  final List<GroupData> data;
  final int splitNumber;
  final StyleFun<GroupData, AreaStyle> areaStyleFun;
  final StyleFun<GroupData, LabelStyle>? labelStyleFun;
  final Fun3<ItemData, int, GroupData, ChartSymbol?>? symbolFun;
  final num nameGap;

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


