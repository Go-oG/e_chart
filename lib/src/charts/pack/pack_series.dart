import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/pack/pack_view.dart';
import 'package:flutter/painting.dart';

class PackSeries extends HierarchySeries<PackData> {
  static const _defaultAnimation = AnimatorOption(
    duration: Duration(seconds: 1),
    updateDuration: Duration(milliseconds: 1000),
  );

  bool optTextDraw;
  Fun2<PackData, num>? paddingFun;
  Fun2<PackData, num>? radiusFun;
  Fun3<PackData, PackData, int>? sortFun;
  Fun2<PackData, Alignment>? labelAlignFun;

  PackSeries(
    super.data, {
    this.optTextDraw = true,
    this.radiusFun,
    this.labelAlignFun,
    this.paddingFun,
    this.sortFun,
    super.borderStyleFun,
    super.itemStyleFun,
    super.labelStyleFun,
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
  AreaStyle getAreaStyle(Context context, PackData data) {
    if (itemStyleFun != null) {
      return super.getAreaStyle(context, data);
    }
    return context.option.theme.packTheme.getAreaStyle(data.deep, data.maxDeep).convert(data.status);
  }

  @override
  LineStyle getBorderStyle(Context context, PackData data) {
    if (borderStyleFun != null) {
      return super.getBorderStyle(context, data);
    }
    return context.option.theme.packTheme.getBorderStyle() ?? LineStyle.empty;
  }

  Alignment getLabelAlign(PackData node) {
    var fun = labelAlignFun;
    if (fun != null) {
      return fun.call(node);
    }
    return Alignment.center;
  }

  @override
  SeriesType get seriesType => SeriesType.pack;

  @override
  ChartView? toView() {
    return PackView(this);
  }
}
