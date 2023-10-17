import 'package:e_chart/e_chart.dart';

class AxisTick extends ChartNotifier2 {
  bool show;
  MainTick? tick;
  Fun3<int, int, MainTick?>? tickFun;

  AxisTick({
    this.show = true,
    MainTick? tick,
    this.tickFun,
  }) {
    if (tick != null) {
      this.tick = tick;
    }
  }

  MainTick? getTick(int index, int maxIndex, AxisTheme theme) {
    if (!show) {
      return null;
    }
    MainTick? tick;
    if (tickFun != null) {
      tick = tickFun?.call(index, maxIndex);
    } else {
      if (this.tick != null) {
        tick = this.tick;
      } else {
        tick = theme.getMainTick();
      }
    }
    return tick;
  }

  MainTick? getTickNotFun(AxisTheme theme) {
    if (!show || tickFun == null) {
      return null;
    }

    MainTick? tick;
    if (this.tick != null) {
      tick = this.tick;
    } else {
      tick = theme.getMainTick();
    }
    return tick;
  }
}
