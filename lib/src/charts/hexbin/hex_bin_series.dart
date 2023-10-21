import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/hexbin/hex_bin_view.dart';

class HexbinSeries extends RectSeries {
  HexbinLayout layout = HexagonsLayout();
  List<HexbinData> data;
  List<SNumber> center;

  ///是否为平角在上
  bool flat;

  ///形状的大小(由外接圆半径描述)
  num radius;

  LineStyle? border;
  Fun2<HexbinData, LineStyle?>? borderFun;
  AreaStyle? itemStyle;
  Fun2<HexbinData, AreaStyle?>? itemStyleFun;
  LabelStyle? label;
  Fun2<HexbinData, LabelStyle>? labelStyleFun;
  bool clock = false;

  HexbinSeries(
    this.data, {
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    this.flat = true,
    this.radius = 24,
    this.border,
    this.borderFun,
    this.itemStyle,
    this.itemStyleFun,
    this.label,
    this.labelStyleFun,
    HexbinLayout? layout,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.animation,
    super.clip,
    super.tooltip,
    super.backgroundColor,
    super.id,
  }) : super(gridIndex: -1, polarIndex: -1, parallelIndex: -1, radarIndex: -1, calendarIndex: -1) {
    if (layout != null) {
      this.layout = layout;
    }
  }

  @override
  ChartView? toView() {
    return HexbinView(this);
  }

  AreaStyle? getItemStyle(Context context, HexbinData data) {
    if (itemStyleFun != null) {
      return itemStyleFun?.call(data);
    }
    if (itemStyle != null) {
      return itemStyle?.convert(data.status);
    }
    var theme = context.option.theme;
    return AreaStyle(color: theme.getColor(data.dataIndex)).convert(data.status);
  }

  LineStyle? getBorderStyle(Context context, HexbinData data) {
    if (borderFun != null) {
      return borderFun?.call(data);
    }
    if (border != null) {
      return border?.convert(data.status);
    }
    var theme = context.option.theme;
    return theme.hexbinTheme.getBorderStyle()?.convert(data.status);
  }

  LabelStyle? getLabelStyle(Context context, HexbinData data) {
    if (labelStyleFun != null) {
      return labelStyleFun?.call(data);
    }
    if (label != null) {
      return label?.convert(data.status);
    }
    var theme = context.option.theme;
    return theme.hexbinTheme.labelStyle?.convert(data.status);
  }

  @override
  List<LegendItem> getLegendItem(Context context) => [];

  @override
  int onAllocateStyleIndex(int start) {
    each(data, (p0, p1) {
      p0.styleIndex = p1 + start;
    });
    return data.length;
  }

  @override
  SeriesType get seriesType => SeriesType.hexbin;
}
