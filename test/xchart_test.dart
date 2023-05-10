import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/cupertino.dart';

void main() {
  Offset center = Offset.zero;
  num startAngle = 90;
  num sweepAngle = -180;

  Offset x = Offset(1, 0);

  debugPrint('${x.inSector(0, 2, startAngle, sweepAngle, center: center)}');

}
