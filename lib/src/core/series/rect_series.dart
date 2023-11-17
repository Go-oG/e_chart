import 'package:e_chart/e_chart.dart';

abstract class RectSeries extends ChartSeries {
  /// 定义布局的上下左右间距或者宽高，
  /// 宽高的优先级大于上下间距的优先级(如果定义了)
  SNumber leftMargin;
  SNumber topMargin;
  SNumber rightMargin;
  SNumber bottomMargin;
  SNumber? width;
  SNumber? height;

  RectSeries({
    this.leftMargin = SNumber.zero,
    this.topMargin = SNumber.zero,
    this.rightMargin = SNumber.zero,
    this.bottomMargin = SNumber.zero,
    this.width,
    this.height,
    super.coordType,
    super.gridIndex,
    super.calendarIndex,
    super.parallelIndex,
    super.polarIndex,
    super.radarIndex,
    super.animation,
    super.backgroundColor,
    super.tooltip,
    super.clip,
    super.id,
    super.name,
    super.useSingleLayer,
  });

  LayoutParams toLayoutParams() {
    SizeParams w;
    if (width != null) {
      w = SizeParams.from(width!);
    } else {
      w = const SizeParams.match();
    }
    SizeParams h;
    if (height != null) {
      h = SizeParams.from(height!);
    } else {
      h = const SizeParams.match();
    }

    return LayoutParams(
      w,
      h,
      leftMargin: leftMargin,
      topMargin: topMargin,
      rightMargin: rightMargin,
      bottomMargin: bottomMargin,
    );
  }
}

abstract class RectSeries2<T extends RenderData> extends ChartListSeries<T> {
  /// 定义布局的上下左右间距或者宽高，
  /// 宽高的优先级大于上下间距的优先级(如果定义了)
  SNumber leftMargin;
  SNumber topMargin;
  SNumber rightMargin;
  SNumber bottomMargin;
  SNumber? width;
  SNumber? height;

  RectSeries2(
    super.data, {
    this.leftMargin = SNumber.zero,
    this.topMargin = SNumber.zero,
    this.rightMargin = SNumber.zero,
    this.bottomMargin = SNumber.zero,
    this.width,
    this.height,
    super.borderStyleFun,
    super.itemStyleFun,
    super.labelStyle,
    super.labelStyleFun,
    super.labelFormatFun,
    super.labelLineStyleFun,
    super.coordType,
    super.gridIndex,
    super.calendarIndex,
    super.parallelIndex,
    super.polarIndex,
    super.radarIndex,
    super.animation,
    super.backgroundColor,
    super.tooltip,
    super.clip,
    super.id,
    super.name,
    super.useSingleLayer,
  });

  LayoutParams toLayoutParams() {
    SizeParams w;
    if (width != null) {
      w = SizeParams.from(width!);
    } else {
      w = const SizeParams.match();
    }
    SizeParams h;
    if (height != null) {
      h = SizeParams.from(height!);
    } else {
      h = const SizeParams.match();
    }

    return LayoutParams(
      w,
      h,
      leftMargin: leftMargin,
      topMargin: topMargin,
      rightMargin: rightMargin,
      bottomMargin: bottomMargin,
    );
  }
}
