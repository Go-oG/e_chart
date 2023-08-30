import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/hexbin/hex_bin_view.dart';

class HexbinSeries extends RectSeries {
  HexbinLayout layout = HexagonsLayout();
  List<ItemData> data;
  LineStyle? border;
  Fun3<ItemData, Set<ViewState>, LineStyle?>? borderFun;
  AreaStyle? itemStyle;
  Fun3<ItemData, Set<ViewState>, AreaStyle?>? itemStyleFun;
  LabelStyle? label;
  Fun3<ItemData, Set<ViewState>, LabelStyle>? labelStyleFun;

  bool clock = false;

  HexbinSeries(
    this.data, {
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
    super.z,
  }) : super(gridIndex: -1, polarIndex: -1, parallelIndex: -1, radarIndex: -1, calendarIndex: -1) {
    if (layout != null) {
      this.layout = layout;
    }
  }

  @override
  ChartView? toView() {
    return HexbinView(this);
  }

  AreaStyle? getItemStyle(Context context, ItemData data, int dataIndex, Set<ViewState>? status) {
    status ??= {};
    if (itemStyleFun != null) {
      return itemStyleFun?.call(data, status);
    }
    if (itemStyle != null) {
      return itemStyle?.convert(status);
    }
    var theme = context.option.theme;
    return AreaStyle(color: theme.getColor(dataIndex)).convert(status);
  }

  LineStyle? getBorderStyle(Context context, ItemData data, int dataIndex, Set<ViewState>? status) {
    status ??= {};
    if (borderFun != null) {
      return borderFun?.call(data, status);
    }
    if (border != null) {
      return border?.convert(status);
    }
    var theme = context.option.theme;
    return theme.hexbinTheme.getBorderStyle()?.convert(status);
  }

  LabelStyle? getLabelStyle(Context context, ItemData data, int dataIndex, Set<ViewState>? status) {
    status ??= {};
    if (labelStyleFun != null) {
      return labelStyleFun?.call(data, status);
    }
    if (label != null) {
      return label?.convert(status);
    }
    var theme = context.option.theme;
    return theme.hexbinTheme.labelStyle?.convert(status);
  }
}
