import 'package:e_chart/e_chart.dart';

class LabelResult {
  final int originIndex;
  final int index;
  final int maxIndex;
  final TextDraw textConfig;
  final List<LabelResult> minorLabel;

  LabelResult(
    this.originIndex,
    this.index,
    this.maxIndex,
    this.textConfig,[
    this.minorLabel = const [],
  ]);
}
