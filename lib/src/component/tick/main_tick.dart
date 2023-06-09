import 'base_tick.dart';
import 'minor_tick.dart';

class MainTick extends BaseTick {
  MinorTick? minorTick;

  MainTick({
    this.minorTick,
    super.show,
    super.inside,
    super.length,
    super.lineStyle,
    super.labelStyle,
    super.labelPadding,
    super.interval,
    super.tickOffset,
  });
}
