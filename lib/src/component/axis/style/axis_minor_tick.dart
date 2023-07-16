import 'package:e_chart/e_chart.dart';

class AxisMinorTick{
  bool show;
  MinorTick? tick;
  Fun3<int, int, MinorTick>? tickFun;

  AxisMinorTick({
    this.show=false,
    MinorTick? tick,
    this.tickFun,
  }) {
    if (tick != null) {
      this.tick = tick;
    }
  }

  MinorTick? getTick(int index, int maxIndex, AxisTheme theme) {
    if (!show) {
      return null;
    }
    MinorTick? tick;
    if (tickFun != null) {
      tick = tickFun?.call(index, maxIndex);
    } else {
      if (this.tick != null) {
        tick = this.tick;
      } else {
        tick = theme.getMinorTick();
      }
    }
    return tick;
  }


}