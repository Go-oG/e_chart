import '../../../shape/arc.dart';
import '../model/axis_layout_result.dart';

class AngleAxisLayoutResult extends AxisLayoutResult {
  final Arc arc;
  final List<Arc> splitList;

  AngleAxisLayoutResult(this.arc, this.splitList, super.tick, super.label);


}
