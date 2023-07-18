import '../../../model/dynamic_text.dart';
import '../../../model/text_position.dart';

class LabelResult {
  TextDrawConfig textConfig;
  DynamicText? text;
  List<LabelResult> minorLabel;

  LabelResult(this.textConfig, this.text, [this.minorLabel = const []]);
}
