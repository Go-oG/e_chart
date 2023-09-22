import 'dart:ui';

import '../../../core/index.dart';
import '../../../functions.dart';

import '../model/graph.dart';
import '../model/graph_node.dart';
import '../graph_series.dart';

abstract class GraphLayout extends ChartNotifier<Command> {
  Fun2<List<GraphNode>, Map<GraphNode, num>>? sort;
  Fun2<GraphNode, num>? nodeSpaceFun;
  late final bool _workerThread;

  GraphLayout({
    this.nodeSpaceFun,
    this.sort,
    bool workerThread = false,
  }) : super(Command.none) {
    _workerThread = workerThread;
  }

  void doLayout(Graph graph, GraphLayoutParams params, LayoutType type) {
    if (_workerThread) {
      Future(() {
        onLayout(graph, params, type);
        notifyLayoutUpdate();
      });
    } else {
      onLayout(graph, params, type);
    }
  }

  void onLayout(Graph graph, GraphLayoutParams params, LayoutType type);

  void stopLayout() {}

  Offset getTranslation()=>Offset.zero;

  ///获取节点间距
  num getNodeSpace(GraphNode node) {
    return nodeSpaceFun?.call(node) ?? 8;
  }

  void sortNode(Graph graph, List<GraphNode> list, [bool asc = false]) {
    if (sort == null) {
      return;
    }
    Map<GraphNode, num> sortMap = sort!.call(list);
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

  void notifyLayoutUpdate() {
    value = Command.layoutUpdate;
  }

  void notifyLayoutEnd() {
    value = Command.layoutEnd;
  }
}

class GraphLayoutParams {
  final Context context;
  final GraphSeries series;
  final Rect boxBound;
  final Rect globalBoxBound;
  final double width;
  final double height;

  GraphLayoutParams(this.context, this.series, this.boxBound, this.globalBoxBound, this.width, this.height);
}