
import 'dart:ui';

import 'index.dart';

class TickResult {
  final Offset start;
  final Offset end;
  final TextDrawConfig? textConfig;
  final DynamicText? text;

  TickResult(this.start, this.end, this.textConfig, this.text);
}