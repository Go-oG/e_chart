import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/circle/circle_view.dart';

class CircleSeries extends ChartSeries {
  List<CircleItemData> data;
  List<SNumber> center;
  SNumber innerRadius;
  SNumber radiusGap;
  SNumber? radius;
  double corner;
  bool clockWise;

  Fun5<CircleItemData, int, double, double, num>? radiusGapFun;
  Fun5<CircleItemData, int, double, double, num>? radiusFun;

  Fun2<CircleItemData, AreaStyle>? backStyleFun;

  Fun4<CircleItemData, int, Set<ViewState>, LabelStyle?>? labelStyleFun;
  Fun4<CircleItemData, int, Set<ViewState>, AreaStyle?>? areaStyleFun;
  Fun4<CircleItemData, int, Set<ViewState>, LineStyle?>? borderFun;

  CircleSeries(
    this.data, {
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    this.radius,
    this.innerRadius = const SNumber.percent(15),
    this.radiusGap = const SNumber.number(10),
    this.corner = 0,
    this.clockWise = true,
    this.radiusFun,
    this.radiusGapFun,
    this.backStyleFun,
    this.labelStyleFun,
    this.areaStyleFun,
    this.borderFun,
    super.animation,
    super.backgroundColor,
    super.clip,
    super.id,
    super.name,
    super.tooltip,
    super.z,
  }) : super(
          calendarIndex: -1,
          gridIndex: -1,
          parallelIndex: -1,
          polarIndex: -1,
          radarIndex: -1,
          coordType: CoordType.single,
        );

  AreaStyle getBackStyle(Context context, CircleItemData data) {
    if (backStyleFun != null) {
      return backStyleFun?.call(data) ?? AreaStyle.empty;
    }
    return AreaStyle.empty;
  }

  AreaStyle getAreaStyle(Context context, CircleItemData data, int dataIndex, Set<ViewState> status) {
    AreaStyle? style;
    if (areaStyleFun != null) {
      style = areaStyleFun?.call(data, dataIndex, status);
      if (style != null) {
        return style;
      }
    }
    return context.option.theme.getAreaStyle(dataIndex).convert(status);
  }

  LineStyle getBorderStyle(Context context, CircleItemData data, int dataIndex, Set<ViewState> status) {
    if (borderFun != null) {
      return borderFun?.call(data, dataIndex, status) ?? LineStyle.empty;
    }
    var theme = context.option.theme.pieTheme;
    return theme.getBorderStyle() ?? LineStyle.empty;
  }

  LabelStyle getLabelStyle(Context context, CircleItemData data, int dataIndex, Set<ViewState> status) {
    if (labelStyleFun != null) {
      return labelStyleFun!.call(data, dataIndex, status) ?? LabelStyle.empty;
    }
    var theme = context.option.theme;
    return theme.getLabelStyle() ?? LabelStyle.empty;
  }

  @override
  ChartView? toView() {
    return CircleView(this);
  }

  @override
  List<LegendItem> getLegendItem(Context context) {
    List<LegendItem> list = [];
    each(data, (item, i) {
      var name = item.name;
      if (name == null || name.isEmpty) {
        return;
      }
      list.add(LegendItem(name, CircleSymbol()..itemStyle = getAreaStyle(context, item, i, {})));
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

class CircleItemData extends BaseItemData {
  num value;
  num max;
  num offsetAngle;

  CircleItemData(this.value, this.max, {this.offsetAngle = 0, super.id, super.name});
}
