import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';

abstract class GraphLayout extends LayoutHelper2<GraphNode, GraphSeries> {
  ///是否在工作线程中布局
  bool workerThread;

  ///节点大小获取优先级: Node.size>sizeFun>>nodeSize>default（8）
  Fun3<Graph, List<GraphNode>, Map<GraphNode, num>>? sort;
  Fun2<GraphNode, num>? nodeSpaceFun;

  GraphLayout({
    this.nodeSpaceFun,
    this.sort,
    this.workerThread = false,
  }) : super.lazy();

  @override
  void doLayout(Rect boxBound, Rect globalBoxBound, LayoutType type) {
    each(series.graph.nodes, (node, p1) {
      node.index=p1;
      node.dataIndex=p1;
      node.size=series.getNodeSize(node);
      node.setSymbol(series.getSymbol(context, node), true);
    });
    super.doLayout(boxBound, globalBoxBound, type);
  }

  @override
  void onRunUpdateAnimation(var list, var animation) {
    notifyLayoutUpdate();
  }

  @override
  SeriesType get seriesType => SeriesType.graph;

  @override
  Offset getScroll() {
    return Offset.zero;
  }

  @override
  void dispose() {
    interrupt();
    super.dispose();
  }

  @override
  void notifyLayoutEnd() {
    if (!hasInterrupted && hasListeners) {
      super.notifyLayoutEnd();
    }
  }

  @override
  void notifyLayoutUpdate() {
    if (!hasInterrupted && hasListeners) {
      super.notifyLayoutUpdate();
    }
  }


  ///获取节点间距
  num getNodeSpace(GraphNode node) {
    return nodeSpaceFun?.call(node) ?? 8;
  }

  void sortNode(Graph graph, List<GraphNode> list, [bool asc = false]) {
    if (sort == null) {
      return;
    }
    Map<GraphNode, num> sortMap = sort!.call(graph, list);
    list.sort((a, b) {
      num av = sortMap[a] ?? 0;
      num bv = sortMap[b] ?? 0;
      if (asc) {
        return av.compareTo(bv);
      } else {
        return bv.compareTo(av);
      }
    });
  }

  ///是否允许运行
  bool _allowRun = true;

  void clearInterrupt() {
    _allowRun = true;
  }

  void interrupt() {
    _allowRun = false;
  }

  void checkInterrupt() {
    if (!_allowRun) {
      throw FlutterError('当前已经被中断了');
    }
  }

  bool get hasInterrupted => !_allowRun;
}
