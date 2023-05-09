
import 'base_tick.dart';

class MinorTick extends BaseTick {
  final int splitNumber;
  const MinorTick({
    this.splitNumber=5,
    super.show,
    super.inside,
    super.length,
    super.lineStyle,
    super.labelStyle,
    super.labelPadding,
    super.interval,
  });
}
