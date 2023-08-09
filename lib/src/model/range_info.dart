import 'package:e_chart/e_chart.dart';

class RangeInfo {
  final DynamicData start;
  final DynamicData end;
  final int startIndex;
  final int endIndex;

  RangeInfo(this.start, this.end, this.startIndex, this.endIndex);

  @override
  String toString() {
    return "start:$start end:$end si:$startIndex ei:$endIndex";
  }
}
