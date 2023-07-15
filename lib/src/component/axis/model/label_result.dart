import '../../../model/dynamic_text.dart';
import '../../../model/text_position.dart';

class LabelResult {
  final TextDrawConfig textConfig;
  final DynamicText? text;
  final List<LabelResult> minorLabel;

  LabelResult(this.textConfig, this.text, [this.minorLabel = const []]);
}
