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
  List<RadarIndicator> indicator;
  num offsetAngle;
  int splitNumber;
  bool silent;
  bool clockwise;
  RadarShape shape;
  AxisLine? axisLine;
  MainTick? axisTick;

  Fun2<RadarIndicator, LabelStyle>? labelStyleFun;
  Fun3<int, int, AreaStyle>? splitStyleFun;
  Fun2<int, LineStyle>? borderStyleFun;

  RadarConfig({
    required this.indicator,
    this.offsetAngle = 0,
    this.splitNumber = 5,
    this.axisLine,
    this.axisTick,
    this.shape = RadarShape.polygon,
    this.silent = false,
    this.clockwise = true,
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
