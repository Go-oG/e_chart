import '../../functions.dart';
import '../../model/dynamic_data.dart';
import '../../model/enums/coordinate.dart';
import '../../style/line_style.dart';
import '../../core/series.dart';

class ParallelSeries extends RectSeries {
  List<ParallelGroup> data;
  Fun2<ParallelGroup, LineStyle> styleFun;

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
    super.backgroundColor,
    super.id,
    super.z,
  }) : super(
          coordSystem: CoordSystem.parallel,
          gridIndex: -1,
          calendarIndex: -1,
          polarIndex: -1,
          radarIndex: -1,
        );
}

class ParallelGroup {
  final List<DynamicData> data;
  final String id;

  ParallelGroup(this.id, this.data);
}
