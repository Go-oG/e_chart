import 'package:flutter/material.dart';

import '../core/view_state.dart';

extension TextStyleExtension on TextStyle {
  TextPainter toPainter(String text,
      {TextAlign textAlign = TextAlign.center,
      TextDirection textDirection = TextDirection.ltr,
      int? maxLines,
      String? ellipsis,
      double textScaleFactor = 1,
      TextWidthBasis textWidthBasis = TextWidthBasis.longestLine,
      Set<ViewState>? states}) {
    return TextPainter(
      text: TextSpan(text: text, style: this),
      textAlign: textAlign,
      textDirection: textDirection,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      ellipsis: ellipsis,
      textWidthBasis: textWidthBasis,
    );
  }
}
