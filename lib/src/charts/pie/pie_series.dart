import 'package:e_chart/e_chart.dart';

enum RoseType {
  normal,
  radius, //圆心角展现数据百分比，半径展示数据大小
  area // 圆心角相同 半径展示数据的大小
}

enum PieAnimatorStyle {
  expand,
  expandScale,
  originExpand,
  originExpandScale,
}

/// 饼图系列
class PieSeries extends RectSeries {
  List<ItemData> data;
  List<SNumber> center;

  //内圆半径(<=0时为圆)
  SNumber innerRadius;

  //外圆最大半径(<=0时为圆)
  SNumber outerRadius;

  ///饼图扫过的角度(范围为(0,360]默认为360)
  num sweepAngle;

  //偏移角度默认为0
  double offsetAngle;

  //拐角半径 默认为0
  double corner;

  //角度间距(默认为0)
  double angleGap;

  //是否为顺时针
  bool clockWise;

  //动画缩放扩大系数
  SNumber scaleExtend;

  //布局类型
  RoseType roseType;
  CircleAlign labelAlign;
  PieAnimatorStyle animatorStyle;
  Fun2<ItemData, LabelStyle?>? labelStyleFun;
  Fun2<ItemData, AreaStyle> areaStyleFun;

  PieSeries(
    this.data, {
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    this.innerRadius = const SNumber.percent(15),
    this.outerRadius = const SNumber.percent(90),
    this.scaleExtend = const SNumber.number(16),
    this.sweepAngle = 360,
    this.offsetAngle = 0,
    this.corner = 0,
    this.roseType = RoseType.radius,
    this.angleGap = 0,
    this.labelStyleFun,
    this.clockWise = true,
    this.labelAlign = CircleAlign.inside,
    this.animatorStyle = PieAnimatorStyle.expandScale,
    required this.areaStyleFun,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.coordSystem,
    super.calendarIndex,
    super.tooltip,
    super.animation,
    super.enableClick,
    super.enableHover,
    super.enableDrag,
    super.enableScale = false,
    super.clip,
    super.backgroundColor,
    super.id,
    super.z,
  }) : super(
          xAxisIndex: -1,
          yAxisIndex: -1,
          parallelIndex: -1,
          radarIndex: -1,
          polarAxisIndex: -1,
        );

  @override
  void dispose() {
    logPrint('Pie Dispose');
    super.dispose();
  }
}
