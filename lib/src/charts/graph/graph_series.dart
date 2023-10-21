import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/graph/graph_view.dart';

class GraphSeries extends RectSeries {
  List<GraphData> nodes;
  List<EdgeData> edges;
  GraphLayout layout;

  bool enableDrag;
  bool onlyDragNode;

  Fun2<GraphData, Size>? sizeFun;
  Fun2<GraphData, ChartSymbol>? symbolFun;
  Fun3<GraphData, GraphData, LineStyle>? lineFun;

  GraphSeries(
    this.nodes,
    this.edges,
    this.layout, {
    this.enableDrag = true,
    this.onlyDragNode = true,
    this.sizeFun,
    this.symbolFun,
    this.lineFun,
    super.animation,
    super.backgroundColor,
    super.bottomMargin,
    super.calendarIndex,
    super.clip,
    super.height,
    super.id,
    super.leftMargin,
    super.gridIndex,
    super.parallelIndex,
    super.polarIndex,
    super.radarIndex,
    super.rightMargin,
    super.tooltip,
    super.topMargin,
    super.width,
  });

  @override
  ChartView? toView() {
    return GraphView(this);
  }

  ///给定一个节点返回节点的大小
  final _defaultSize = const Size.square(16);

  Size getNodeSize(GraphData data) {
    var fun = sizeFun;
    if (fun != null) {
      return fun.call(data);
    }
    double w = 16, h = 16;
    if (data.data.width != null && data.data.width! > 0) {
      w = data.data.width!.toDouble();
    }
    if (data.data.height != null && data.data.height! > 0) {
      h = data.data.height!.toDouble();
    }
    if (w == _defaultSize.width && h == _defaultSize.height) {
      return _defaultSize;
    }
    return Size(w, h);
  }

  ChartSymbol getSymbol(Context context, GraphData data) {
    var fun = symbolFun;
    if (fun != null) {
      return fun.call(data);
    }
    var as = context.option.theme.getAreaStyle(data.dataIndex).convert(data.status);
    var bs = context.option.theme.graphTheme.getStyle() ?? LineStyle.empty;
    return CircleSymbol(radius: data.size.shortestSide / 2, itemStyle: as, borderStyle: bs).convert(data.status);
  }

  LineStyle getBorderStyle(Context context, GraphData source, GraphData target, Set<ViewState> status) {
    var fun = lineFun;
    if (fun != null) {
      return fun.call(source, target);
    }
    return context.option.theme.graphTheme.getStyle() ?? LineStyle.empty;
  }

  @override
  List<LegendItem> getLegendItem(Context context) => [];

  @override
  int onAllocateStyleIndex(int start) {
    each(nodes, (p0, p1) {
      p0.styleIndex = p1 + start;
    });
    return nodes.length;
  }

  @override
  SeriesType get seriesType => SeriesType.graph;
}
