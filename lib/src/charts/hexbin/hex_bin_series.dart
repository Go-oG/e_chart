import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/hexbin/hex_bin_view.dart';

class HexbinSeries extends RectSeries2<HexBinData> {
  HexbinLayout layout = HexagonsLayout();
  List<SNumber> center;

  ///是否为平角在上
  bool flat;

  ///形状的大小(由外接圆半径描述)
  num radius;

  Fun2<HexBinData, LineStyle?>? borderFun;

  bool clock = false;

  HexbinSeries(
    super.data, {
    HexbinLayout? layout,
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    this.flat = true,
    this.radius = 24,
    this.borderFun,
    super.borderStyleFun,
    super.labelFormatFun,
    super.labelLineStyleFun,
    super.labelStyle,
    super.itemStyleFun,
    super.labelStyleFun,
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
    super.name,
    super.useSingleLayer,
  }) : super(coordType: null, gridIndex: -1, polarIndex: -1, parallelIndex: -1, radarIndex: -1, calendarIndex: -1) {
    if (layout != null) {
      this.layout = layout;
    }
  }

  @override
  ChartView? toView(Context context) {
    return HexbinView(context, this);
  }

  @override
  LineStyle getBorderStyle(Context context, HexBinData data) {
    if (borderFun != null) {
      return super.getBorderStyle(context, data);
    }

    var theme = context.option.theme;
    return theme.hexbinTheme.getBorderStyle()?.convert(data.status) ?? LineStyle.empty;
  }

  @override
  LabelStyle getLabelStyle(Context context, HexBinData data) {
    if (labelStyleFun != null) {
      return super.getLabelStyle(context, data);
    }
    var theme = context.option.theme;
    return theme.hexbinTheme.labelStyle ?? LabelStyle.empty;
  }

  @override
  List<LegendItem> getLegendItem(Context context) => [];

  @override
  SeriesType get seriesType => SeriesType.hexbin;
}
