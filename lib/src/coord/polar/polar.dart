
import '../../component/tooltip/tool_tip.dart';
import '../circle_coord.dart';
import '../coord_layout.dart';
import 'axis_angle.dart';
import 'axis_radius.dart';
import 'polar_layout.dart';

///极坐标系
///一个极坐标系只能包含一个径向轴和一个角度轴
class Polar extends CircleCoordinate {
  final AngleAxis angleAxis;
  final RadiusAxis radiusAxis;
  final bool silent;
  final ToolTip? toolTip;

  const Polar({
    super.radius,
    super.center,
    this.radiusAxis = const RadiusAxis(),
    this.angleAxis = const AngleAxis(),
    this.toolTip,
    this.silent=true,
    super.id,
  });

  @override
  CoordinateLayout toLayout() {
   return PolarLayout(this);
  }
}
