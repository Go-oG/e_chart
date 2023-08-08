import 'dart:ui';

import '../../../model/index.dart';

class TickResult {
  final int originIndex;
  final int index;
  final int maxIndex;
  final Offset start;
  final Offset end;

  final List<TickResult> minorTickList;

  TickResult(this.originIndex,this.index,this.maxIndex,this.start, this.end, [this.minorTickList = const []]);
}
