import 'package:e_chart/e_chart.dart';
import 'package:flutter/painting.dart';

///热力图
///可以在日历坐标系和笛卡尔坐标系中使用
class HeatMapSeries extends RectSeries {
  List<HeatMapData> data;
  Fun2<HeatMapData, LabelStyle>? labelFun;
  Fun2<HeatMapData, Alignment>? labelAlignFun;
  Fun2<HeatMapData, AreaStyle?>? areaStyleFun;
  Fun2<HeatMapData, LineStyle?>? borderStyleFun;

  HeatMapSeries(
    this.data, {
    this.labelFun,
    this.labelAlignFun,
    this.areaStyleFun,
    this.borderStyleFun,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.animation,
    super.coordSystem = CoordSystem.calendar,
    super.gridIndex,
    super.calendarIndex = 0,
    super.tooltip,
    super.enableClick,
    super.enableHover,
    super.enableDrag,
    super.enableScale,
    super.backgroundColor,
    super.id,
    super.clip,
    super.z,
  }) : super(polarIndex: -1, parallelIndex: -1, radarIndex: -1);
}

class HeatMapData extends ItemData {
  DynamicData x;
  DynamicData y;

  HeatMapData(this.x, this.y, num value, {super.id, super.label}) : super(value: value);
}
