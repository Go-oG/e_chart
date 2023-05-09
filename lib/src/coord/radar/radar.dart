import '../../component/axis/axis_line.dart';
import '../../component/tick/main_tick.dart';
import '../../functions.dart';
import '../../style/area_style.dart';
import '../../style/label.dart';
import '../../style/line_style.dart';
import '../circle_coord.dart';
import '../coord_layout.dart';
import 'radar_layout.dart';

//雷达坐标系
class Radar extends CircleCoordinate {
  final List<RadarIndicator> indicator;
  final num offsetAngle;
  final int splitNumber;
  final bool silent;
  final bool clockwise;
  final RadarShape shape;
  final AxisLine axisLine;
  final MainTick axisTick;

  final StyleFun<RadarIndicator, LabelStyle>? labelStyleFun;
  final StyleFun2<int, int, AreaStyle>? splitStyleFun;
  final StyleFun<int, LineStyle>? borderStyleFun;

  const Radar({
    required this.indicator,
    this.offsetAngle = 0,
    this.splitNumber = 5,
    this.shape = RadarShape.polygon,
    this.silent = false,
    this.clockwise = true,
    this.axisLine = const AxisLine(),
    this.axisTick = const MainTick(),
    this.splitStyleFun,
    this.borderStyleFun,
    this.labelStyleFun,
    super.center,
    super.radius,
    super.id,
    super.show,
  });

  @override
  CoordinateLayout toLayout() {
    return RadarLayout(this);
  }
}

/// 雷达图样式
enum RadarShape { circle, polygon }

enum RadarAnimatorStyle { scale, rotate, scaleAndRotate }

class RadarIndicator {
  final String name;
  final double? max;
  final double min;
  final num nameGap;
  final LabelStyle nameStyle;

  final LineStyle lineStyle;

  RadarIndicator(
    this.name, {
    this.max,
    this.min = 0,
    this.nameGap = 3,
    this.nameStyle = const LabelStyle(),
    this.lineStyle = const LineStyle(),
  });
}
