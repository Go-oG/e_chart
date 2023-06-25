import 'package:e_chart/src/model/enums/coordinate.dart';

import '../../component/axis/axis_line.dart';
import '../../component/tick/main_tick.dart';
import '../../functions.dart';
import '../../model/dynamic_text.dart';
import '../../style/area_style.dart';
import '../../style/label.dart';
import '../../style/line_style.dart';
import '../circle_coord.dart';

//雷达坐标系
class RadarConfig extends CircleCoordConfig {
  final List<RadarIndicator> indicator;
  final num offsetAngle;
  final int splitNumber;
  final bool silent;
  final bool clockwise;
  final RadarShape shape;
  final AxisLine axisLine;
  final MainTick axisTick;

  final Fun2<RadarIndicator, LabelStyle>? labelStyleFun;
  final Fun3<int, int, AreaStyle>? splitStyleFun;
  final Fun2<int, LineStyle>? borderStyleFun;

  const RadarConfig({
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
  });

  @override
  CoordSystem get coordSystem => CoordSystem.radar;

}

/// 雷达图样式
enum RadarShape { circle, polygon }

enum RadarAnimatorStyle { scale, rotate, scaleAndRotate }

class RadarIndicator {
  final DynamicText name;
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
