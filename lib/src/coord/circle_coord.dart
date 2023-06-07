import 'dart:math';
import 'dart:ui';

import '../model/string_number.dart';
import 'coord.dart';
import 'coord_config.dart';


abstract class CircleCoord<T extends CircleCoordConfig> extends Coord {
  final T props;

  CircleCoord(this.props);

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    double w = parentWidth;
    double h = parentHeight;
    double d = props.radius.convert(min(w, h));
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
  final List<SNumber> center;
  final SNumber radius;

  const CircleCoordConfig(
      {this.radius = const SNumber.percent(50), this.center = const [SNumber.percent(50), SNumber.percent(50)], super.id, super.show});
}
