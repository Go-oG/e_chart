import '../../functions.dart';
import '../../model/enums/align2.dart';
import '../../model/enums/direction.dart';
import '../../model/enums/sort.dart';
import '../../style/area_style.dart';
import '../../style/label.dart';
import '../../style/line_style.dart';
import '../series.dart';

enum FunnelAlign {
  left,
  right,
  top,
  bottom,
  center,
  insideLeft,
  insideTop,
  insideRight,
  insideBottom,
  leftTop,
  leftBottom,
  rightTop,
  rightBottom,
}

class FunnelSeries extends RectSeries {
  List<FunnelData> dataList;
  double? maxValue;
  FunnelAlign labelAlign;
  Direction direction;
  Sort sort;
  double gap;
  Align2 align;
  StyleFun<FunnelData, AreaStyle> areaStyleFun;
  StyleFun<FunnelData, LabelStyle>? labelStyleFun;
  StyleFun<FunnelData, LineStyle>? labelLineStyleFun;

  FunnelSeries(
    this.dataList, {
    this.labelAlign = FunnelAlign.center,
    this.maxValue,
    this.direction = Direction.vertical,
    this.sort = Sort.empty,
    this.gap = 2,
    this.align = Align2.center,
    this.labelStyleFun,
    this.labelLineStyleFun,
    required this.areaStyleFun,
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
    super.clip,
    super.tooltip,
    super.z,
  }) : super(
          coordSystem: null,
          calendarIndex: -1,
          parallelIndex: -1,
          polarAxisIndex: -1,
          radarIndex: -1,
          xAxisIndex: -1,
          yAxisIndex: -1,
        );
}

class FunnelData {
  final double data;
  final String? labelText;

  const FunnelData(
    this.data, [
    this.labelText,
  ]);
}
