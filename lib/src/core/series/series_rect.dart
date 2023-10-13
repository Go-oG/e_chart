import '../../model/string_number.dart';
import '../model/layout_params.dart';
import '../model/size_params.dart';
import 'series.dart';

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
