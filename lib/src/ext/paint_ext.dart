import 'package:flutter/material.dart';

extension PaintExtension on Paint {
  void reset() {
    colorFilter = null;
    blendMode = BlendMode.srcOver;
    color = Colors.white;
    colorFilter = null;
    filterQuality = FilterQuality.none;
    imageFilter = null;
    invertColors = false;
    maskFilter = null;
    shader = null;
    strokeCap = StrokeCap.butt;
    strokeJoin = StrokeJoin.miter;
    strokeMiterLimit = 4.0;
    strokeWidth = 1;
    style = PaintingStyle.stroke;
    isAntiAlias = true;
  }
}
