import 'base_tick.dart';

class MinorTick extends BaseTick {
  int splitNumber;

  MinorTick({
    this.splitNumber = 5,
    super.show,
    super.length,
    super.lineStyle,
    super.interval,
  });
}
