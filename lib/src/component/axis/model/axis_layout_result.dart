import 'label_result.dart';
import 'line_result.dart';
import 'tick_result.dart';

class AxisLayoutResult {
  final List<LineResult> line;
  final List<LabelResult> label;
  final List<TickResult> tick;

  AxisLayoutResult(this.line, this.tick, this.label);
}
