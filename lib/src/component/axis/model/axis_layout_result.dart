import 'package:e_chart/e_chart.dart';

class AxisLayoutResult extends Disposable {
   List<LineResult> line;
   List<LabelResult> label;
   List<TickResult> tick;

  AxisLayoutResult(this.line, this.tick, this.label);

  @override
  void dispose() {
    each(line, (p0, p1) {
      p0.dispose();
    });
    each(label, (p0, p1) {
      p0.dispose();
    });
    each(tick, (p0, p1) {
      p0.dispose();
    });
    line=[];
    label=[];
    tick=[];
    super.dispose();
  }
}
