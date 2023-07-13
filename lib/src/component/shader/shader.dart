import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/view_state.dart';

abstract class ChartShader {
  ChartShader();

  ui.Shader toShader(Rect rect);

  ChartShader convert(covariant ChartShader begin, covariant ChartShader end, double animatorPercent);

  ChartShader convert2(Set<ViewState>? states);
}
