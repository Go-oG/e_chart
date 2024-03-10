
import 'package:e_chart/src/coord/index.dart';
import 'package:e_chart/src/model/enums/coordinate.dart';

import '../../component/index.dart';


///极坐标系
///一个极坐标系只能包含一个径向轴和一个角度轴
class Polar extends CircleCoord {
  AngleAxis angleAxis = AngleAxis();
  RadiusAxis radiusAxis = RadiusAxis();
  bool silent;

  Polar({
    super.radius,
    super.center,
    RadiusAxis? radiusAxis,
    AngleAxis? angleAxis,
    this.silent = true,
    super.toolTip,
    super.layoutParams,
    super.backgroundColor,
    super.id,
    super.show,
  }) {
    if (radiusAxis != null) {
      this.radiusAxis = radiusAxis;
    }
    if (angleAxis != null) {
      this.angleAxis = angleAxis;
    }
  }

  @override
  CoordType get coordSystem => CoordType.polar;

  @override
  CoordLayout<Coord>? toCoord() {
    return PolarCoordImpl(this);
  }
}
