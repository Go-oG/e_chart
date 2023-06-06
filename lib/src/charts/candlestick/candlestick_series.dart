import '../../functions.dart';
import '../../model/enums/coordinate.dart';
import '../../style/area_style.dart';
import '../../style/line_style.dart';
import '../series.dart';

class CandleStickSeries extends RectSeries {
  final List<CandleStickData> data;
  final String name;
  final bool hoverAnimation;
  final StyleFun<CandleStickData, AreaStyle> styleFun;
  final StyleFun<CandleStickData, LineStyle> lineStyleFun;

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
  final DateTime time;

  final double highest;
  final double lowest;
  final double open;
  final double close;

  CandleStickData({
    required this.time,
    required this.open,
    required this.close,
    required this.lowest,
    required this.highest,
  });
}
