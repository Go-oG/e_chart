import '../../functions.dart';
import '../../model/enums/circle_align.dart';
import '../../model/group_data.dart';
import '../../model/string_number.dart';
import '../../style/area_style.dart';
import '../../style/label.dart';
import '../series.dart';

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
  SNumber innerRadius; //内圆半径(<=0时为圆)
  SNumber outerRadius; //外圆最大半径(<=0时为圆)
  double offsetAngle; // 偏移角度
  double corner;
  RoseType roseType;
  double angleGap;
  bool clockWise;
  CircleAlign labelAlign;
  StyleFun<ItemData, LabelStyle>? labelStyleFun;
  StyleFun<ItemData, AreaStyle> areaStyleFun;
  PieAnimatorStyle animatorStyle;

  PieSeries(
    this.data, {
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    this.innerRadius = const SNumber.percent(15),
    this.outerRadius = const SNumber.percent(90),
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
    super.enableScale=false,
    super.clip,
    super.z,
  }) : super(
          xAxisIndex: -1,
          yAxisIndex: -1,
          parallelIndex: -1,
          radarIndex: -1,
          polarAxisIndex: -1,
        );
}

