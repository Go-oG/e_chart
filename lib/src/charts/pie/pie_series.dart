import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/pie/pie_view.dart';

/// 饼图系列
class PieSeries extends RectSeries {
  List<ItemData> data;
  List<SNumber> center;

  //内圆半径(<=0时为圆)
  SNumber innerRadius;

  //外圆最大半径(<=0时为圆)
  SNumber outerRadius;

  ///饼图扫过的角度(范围最大为360，如果为负数则为逆时针)
  num sweepAngle;

  //偏移角度默认为0
  double offsetAngle;

  //拐角半径 默认为0
  double corner;

  //角度间距(默认为0)
  double angleGap;

  //动画缩放扩大系数
  SNumber scaleExtend;

  //布局类型
  RoseType roseType;
  CircleAlign labelAlign;
  PieAnimatorStyle animatorStyle;

  Fun4<ItemData, int, Set<ViewState>, LabelStyle?>? labelStyleFun;
  Fun4<ItemData, int, Set<ViewState>, AreaStyle?>? areaStyleFun;
  Fun4<ItemData, int, Set<ViewState>, LineStyle?>? borderFun;

  ///用于实现偏移
  Fun2<ItemData, num>? offsetFun;

  PieSeries(
    this.data, {
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    this.innerRadius = const SNumber.percent(15),
    this.outerRadius = const SNumber.percent(45),
    this.scaleExtend = const SNumber.number(16),
    this.sweepAngle = 360,
    this.offsetAngle = 0,
    this.corner = 0,
    this.roseType = RoseType.radius,
    this.angleGap = 0,
    this.labelStyleFun,
    this.labelAlign = CircleAlign.inside,
    this.animatorStyle = PieAnimatorStyle.expandScale,
    this.areaStyleFun,
    this.borderFun,
    this.offsetFun,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.coordType,
    super.calendarIndex,
    super.tooltip,
    super.animation,
    super.clip,
    super.backgroundColor,
    super.id,
    super.z,
  }) : super(gridIndex: -1, parallelIndex: -1, radarIndex: -1, polarIndex: -1);

  @override
  ChartView? toView() {
    return PieView(this);
  }

  AreaStyle? getAreaStyle(Context context, ItemData data, int dataIndex, Set<ViewState> status) {
    if (areaStyleFun != null) {
      return areaStyleFun?.call(data, dataIndex, status);
    }
    return context.option.theme.getAreaStyle(dataIndex).convert(status);
  }

  LineStyle? getBorderStyle(Context context, ItemData data, int dataIndex, Set<ViewState> status) {
    if (borderFun != null) {
      return borderFun?.call(data, dataIndex, status);
    }
    var theme = context.option.theme.pieTheme;
    return theme.getBorderStyle();
  }

  LabelStyle? getLabelStyle(Context context, ItemData data, int dataIndex, Set<ViewState> status) {
    if (labelStyleFun != null) {
      return labelStyleFun!.call(data, dataIndex, status);
    }
    var theme = context.option.theme;
    return theme.getLabelStyle();
  }

  double getOffset(Context context, ItemData data) {
    if (offsetFun == null) {
      return 0;
    }
    return offsetFun!.call(data).toDouble();
  }

  @override
  List<LegendItem> getLegendItem(Context context) {
    List<LegendItem> list = [];
    each(data, (item, i) {
      var name = item.name;
      if (name == null || name.isEmpty) {
        return;
      }
      var color = context.option.theme.getColor(i);
      list.add(LegendItem(
        name,
        RectSymbol()..itemStyle = AreaStyle(color: color),
        seriesId: id,
      ));
    });
    return list;
  }

  @override
  int onAllocateStyleIndex(int start) {
    each(data, (p0, p1) {
      p0.styleIndex = p1 + start;
    });
    return data.length;
  }
}

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
