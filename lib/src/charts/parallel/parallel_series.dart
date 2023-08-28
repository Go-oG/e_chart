import 'package:e_chart/e_chart.dart';

import 'parallel_view.dart';

class ParallelSeries extends ChartSeries {
  List<ParallelGroup> data;
  Fun4<ParallelGroup, int, Set<ViewState>, LineStyle>? styleFun;
  Fun4<ParallelGroup, int, Set<ViewState>, ChartSymbol?>? symbolFun;

  bool connectNull;

  ParallelSeries({
    required this.data,
    this.styleFun,
    this.symbolFun,
    this.connectNull = true,
    super.animation,
    super.parallelIndex,
    super.clip,
    super.tooltip,
    super.backgroundColor,
    super.id,
    super.z,
  }) : super(coordType: CoordType.parallel, gridIndex: -1, calendarIndex: -1, polarIndex: -1, radarIndex: -1);

  @override
  ChartView? toView() {
    return ParallelView(this);
  }
}

class ParallelGroup extends BaseGroupData<dynamic> {
  ParallelGroup(super.data, {super.id, super.label});
}
