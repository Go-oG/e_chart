import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/graph/graph_view.dart';

class GraphSeries extends RectSeries {
  Graph graph;
  GraphLayout layout;
  Size? nodeSize;
  Fun2<GraphNode, Size>? sizeFun;

  Fun2<GraphNode, ChartSymbol>? symbolFun;
  Fun3<GraphNode, GraphNode, LineStyle>? lineFun;

  GraphSeries(
    this.graph,
    this.layout, {
    this.nodeSize,
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
    super.z,
  });

  @override
  void dispose() {
    layout.dispose();
    super.dispose();
  }

  @override
  ChartView? toView() {
    return GraphView(this);
  }

  ///给定一个节点返回节点的大小
  final _defaultSize = const Size.square(8);

  Size getNodeSize(GraphNode node) {
    if (sizeFun != null) {
      return sizeFun!.call(node);
    }
    if (nodeSize != null) {
      return nodeSize!;
    }
    return _defaultSize;
  }

  ChartSymbol getSymbol(Context context, GraphNode node) {
    var fun = symbolFun;
    if (fun != null) {
      return fun.call(node);
    }
    var as = context.option.theme.getAreaStyle(node.dataIndex);
    var bs = context.option.theme.graphTheme.getStyle() ?? LineStyle.empty;
    return CircleSymbol(radius: node.r, itemStyle: as, borderStyle: bs).convert(node.status);
  }
}
