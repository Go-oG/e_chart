import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/pack/pack_view.dart';
import 'package:flutter/painting.dart';

class PackSeries extends RectSeries {
  static const _defaultAnimation = AnimatorOption(
    duration: Duration(seconds: 1),
    updateDuration: Duration(milliseconds: 1000),
  );

  PackData data;

  bool optTextDraw;
  Fun2<PackData, AreaStyle?>? itemStyleFun;
  Fun2<PackData, LineStyle?>? borderStyleFun;
  Fun2<PackData, LabelStyle?>? labelStyleFun;
  Fun2<PackData, num>? paddingFun;
  Fun2<PackData, num>? radiusFun;
  Fun3<PackData, PackData, int>? sortFun;
  Fun2<PackData, Alignment>? labelAlignFun;

  PackSeries(
    this.data, {
    this.optTextDraw = true,
    this.radiusFun,
    this.itemStyleFun,
    this.borderStyleFun,
    this.labelStyleFun,
    this.labelAlignFun,
    this.paddingFun,
    this.sortFun,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.animation = _defaultAnimation,
    super.backgroundColor,
    super.id,
    super.tooltip,
    super.clip,
  }) : super(parallelIndex: -1, polarIndex: -1, calendarIndex: -1, gridIndex: -1, radarIndex: -1);

  @override
  ChartView? toView() {
    return PackView(this);
  }

  AreaStyle? getItemStyle(Context context, PackData node) {
    if (itemStyleFun != null) {
      return itemStyleFun?.call(node);
    }
    return context.option.theme.packTheme.getAreaStyle(node.deep, node.maxDeep).convert(node.status);
  }

  LineStyle? getBorderStyle(Context context, PackData node) {
    if (borderStyleFun != null) {
      return borderStyleFun?.call(node);
    }
    return context.option.theme.packTheme.getBorderStyle();
  }

  LabelStyle? getLabelStyle(Context context, PackData node) {
    if (labelStyleFun != null) {
      return labelStyleFun?.call(node);
    }
    return null;
  }

  Alignment getLabelAlign(PackData node) {
    var fun = labelAlignFun;
    if (fun != null) {
      return fun.call(node);
    }
    return Alignment.center;
  }

  @override
  List<LegendItem> getLegendItem(Context context) => [];

  @override
  int onAllocateStyleIndex(int start) {
    return 0;
  }

  @override
  SeriesType get seriesType => SeriesType.pack;
}
