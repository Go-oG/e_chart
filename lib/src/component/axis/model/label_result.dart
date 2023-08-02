import '../../../model/data.dart';
import '../../../model/text_info.dart';

class LabelResult {
  final int originIndex;
  final int index;
  final int maxIndex;
  final TextDrawInfo textConfig;
  final DynamicText? text;
  final List<LabelResult> minorLabel;

  LabelResult(
    this.originIndex,
    this.index,
    this.maxIndex,
    this.textConfig,
    this.text, [
    this.minorLabel = const [],
  ]);
}
