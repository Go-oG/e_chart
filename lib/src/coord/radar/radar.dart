import 'package:e_chart/e_chart.dart';

///雷达图坐标系
class Radar extends CircleCoord {
  List<RadarIndicator> indicator;
  num offsetAngle;
  int splitNumber;
  bool silent;
  bool clockwise;
  RadarShape shape;

  ///雷达图将忽略掉label 和Tick
  AxisStyle axisStyle = AxisStyle();

  Fun2<RadarIndicator, LabelStyle>? labelStyleFun;
  Fun3<int, int, AreaStyle?>? splitAreaStyleFun;
  Fun3<int, int, LineStyle?>? splitLineStyleFun;

  Radar({
    required this.indicator,
    this.offsetAngle = 0,
    this.splitNumber = 5,
    AxisStyle? axisStyle,
    this.shape = RadarShape.polygon,
    this.silent = false,
    this.clockwise = true,
    this.splitAreaStyleFun,
    this.splitLineStyleFun,
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
  }) {
    if (axisStyle != null) {
      this.axisStyle = axisStyle;
    } else {
      var style = this.axisStyle;
      style.minorTick = null;
      style.axisTick.show = false;
      style.axisLabel.show = false;
    }
  }

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
