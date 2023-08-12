import 'package:e_chart/e_chart.dart';

class AngleAxisLayoutResult extends AxisLayoutResult {
  final Arc arc;
  final List<Arc> splitList;

  AngleAxisLayoutResult(this.arc, this.splitList, super.line, super.tick, super.label);
}
