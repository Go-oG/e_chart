import 'package:e_chart/e_chart.dart';

class AngleAxisLayoutResult extends AxisPainter {
  final Arc arc;
  final List<ArcWrap> splitList;

  AngleAxisLayoutResult(this.arc, this.splitList, super.line, super.tick, super.label);

}
class ArcWrap{
  final dynamic data;
  final Arc arc;

  ArcWrap(this.data, this.arc);

}
