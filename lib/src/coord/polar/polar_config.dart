
import 'package:e_chart/src/model/enums/coordinate.dart';

import '../../component/tooltip/tool_tip.dart';
import '../circle_coord.dart';
import 'axis_angle.dart';
import 'axis_radius.dart';

///极坐标系
///一个极坐标系只能包含一个径向轴和一个角度轴
class PolarConfig extends CircleCoordConfig {
  final AngleAxis angleAxis;
  final RadiusAxis radiusAxis;
  final bool silent;
  final ToolTip? toolTip;

  const PolarConfig({
    super.radius,
    super.center,
    this.radiusAxis = const RadiusAxis(),
    this.angleAxis = const AngleAxis(),
    this.toolTip,
    this.silent=true,
    super.id,
    super.show
  });

  @override
  CoordSystem get coordSystem => CoordSystem.polar;
}
