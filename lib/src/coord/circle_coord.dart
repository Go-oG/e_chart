import 'dart:math';
import 'dart:ui';

import '../model/string_number.dart';
import 'coord.dart';
import 'coord_config.dart';

abstract class CircleCoord<T extends CircleCoordConfig> extends Coord<T> {
  CircleCoord(super.props);

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    double w = parentWidth;
    double h = parentHeight;
    double d = props.radius.last.convert(min(w, h));
    return Size(d, d);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    for (var child in children) {
      child.layout(0, 0, width, height);
    }
  }
}

abstract class CircleCoordConfig extends CoordConfig {
  List<SNumber> center;
  List<SNumber> radius;

  CircleCoordConfig({
    this.radius = const [SNumber.zero, SNumber.percent(40)],
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    super.enableClick,
    super.enableDrag,
    super.enableHover,
    super.enableScale,
    super.backgroundColor,
    super.id,
    super.show,
  });
}
