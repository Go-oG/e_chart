import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/cupertino.dart';

void main() {
  var arc = Arc(innerRadius: 68.9, outRadius: 103.9, startAngle: 0, sweepAngle: 214.8, center: Offset.zero);
  print(arc.contains(Offset(-74, 42)));
}
