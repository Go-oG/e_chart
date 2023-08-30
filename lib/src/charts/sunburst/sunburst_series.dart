import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/sunburst/sunburst_view.dart';

import 'sunburst_node.dart';

typedef RadiusDiffFun = SNumber Function(int deep, int maxDeep, num radius);

/// 旭日图
class SunburstSeries extends RectSeries {
  TreeData data;
  List<SNumber> center;
  SNumber innerRadius; //内圆半径(<=0时为圆)
  SNumber outerRadius; //外圆最大半径(<=0时为圆)
  num sweepAngle;
  num offsetAngle; // 偏移角度
  bool clockwise;
  num radiusGap; // 两层半径之间的间距
  num angleGap; // 相邻两扇形的角度
  bool matchParent; //孩子是否占满父节点区域，如果是则父节点的值来源于子节点
  num corner; // 扇形圆角
  Sort sort; // 数据排序规则

  SelectedMode selectedMode; //选中模式的配置
  RadiusDiffFun? radiusDiffFun; // 半径差值函数
  AreaStyle? backStyle; //返回区域样式
  Fun2<SunburstNode, AreaStyle> areaStyleFun; //填充区域的样式
  Fun2<SunburstNode, LabelStyle>? labelStyleFun; //文字标签的样式
  Fun2<SunburstNode, double>? rotateFun; // 标签旋转角度函数 -1 径向旋转 -2 切向旋转  >=0 旋转角度
  Fun2<SunburstNode, Align2>? labelAlignFun; // 标签对齐函数
  Fun2<SunburstNode, double>? labelMarginFun; // 标签对齐函数

  SunburstSeries(
    this.data, {
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    this.innerRadius = const SNumber.number(0),
    this.outerRadius = const SNumber.percent(80),
    this.offsetAngle = 0,
    this.sweepAngle = 360,
    this.clockwise = true,
    this.corner = 0,
    this.radiusGap = 0,
    this.angleGap = 0,
    this.matchParent = false,
    this.sort = Sort.empty,
    this.selectedMode = SelectedMode.group,
    this.radiusDiffFun,
    this.labelStyleFun,
    this.labelAlignFun,
    this.rotateFun,
    this.labelMarginFun,
    required this.areaStyleFun,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.tooltip,
    super.animation,
    super.backgroundColor,
    super.id,
    super.clip,
    super.z,
  }) : super(gridIndex: -1, polarIndex: -1, parallelIndex: -1, calendarIndex: -1, radarIndex: -1);

  @override
  ChartView? toView() {
    return SunburstView(this);
  }
}
