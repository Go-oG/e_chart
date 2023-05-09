import 'dart:math';
import 'dart:ui';


import 'circle_coord.dart';
import 'coord_layout.dart';

abstract class CircleCoordLayout<T extends CircleCoordinate> extends CoordinateLayout {
  final T props;

  CircleCoordLayout(this.props);

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    double w=parentWidth;
    double h=parentHeight;
    double d=props.radius.convert(min(w, h));
    return Size(d,d);

  }
}
