import 'package:e_chart/e_chart.dart';
import 'parallel_view.dart';

class ParallelSeries extends ChartSeries {
  List<ParallelData> data;
  Fun2<ParallelData, LineStyle>? borderStyleFun;
  Fun2<ParallelData, LabelStyle>? labelStyleFun;
  Fun3<dynamic, ParallelData, ChartSymbol?>? symbolFun;

  bool connectNull;

  ParallelSeries({
    required this.data,
    this.borderStyleFun,
    this.symbolFun,
    this.connectNull = true,
    super.animation,
    super.parallelIndex,
    super.clip,
    super.tooltip,
    super.backgroundColor,
    super.id,
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

  LineStyle getBorderStyle(Context context, ParallelData data) {
    if (borderStyleFun != null) {
      return borderStyleFun!.call(data);
    }
    var theme = context.option.theme.parallelTheme;
    return theme.getItemStyle(context, data.styleIndex) ?? LineStyle.empty;
  }

  LabelStyle getLabelStyle(Context context, ParallelData data) {
    if (labelStyleFun != null) {
      return labelStyleFun!.call(data);
    }
    var theme = context.option.theme;
    return theme.getLabelStyle()?.convert(data.status) ?? LabelStyle.empty;
  }

  @override
  List<LegendItem> getLegendItem(Context context) {
    List<LegendItem> list = [];
    each(data, (item, i) {
      var name = item.label.text;
      if (name.isEmpty) {
        return;
      }
      var color = context.option.theme.getColor(i);
      list.add(LegendItem(
        name,
        RectSymbol()..itemStyle = AreaStyle(color: color),
        seriesId: id,
      ));
    });
    return list;
  }

  @override
  int onAllocateStyleIndex(int start) {
    each(data, (p0, p1) {
      p0.styleIndex = p1 + start;
    });
    return data.length;
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
