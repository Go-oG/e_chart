import 'package:e_chart/e_chart.dart';
import 'parallel_view.dart';

class ParallelSeries extends ChartSeries2<ParallelData> {
  Fun3<dynamic, ParallelData, ChartSymbol?>? symbolFun;

  bool connectNull;

  ParallelSeries(
    super.data, {
    this.symbolFun,
    this.connectNull = true,
    super.animation,
    super.parallelIndex,
    super.clip,
    super.tooltip,
    super.backgroundColor,
    super.id,
    super.borderStyleFun,
    super.itemStyleFun,
    super.labelFormatFun,
    super.labelLineStyleFun,
    super.labelStyle,
    super.labelStyleFun,
    super.name,
    super.useSingleLayer,
  }) : super(coordType: CoordType.parallel, gridIndex: -1, calendarIndex: -1, polarIndex: -1, radarIndex: -1);

  @override
  ChartView? toView() {
    return ParallelView(this);
  }

  ChartSymbol getSymbol(dynamic data, ParallelData group) {
    var fun = symbolFun;
    if (fun != null) {
      return fun.call(data, group) ?? EmptySymbol.empty;
    }
    return EmptySymbol.empty;
  }

  @override
  LineStyle getBorderStyle(Context context, ParallelData data) {
    if (borderStyleFun != null) {
      return super.getBorderStyle(context, data);
    }
    var theme = context.option.theme.parallelTheme;
    return theme.getItemStyle(context, data.styleIndex) ?? LineStyle.empty;
  }

  @override
  AreaStyle getItemStyle(Context context, ParallelData data) {
    return AreaStyle.empty;
  }

  @override
  SeriesType get seriesType => SeriesType.parallel;

  ExtremeHelper<dynamic>? _extremeHelper;

  ExtremeHelper<dynamic> getExtremeHelper() {
    if (_extremeHelper != null) {
      return _extremeHelper!;
    }

    int maxValue = 0;
    each(data, (group, p0) {
      maxValue = max([maxValue, group.data.length]).toInt();
    });

    ExtremeHelper<ParallelData> helper = ExtremeHelper(
      (p0) => List.generate(maxValue, (index) => '$index', growable: false),
      (p0, index) {
        var di = int.parse(index);
        if (p0.data.length <= di) {
          return null;
        }
        return p0.data[di];
      },
      data,
    );
    _extremeHelper = helper;
    return helper;
  }

  void clearExtreme() {
    _extremeHelper = null;
  }

  @override
  void notifyUpdateData() {
    clearExtreme();
    super.notifyUpdateData();
  }

  @override
  void notifyConfigChange() {
    clearExtreme();
    super.notifyConfigChange();
  }
}
