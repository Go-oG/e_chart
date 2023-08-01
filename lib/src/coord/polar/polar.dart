import 'package:e_chart/src/component/axis/radius/radius_axis.dart';
import 'package:e_chart/src/model/enums/coordinate.dart';

import '../../component/tooltip/tool_tip.dart';
import '../circle_coord.dart';
import '../../component/axis/angle/angle_axis.dart';

///极坐标系
///一个极坐标系只能包含一个径向轴和一个角度轴
class Polar extends CircleCoord {
  AngleAxis angleAxis = AngleAxis();
  RadiusAxis radiusAxis = RadiusAxis();
  bool silent;
  ToolTip? toolTip;

  Polar({
    super.radius,
    super.center,
    RadiusAxis? radiusAxis,
    AngleAxis? angleAxis,
    this.toolTip,
    this.silent = true,
    super.enableClick,
    super.enableDrag,
    super.enableHover,
    super.enableScale,
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
  CoordSystem get coordSystem => CoordSystem.polar;
}
