import 'dart:ui';

import 'index.dart';

class TickResult {
  Offset start;
  Offset end;
  TextDrawConfig? textConfig;
  DynamicText? text;
  List<TickResult> minorTickList = [];

  TickResult(this.start, this.end, this.textConfig, this.text);
}
