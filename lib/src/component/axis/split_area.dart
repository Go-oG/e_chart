
import '../../style/area_style.dart';

class SplitArea {
  final bool show;
  final int interval;
  final AreaStyle style;

  const SplitArea({
    this.show = false,
    this.interval = -1,
    this.style = const AreaStyle(),
  });
}
