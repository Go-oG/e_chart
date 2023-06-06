//雷达图
import 'package:uuid/uuid.dart';

import '../../functions.dart';
import '../../model/enums/coordinate.dart';
import '../../style/area_style.dart';
import '../../style/label.dart';
import '../../style/symbol/symbol.dart';
import '../series.dart';

class RadarSeries extends RectSeries {
  final List<RadarGroup> data;
  final int splitNumber;
  final StyleFun<RadarGroup, AreaStyle> areaStyleFun;
  final StyleFun<RadarGroup, LabelStyle>? labelStyleFun;
  final Fun3<RadarData, int, RadarGroup, ChartSymbol?>? symbolFun;
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

class RadarGroup {
  late final String id;
  final List<RadarData> dataList;

  RadarGroup(this.dataList, {String? id}) {
    this.id = id ?? (Uuid().v4().toString().replaceAll('-', ''));
  }
}

class RadarData {
  final num value;
  final String? label;

  RadarData(this.value, {this.label});
}
