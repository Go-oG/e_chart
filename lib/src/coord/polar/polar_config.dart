import 'package:e_chart/src/model/enums/coordinate.dart';

import '../../component/tooltip/tool_tip.dart';
import '../circle_coord.dart';
import 'axis_angle.dart';
import 'axis_radius.dart';

///极坐标系
///一个极坐标系只能包含一个径向轴和一个角度轴
class PolarConfig extends CircleCoordConfig {
  AngleAxis angleAxis = AngleAxis();
  RadiusAxis radiusAxis = RadiusAxis();
  bool silent;
  ToolTip? toolTip;

  PolarConfig({
    super.radius,
    super.center,
    RadiusAxis? radiusAxis,
    AngleAxis? angleAxis,
    this.toolTip,
    this.silent = true,
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
