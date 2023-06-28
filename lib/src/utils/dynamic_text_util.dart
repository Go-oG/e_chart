import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/rendering.dart';

extension DStringExt on String {
  DynamicText toText() {
    return DynamicText(this);
  }
}

extension DTextSpanExt on TextSpan {
  DynamicText toText() {
    return DynamicText(this);
  }
}

extension DParagraphExt on Paragraph {
  DynamicText toText() {
    return DynamicText(this);
  }
}

