import 'package:e_chart/e_chart.dart';

//雷达坐标系
class RadarConfig extends CircleCoordConfig {
  List<RadarIndicator> indicator;
  num offsetAngle;
  int splitNumber;
  bool silent;
  bool clockwise;
  RadarShape shape;
  AxisStyle? axisLine;
  MainTick? axisTick;

  Fun2<RadarIndicator, LabelStyle>? labelStyleFun;
  Fun3<int, int, AreaStyle>? splitStyleFun;

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
    this.labelStyleFun,
    super.center,
    super.radius,
    super.enableClick,
    super.enableDrag,
    super.enableHover,
    super.enableScale,
    super.backgroundColor,
    super.id,
    super.show,
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
