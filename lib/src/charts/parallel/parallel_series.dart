import '../../functions.dart';
import '../../model/dynamic_data.dart';
import '../../model/enums/coordinate.dart';
import '../../style/line_style.dart';
import '../series.dart';

class ParallelSeries extends RectSeries {
  List<ParallelGroup> data;
  StyleFun<ParallelGroup, LineStyle> styleFun;

  ParallelSeries({
    required this.data,
    required this.styleFun,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.animation,
    super.parallelIndex,
    super.clip,
    super.tooltip,
    super.enableClick,
    super.enableHover,
    super.enableDrag,
    super.enableScale,
    super.z,
  }) : super(
          coordSystem: CoordSystem.parallel,
          xAxisIndex: -1,
          yAxisIndex: -1,
          calendarIndex: -1,
          polarAxisIndex: -1,
          radarIndex: -1,
        );
}

class ParallelGroup {
  final List<DynamicData> data;
  final String id;

  ParallelGroup(this.id, this.data);
}
