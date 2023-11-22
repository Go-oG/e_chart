import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class TickPainter extends Disposable {
  final dynamic data;
  final int index;
  final int maxIndex;
  final Offset start;
  final Offset end;

  List<TickPainter> minorList;

  TickPainter(this.data, this.index, this.maxIndex, this.start, this.end, [this.minorList = const []]);

  @override
  void dispose() {
    super.dispose();
    each(minorList, (p0, p1) {
      p0.dispose();
    });
    minorList = [];
  }
}
