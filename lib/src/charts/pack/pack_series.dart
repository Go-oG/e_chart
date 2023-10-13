import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/pack/pack_view.dart';
import 'package:flutter/painting.dart';

class PackSeries extends RectSeries {
  static const _defaultAnimation = AnimatorOption(
    duration: Duration(seconds: 1),
    updateDuration: Duration(milliseconds: 1000),
  );

  TreeData data;
  bool optTextDraw;
  Fun2<PackNode, AreaStyle?>? itemStyleFun;
  Fun2<PackNode, LineStyle?>? borderStyleFun;
  Fun2<PackNode, LabelStyle?>? labelStyleFun;
  Fun2<PackNode, num>? paddingFun;
  Fun2<PackNode, num>? radiusFun;
  Fun3<PackNode, PackNode, int>? sortFun;
  Fun2<PackNode, Alignment>? labelAlignFun;

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

  AreaStyle? getItemStyle(Context context, PackNode node) {
    if (itemStyleFun != null) {
      return itemStyleFun?.call(node);
    }
    return context.option.theme.packTheme.getAreaStyle(node.deep, node.maxDeep).convert(node.status);
  }

  LineStyle? getBorderStyle(Context context, PackNode node) {
    if (borderStyleFun != null) {
      return borderStyleFun?.call(node);
    }
    return context.option.theme.packTheme.getBorderStyle();
  }

  LabelStyle? getLabelStyle(Context context, PackNode node) {
    if (labelStyleFun != null) {
      return labelStyleFun?.call(node);
    }
    return null;
  }

  Alignment getLabelAlign(PackNode node) {
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
