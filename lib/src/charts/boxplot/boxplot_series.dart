
//盒须图
import '../../functions.dart';
import '../../model/dynamic_data.dart';
import '../../model/enums/coordinate.dart';
import '../../style/line_style.dart';
import '../series.dart';

class BoxplotSeries extends RectSeries {
  final List<BoxplotData> data;
  final StyleFun<BoxplotData, LineStyle> lineStyleFun;

  BoxplotSeries({
    required this.data,
    required this.lineStyleFun,
    super.animation,
    super.bottomMargin,
    super.leftMargin,
    super.polarAxisIndex,
    super.rightMargin,
    super.topMargin,
    super.height,
    super.width,
    super.xAxisIndex,
    super.yAxisIndex,
    super.tooltip,
    super.enableClick,
    super.enableHover,
    super.enableDrag,
    super.enableScale,
    super.z,
    super.clip,
  }) : super(
          coordSystem: CoordSystem.grid,
          calendarIndex: -1,
          parallelIndex: -1,
          radarIndex: -1,
        );
}

class BoxplotData {
  final DynamicData x;
  final DynamicData max;
  final DynamicData upAve4;
  final DynamicData middle;
  final DynamicData downAve4;
  final DynamicData min;

  BoxplotData({
    required this.x,
    required this.max,
    required this.upAve4,
    required this.middle,
    required this.downAve4,
    required this.min,
  });
}
