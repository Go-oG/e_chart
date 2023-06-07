import 'package:flutter/material.dart';

Color fromHSL(num h, double s, double l) {
  return HSLColor.fromAHSL(1, h.toDouble(), s, l.toDouble()).toColor();
  // if (h < 0 || h > 360) {
  //   throw FlutterError('h must >=0 && <=360');
  // }
  // if (s < 0 || s > 1) {
  //   throw FlutterError('s must >=0 && <=1');
  // }
  // if (l < 0 || l > 1) {
  //   throw FlutterError('l must >=0 && <=1');
  // }
  // if (s == 0) {
  //   int li = (l * 255).ceil();
  //   if (li > 255) {
  //     li = 255;
  //   }
  //   return Color.fromARGB(255, li, li, li);
  // }
  // double q;
  // if (l < 0.5) {
  //   q = l * (1 + s);
  // } else {
  //   q = l + s - (l * s);
  // }
  // double p = 2 * l - q;
  // double hk = h / 360;
  // double r = hk + 0.33333333;
  // double g = hk;
  // double b = hk - 0.33333333;
  // return Color.fromARGB(
  //   255,
  //   (_convert(p, q, r) * 255).ceil(),
  //   (_convert(p, q, g) * 255).ceil(),
  //   (_convert(p, q, b) * 255).ceil(),
  // );
}
