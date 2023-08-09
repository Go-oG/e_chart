import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/coord/index.dart';

///雷达图坐标系
class Radar extends CircleCoord {
  List<RadarIndicator> indicator;
  num offsetAngle;
  int splitNumber;
  bool silent;
  bool clockwise;
  RadarShape shape;

  ///雷达图将忽略掉label 和Tick
  AxisName? axisName;
  AxisLine axisLine = AxisLine();
  SplitLine splitLine = SplitLine();
  MinorSplitLine? minorSplitLine;
  SplitArea? splitArea;

  ///坐标轴指示器
  AxisPointer? axisPointer;

  Fun2<RadarIndicator, LabelStyle>? labelStyleFun;
  Fun3<int, int, AreaStyle?>? splitAreaStyleFun;
  Fun3<int, int, LineStyle?>? splitLineStyleFun;

  Radar({
    required this.indicator,
    this.offsetAngle = 0,
    this.splitNumber = 5,
    this.shape = RadarShape.polygon,
    this.silent = false,
    this.clockwise = true,
    this.splitAreaStyleFun,
    this.splitLineStyleFun,
    this.labelStyleFun,
    super.center,
    super.radius,
    super.toolTip,
    super.layoutParams,
    super.backgroundColor,
    super.id,
    super.show,
    this.axisName,
    AxisLine? axisLine,
    SplitLine? splitLine,
    this.minorSplitLine,
    this.splitArea,
    this.axisPointer,
  }) {
    if (axisLine != null) {
      this.axisLine = axisLine;
    }
    if (splitLine != null) {
      this.splitLine = splitLine;
    }
  }

  @override
  CoordSystem get coordSystem => CoordSystem.radar;

  @override
  CoordLayout<Coord>? toCoord() {
    return RadarCoordImpl(this);
  }
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
