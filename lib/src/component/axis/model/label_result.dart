import '../../../model/dynamic_text.dart';
import '../../../model/text_position.dart';

class LabelResult {
  final int originIndex;
  final int index;
  final int maxIndex;
  final TextDrawConfig textConfig;
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
