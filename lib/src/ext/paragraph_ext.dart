import 'dart:ui';

import '../model/data.dart';

extension DParagraphExt on Paragraph {
  DynamicText toText() {
    return DynamicText(this);
  }
}