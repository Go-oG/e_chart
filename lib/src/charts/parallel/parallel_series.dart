import 'package:e_chart/e_chart.dart';

import 'parallel_view.dart';

class ParallelSeries extends ChartSeries {
  List<ParallelGroup> data;
  Fun4<ParallelGroup, int, Set<ViewState>, LineStyle>? borderStyleFun;
  Fun4<ParallelGroup, int, Set<ViewState>, LabelStyle>? labelStyleFun;
  Fun6<dynamic, ParallelGroup, int, int, Set<ViewState>?, ChartSymbol?>? symbolFun;

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
    super.z,
  }) : super(coordType: CoordType.parallel, gridIndex: -1, calendarIndex: -1, polarIndex: -1, radarIndex: -1);

  @override
  ChartView? toView() {
    return ParallelView(this);
  }

  LineStyle? getBorderStyle(Context context, ParallelGroup data, int index, [Set<ViewState>? status]) {
    if (borderStyleFun != null) {
      return borderStyleFun!.call(data, index, status ?? {});
    }
    var theme = context.option.theme.parallelTheme;
    return theme.getItemStyle(context, index);
  }

  LabelStyle? getLabelStyle(Context context, ParallelGroup data, int index, [Set<ViewState>? status]) {
    if (labelStyleFun != null) {
      return labelStyleFun!.call(data, index, status ?? {});
    }
    var theme = context.option.theme;
    return theme.getLabelStyle()?.convert(status);
  }

  @override
  List<LegendItem> getLegendItem(Context context) {
    List<LegendItem> list = [];
    each(data, (item, i) {
      var name = item.name;
      if (name == null || name.isEmpty) {
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
      p0.styleIndex=p1+start;
    });
    return data.length;
  }
}

class ParallelGroup extends BaseGroupData<dynamic> {
  ParallelGroup(super.data, {super.id, super.name});
}
