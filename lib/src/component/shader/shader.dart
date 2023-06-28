import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/view_state.dart';

abstract class Shader {
   Shader();

  ui.Shader toShader(Rect rect);

  Shader convert(covariant Shader begin, covariant Shader end, double animatorPercent);

  Shader convert2(Set<ViewState>? states);

}
