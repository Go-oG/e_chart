import '../../functions.dart';
import '../../model/dynamic_data.dart';
import '../../model/enums/coordinate.dart';
import '../../style/area_style.dart';
import '../series.dart';

///热力图
class HeatMapSeries extends RectSeries {
  final List<HeatMapData> data;
  final StyleFun<HeatMapData, AreaStyle> styleFun;

  HeatMapSeries(
    this.data, {
    required this.styleFun,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.animation,
    super.coordSystem = CoordSystem.grid,
    super.xAxisIndex = 0,
    super.yAxisIndex = 0,
    super.calendarIndex = 0,
    super.clip,
    super.tooltip,
        super.enableClick,
        super.enableHover,
        super.enableDrag,
        super.enableScale,
    super.z,
  }) : super(polarAxisIndex: -1, parallelIndex: -1, radarIndex: -1);
}

class HeatMapData {
  final DynamicData x;
  final DynamicData y;
  final num value;

  HeatMapData(this.x, this.y, this.value);
}
