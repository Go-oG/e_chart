import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

void main() {
  var uuid=Uuid();
  debugPrint('${uuid.v4()} ${uuid.v4()}');
}
