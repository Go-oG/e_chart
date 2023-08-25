

import 'package:e_chart/e_chart.dart';

import 'parallel_view.dart';

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
    super.backgroundColor,
    super.id,
    super.z,
  }) : super(
    coordType: CoordType.parallel,
          gridIndex: -1,
          calendarIndex: -1,
          polarIndex: -1,
          radarIndex: -1,
        );

  @override
  ChartView? toView() {
    return ParallelView(this);
  }
}

class ParallelGroup {
  final List<dynamic> data;
  final String id;

  ParallelGroup(this.id, this.data);
}
