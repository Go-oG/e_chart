import '../../functions.dart';
import '../../model/enums/align2.dart';
import '../../model/enums/select_mode.dart';
import '../../model/enums/sort.dart';
import '../../model/string_number.dart';
import '../../model/tree_data.dart';
import '../../style/area_style.dart';
import '../../style/label.dart';
import '../series.dart';
import 'layout.dart';

// 半径差值函数
typedef RadiusDiffFun = SNumber Function(int deep, int maxDeep, num radius);

/// 旭日图
class SunburstSeries extends RectSeries {
  TreeData data;
  List<SNumber> center;
  SNumber innerRadius; //内圆半径(<=0时为圆)
  SNumber outerRadius; //外圆最大半径(<=0时为圆)
  double offsetAngle; // 偏移角度
  double radiusGap; // 两层半径之间的间距
  double angleGap; // 相邻两扇形的角度
  bool matchParent; //孩子是否占满父节点区域，如果是则父节点的值来源于子节点
  double corner; // 扇形区域圆角
  Sort sort; // 数据排序规则
  SelectedMode selectedMode; //选中模式的配置
  RadiusDiffFun? radiusDiffFun; // 半径差值函数
  AreaStyle? backStyle; //返回区域样式
  StyleFun<SunburstNode, AreaStyle> areaStyleFun; //填充区域的样式
  StyleFun<SunburstNode, LabelStyle>? labelStyleFun; //文字标签的样式
  StyleFun<SunburstNode, double>? rotateFun; // 标签旋转角度函数 -1 径向旋转 -2 切向旋转  >=0 旋转角度
  StyleFun<SunburstNode, Align2>? labelAlignFun; // 标签对齐函数
  StyleFun<SunburstNode, double>? labelMarginFun; // 标签对齐函数

  SunburstSeries(
    this.data, {
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    this.innerRadius = const SNumber.number(0),
    this.outerRadius = const SNumber.percent(80),
    this.offsetAngle = 0,
    this.corner = 0,
    this.radiusGap = 0,
    this.angleGap = 0,
    this.matchParent = false,
    this.sort = Sort.empty,
    this.selectedMode = SelectedMode.all,
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
    super.touch,
    super.clip,
    super.z,
  }) : super(xAxisIndex: -1, yAxisIndex: -1, polarAxisIndex: -1, parallelIndex: -1, calendarIndex: -1, radarIndex: -1);
}
