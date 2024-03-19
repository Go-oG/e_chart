import 'dart:ui';

import '../../../core/index.dart';
import '../../../functions.dart';

import '../model/graph.dart';
import '../graph_data.dart';
import '../graph_series.dart';

abstract class GraphLayout extends ChartNotifier<Command> {
  Fun2<List<GraphData>, Map<GraphData, num>>? sort;
  Fun2<GraphData, num>? nodeSpaceFun;
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

  Offset getTranslation() => Offset.zero;

  ///获取节点间距
  num getNodeSpace(GraphData node) {
    return nodeSpaceFun?.call(node) ?? 8;
  }

  void sortNode(Graph graph, List<GraphData> list, [bool asc = false]) {
    if (sort == null) {
      return;
    }
    Map<GraphData, num> sortMap = sort!.call(list);
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

  GraphLayoutParams(this.context, this.series, this.boxBound, this.globalBoxBound);

  double get width {
    return boxBound.width;
  }

  double get height {
    return boxBound.height;
  }
}
