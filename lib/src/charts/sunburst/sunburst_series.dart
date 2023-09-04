import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/sunburst/sunburst_view.dart';

import 'sunburst_node.dart';

typedef RadiusDiffFun = num Function(int deep, int maxDeep, num radius);

/// 旭日图
class SunburstSeries extends RectSeries {
  TreeData data;
  List<SNumber> center;
  List<SNumber> radius;

  ///起始角度
  num startAngle;

  ///扫过的角度 负数为逆时针
  num sweepAngle;

  ///两层半径之间的间距
  num radiusGap;

  ///相邻两扇形的角度间距
  num angleGap;

  /// 扇形圆角度数
  num corner;
  Sort sort;

  ///孩子是否占满父节点区域，如果是，那么父节点的值来源于子节点值的和
  bool matchParent;

  ///选中模式
  SelectedMode selectedMode;

  ///点击节点后的行为
  ///当为true时则点击节点后以该节点为根结点
  ///当为 false 则什么都不做
  bool rootToNode;

  ///半径差值函数
  RadiusDiffFun? radiusDiffFun;

  ///返回区域样式
  AreaStyle? backStyle;

  ///填充区域的样式
  Fun2<SunburstNode, AreaStyle?>? areaStyleFun;
  Fun2<SunburstNode, LineStyle?>? borderStyleFun;

  ///文字标签的样式
  Fun2<SunburstNode, LabelStyle?>? labelStyleFun;

  ///标签旋转角度函数 -1 径向旋转 -2 切向旋转  >=0 旋转角度
  Fun2<SunburstNode, double>? rotateFun;

  ///标签对齐函数
  Fun2<SunburstNode, Align2?>? labelAlignFun;

  ///标签间距函数
  Fun2<SunburstNode, double>? labelMarginFun;

  SunburstSeries(
    this.data, {
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    this.radius = const [SNumber.number(0), SNumber.percent(50)],
    this.startAngle = 0,
    this.sweepAngle = 360,
    this.corner = 0,
    this.radiusGap = 0,
    this.angleGap = 0,
    this.matchParent = false,
    this.rootToNode = true,
    this.sort = Sort.empty,
    this.selectedMode = SelectedMode.group,
    this.radiusDiffFun,
    this.labelStyleFun,
    this.labelAlignFun,
    this.rotateFun,
    this.labelMarginFun,
    this.areaStyleFun,
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

  AreaStyle getAreaStyle(Context context, SunburstNode node) {
    if (areaStyleFun != null) {
      return areaStyleFun!.call(node) ?? AreaStyle.empty;
    }
    return AreaStyle(color: context.option.theme.getColor(node.dataIndex)).convert(node.status);
  }

  LineStyle getBorderStyle(Context context, SunburstNode node) {
    if (borderStyleFun != null) {
      return borderStyleFun?.call(node) ?? LineStyle.empty;
    }
    return LineStyle.empty;
  }

  LabelStyle getLabelStyle(Context context, SunburstNode node) {
    if (labelStyleFun != null) {
      return labelStyleFun!.call(node) ?? LabelStyle.empty;
    }
    var theme = context.option.theme;
    return theme.getLabelStyle() ?? LabelStyle.empty;
  }

  Align2 getLabelAlign(Context context, SunburstNode node) {
    if (labelAlignFun != null) {
      return labelAlignFun!.call(node) ?? Align2.center;
    }
    return Align2.center;
  }
}
