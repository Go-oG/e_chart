import 'dart:math';

import 'package:flutter/material.dart';

Color fromHSL(num h, double s, double l) {
  return HSLColor.fromAHSL(1, h.toDouble(), s, l.toDouble()).toColor();
}

Random _random = Random();
Color randomColor() {
  int r = _random.nextInt(145) + 50;
  int g = _random.nextInt(135) + 50;
  int b = _random.nextInt(125) + 50;

  return Color.fromARGB(255, r, g, b);
}
