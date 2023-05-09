import 'dart:ui' as ui;

import 'package:flutter/material.dart';

abstract class Shader {
  const Shader();

  ui.Shader toShader(Rect rect, double? colorOpacity);

  Shader convert(covariant Shader begin, covariant Shader end, double animatorPercent);

}
