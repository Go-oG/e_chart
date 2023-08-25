import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/pack/pack_view.dart';


class PackSeries extends RectSeries {
  TreeData data;
  bool optTextDraw;
  Fun2<PackNode, AreaStyle?>? areaStyleFun;
  Fun2<PackNode, LabelStyle?>? labelStyleFun;
  Fun2<PackNode, num>? paddingFun;
  Fun2<PackNode, num>? radiusFun;
  Fun3<PackNode, PackNode, int>? sortFun;
  VoidFun1<TreeData>? onClick;

  PackSeries(
    this.data, {
    this.optTextDraw = true,
    this.radiusFun,
    required this.areaStyleFun,
    this.labelStyleFun,
    this.paddingFun,
    this.sortFun,
    this.onClick,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.animation,
    super.backgroundColor,
    super.id,
    super.tooltip,
    super.clip,
    super.z,
  }) : super(parallelIndex: -1, polarIndex: -1, calendarIndex: -1, gridIndex: -1, radarIndex: -1);

  @override
  ChartView? toView() {
    return PackView(this);
  }
}
