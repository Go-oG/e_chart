import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'parallel_view.dart';

class ParallelSeries extends ChartSeries3<ParallelChildData, ParallelData> {
  Fun3<ParallelChildData, ParallelData, ChartSymbol?>? symbolFun;
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

  ChartSymbol getSymbol(ParallelChildData data, ParallelData group) {
    var fun = symbolFun;
    if (fun != null) {
      return fun.call(data, group) ?? EmptySymbol.empty;
    }
    return EmptySymbol.empty;
  }

  @override
  LineStyle getBorderStyle(Context context, ParallelChildData data, ParallelData parent) {
    if (borderStyleFun != null) {
      return super.getBorderStyle(context, data, parent);
    }
    var theme = context.option.theme.parallelTheme;
    return theme.getItemStyle(context, data.styleIndex) ?? LineStyle.empty;
  }

  @override
  AreaStyle getItemStyle(Context context, ParallelChildData data,ParallelData parent) {
    return AreaStyle.empty;
  }

  @override
  SeriesType get seriesType => SeriesType.parallel;

  ExtremeHelper<ParallelData>? _extremeHelper;

  ExtremeHelper<ParallelData> getExtremeHelper() {
    if (_extremeHelper != null) {
      return _extremeHelper!;
    }

    int maxDim = 0;
    each(data, (group, p0) {
      maxDim = max([maxDim, group.data.length]).toInt();
    });

    ExtremeHelper<ParallelData> helper = ExtremeHelper(
      (p0) => List.generate(maxDim, (index) => '$index', growable: false),
      (p0, index) {
        var di = int.parse(index);
        if (p0.data.length <= di) {
          return null;
        }
        return p0.data[di].data;
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

  @override
  List<LegendItem> getLegendItem(Context context) {
    List<LegendItem> list = [];
    each(data, (item, i) {
      var name = item.label.text;
      if (name.isEmpty) {
        return;
      }
      if(item.data.isEmpty){
        list.add(LegendItem(name, CircleSymbol()..itemStyle = const AreaStyle(color:Colors.blue), seriesId: id));
      }else{
        list.add(LegendItem(name, CircleSymbol()..itemStyle = AreaStyle(color:item.data.first.borderStyle.pickColor()), seriesId: id));
      }
    });
    return list;
  }

  @override
  int onAllocateStyleIndex(int start) {
    each(data, (p0, p1) {
      p0.styleIndex = start + p1;
      each(p0.data, (child, p2) {
        child.styleIndex = p1;
      });
    });
    return data.length;
  }
}
