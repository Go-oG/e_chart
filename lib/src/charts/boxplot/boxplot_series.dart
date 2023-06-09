//盒须图
import '../../functions.dart';
import '../../model/dynamic_data.dart';
import '../../model/dynamic_text.dart';
import '../../model/enums/coordinate.dart';
import '../../style/line_style.dart';
import '../series.dart';

class BoxplotSeries extends RectSeries {
  List<BoxplotData> data;
  StyleFun<BoxplotData, LineStyle> lineStyleFun;

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
  DynamicData x;
  DynamicData max;
  DynamicData upAve4;
  DynamicData middle;
  DynamicData downAve4;
  DynamicData min;
  DynamicText? label;

  BoxplotData({
    required this.x,
    required this.max,
    required this.upAve4,
    required this.middle,
    required this.downAve4,
    required this.min,
    this.label,
  });
}
