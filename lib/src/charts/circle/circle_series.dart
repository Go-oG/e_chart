import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/circle/circle_view.dart';

class CircleSeries extends ChartSeries2<CircleData> {
  List<SNumber> center;
  SNumber innerRadius;
  SNumber radiusGap;
  SNumber? radius;
  double corner;
  bool clockWise;

  Fun5<CircleData, int, double, double, num>? radiusGapFun;
  Fun5<CircleData, int, double, double, num>? radiusFun;

  Fun2<CircleData, AreaStyle>? backStyleFun;

  CircleSeries(
    super.data, {
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    this.radius,
    this.innerRadius = const SNumber.percent(15),
    this.radiusGap = const SNumber.number(10),
    this.corner = 0,
    this.clockWise = true,
    this.radiusFun,
    this.radiusGapFun,
    this.backStyleFun,
    super.itemStyleFun,
    super.borderStyleFun,
    super.labelStyleFun,
    super.animation,
    super.backgroundColor,
    super.clip,
    super.id,
    super.name,
    super.tooltip,
    super.useSingleLayer,
  }) : super(
          calendarIndex: -1,
          gridIndex: -1,
          parallelIndex: -1,
          polarIndex: -1,
          radarIndex: -1,
          coordType: CoordType.single,
        );

  AreaStyle getBackStyle(Context context, CircleData data) {
    if (backStyleFun != null) {
      return backStyleFun?.call(data) ?? AreaStyle.empty;
    }
    return AreaStyle.empty;
  }

  @override
  ChartView? toView() {
    return CircleView(this);
  }


  @override
  int onAllocateStyleIndex(int start) {
    each(data, (p0, p1) {
      p0.styleIndex = p1 + start;
    });
    return data.length;
  }

  @override
  SeriesType get seriesType => SeriesType.circle;
}
