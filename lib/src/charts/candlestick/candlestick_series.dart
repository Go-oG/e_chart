import '../../functions.dart';
import '../../model/dynamic_text.dart';
import '../../model/enums/coordinate.dart';
import '../../style/area_style.dart';
import '../../style/line_style.dart';
import '../../core/series.dart';

class CandleStickSeries extends RectSeries {
  List<CandleStickData> data;
  String name;
  bool hoverAnimation;
  Fun2<CandleStickData, AreaStyle> styleFun;
  Fun2<CandleStickData, LineStyle> lineStyleFun;

  CandleStickSeries(
    this.data, {
    super.xAxisIndex = 0,
    super.yAxisIndex = 0,
    this.name = '',
    this.hoverAnimation = true,
    required this.styleFun,
    required this.lineStyleFun,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.animation,
    super.tooltip,
    super.backgroundColor,
    super.id,
    super.enableClick,
    super.enableHover,
    super.enableDrag,
    super.enableScale,
    super.clip,
    super.z,
  }) : super(
          coordSystem: CoordSystem.grid,
          parallelIndex: -1,
          polarAxisIndex: -1,
          radarIndex: -1,
          calendarIndex: -1,
        );
}

class CandleStickData {
  DateTime time;
  double highest;
  double lowest;
  double open;
  double close;
  DynamicText? label;

  CandleStickData({
    required this.time,
    required this.open,
    required this.close,
    required this.lowest,
    required this.highest,
    this.label,
  });
}
