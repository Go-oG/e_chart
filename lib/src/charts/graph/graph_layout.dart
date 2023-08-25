import 'dart:math' as m;

import 'package:flutter/widgets.dart';

import '../../core/layout_helper.dart';
import '../../functions.dart';
import '../../model/index.dart';
import 'graph_series.dart';

abstract class GraphLayout extends LayoutHelper<GraphSeries> {
  ///是否在工作线程中布局
  bool workerThread;

  ///节点大小获取优先级: Node.size>sizeFun>>nodeSize>default（8）
  Size? nodeSize;
  Fun2<GraphNode, Size>? sizeFun;
  Fun3<Graph, List<GraphNode>, Map<GraphNode, num>>? sort;
  Fun2<GraphNode, num>? nodeSpaceFun;

  GraphLayout({
    this.nodeSize,
    this.sizeFun,
    this.nodeSpaceFun,
    this.sort,
    this.workerThread = false,
  }) : super.lazy();

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

  @override
  SeriesType get seriesType => SeriesType.graph;

  ///给定一个节点返回节点的大小
  Size getNodeSize(GraphNode node) {
    if (sizeFun != null) {
      return sizeFun!.call(node);
    }

    if (nodeSize != null) {
      return nodeSize!;
    }

    Size size = Size(node.width, node.height);
    if (size.width <= 0 || size.height <= 0) {
      size = const Size.square(8);
    }
    return size;
  }

  ///获取节点的半径大小
  double getNodeRadius(GraphNode node, [bool maxValue = false]) {
    Size size = getNodeSize(node);
    if (maxValue) {
      return m.max(size.width, size.height) * 0.5;
    } else {
      return m.min(size.width, size.height) * 0.5;
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

  ///返回Graph应该平移的偏移量
  Offset getTranslationOffset(num width, num height) {
    return Offset.zero;
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

  @override
  void dispose() {
    interrupt();
    super.dispose();
  }
}
