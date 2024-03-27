import 'dart:math';

import 'package:e_chart/e_chart.dart';

class AxisTick extends ChartNotifier2 {
  bool show;
  bool inside;
  MainTick? tick;
  MinorTick? minorTick;

  AxisTick({
    this.show = true,
    this.inside = true,
    MainTick? tick,
    this.minorTick,
  }) {
    if (tick != null) {
      this.tick = tick;
    } else {
      this.tick = MainTick();
    }
  }

  AxisTick.of({
    this.show = true,
    this.inside = true,
    this.tick,
    this.minorTick,
  });

  double getMaxTickSize() {
    return max(getTickSize(), getMinorSize());
  }

  double getTickSize() {
    if (!show) {
      return 0;
    }
    var tick = this.tick;
    if (tick == null || !tick.show) {
      return 0;
    }
    return tick.length.toDouble();
  }

  double getMinorSize() {
    if (!show) {
      return 0;
    }
    var tick = minorTick;
    if (tick == null || !tick.show) {
      return 0;
    }
    return tick.length.toDouble();
  }
}
