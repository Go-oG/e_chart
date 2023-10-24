import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class TickResult extends Disposable {
  final int originIndex;
  final int index;
  final int maxIndex;
  final Offset start;
  final Offset end;

  List<TickResult> minorTickList;

  TickResult(this.originIndex, this.index, this.maxIndex, this.start, this.end, [this.minorTickList = const []]);

  @override
  void dispose() {
    each(minorTickList, (p0, p1) {
      p0.dispose();
    });
    minorTickList = [];
    super.dispose();
  }
}
