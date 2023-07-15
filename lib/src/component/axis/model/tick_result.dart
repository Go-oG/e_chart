import 'dart:ui';

import '../../../model/index.dart';

class TickResult {
  final Offset start;
  final Offset end;

  final List<TickResult> minorTickList;

  TickResult(this.start, this.end, [this.minorTickList = const []]);
}
