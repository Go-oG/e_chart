// import 'package:e_chart/e_chart.dart';
// import 'package:e_chart_ext/src/model/graph/graph.dart';
// import 'package:flutter/cupertino.dart';
//
// import '../../model/graph/graph_data.dart';
// import '../graph_helper.dart';
//
// ///组合布局
// class ComboLayout extends GraphLayout {
//   ///用于最外部的布局
//   GraphLayout outerLayout;
//
//   ///用于划分节点
//   Fun2<Graph, List<Combo>> comboFun;
//
//   ComboLayout({
//     required this.outerLayout,
//     required this.comboFun,
//     super.nodeSize,
//     super.nodeSpaceFun,
//     super.sizeFun,
//     super.sort,
//     super.workerThread,
//   });
//
//   List<Combo> _comboList = [];
//
//   @override
//   void onLayout(LayoutType type) {
//     stopLayout();
//     clearInterrupt();
//     try {
//       if (workerThread) {
//         Future.doWhile(() {
//           runLayout(context, series.graph, width, height);
//           return false;
//         });
//       } else {
//         runLayout(context, series.graph, width, height);
//       }
//     } catch (e) {
//       debugPrint('异常:$e');
//     }
//   }
//
//   void runLayout(Context context, Graph graph, double width, double height) {
//     List<Combo> comboList = comboFun.call(graph);
//     if (comboList.isEmpty) {
//       return;
//     }
//     _comboList = comboList;
//
//     ///执行外部布局
//     Graph rootGraph = Graph(comboList);
//     bool first = true;
//     innerLayout() {
//       checkInterrupt();
//       notifyLayoutEnd();
//       each(comboList, (cn, i) {
//         if (!first) {
//           cn._lastOffset = Offset(cn.x, cn.y);
//           first = false;
//         }
//         _doInnerLayout(context, comboList[i]);
//       });
//     }
//
//     outerLayout.addListener(() {
//       innerLayout();
//     });
//
//     outerLayout.doLayout(rootGraph, Rect.fromLTWH(0, 0, width, height), LayoutType.none);
//   }
//
//   void _doInnerLayout(Context context, Combo combo) {
//     var x = combo.x;
//     var y = combo.y;
//     if (combo._lastOffset != null) {
//       Offset last = combo._lastOffset!;
//
//       ///计算偏移量
//       double dx = x - last.dx;
//       double dy = y - last.dx;
//       if (dx != 0 || dy != 0) {
//         for (var node in combo.graph.nodes) {
//           checkInterrupt();
//           node.x += dx;
//           node.y += dy;
//         }
//       }
//     }
//     Size size = getNodeSize(combo);
//     innerLayout() {
//       ///平移坐标节点
//       if (x != 0 || y != 0) {
//         for (var n in combo.graph.nodes) {
//           checkInterrupt();
//           n.x += combo.x;
//           n.y += combo.y;
//         }
//       }
//     }
//
//     combo.layout.addListener(() {
//       checkInterrupt();
//       innerLayout();
//       var c = combo.layout.value;
//       if (c == Command.layoutEnd) {
//         notifyLayoutEnd();
//       } else if (c == Command.layoutUpdate) {
//         notifyLayoutUpdate();
//       }
//     });
//     combo.layout.doLayout(
//       combo.graph,
//       Rect.fromLTWH(0, 0, size.width, size.height),
//       LayoutType.none,
//     );
//   }
//
//   @override
//   void stopLayout() {
//     interrupt();
//     for (var combo in _comboList) {
//       combo.layout.stopLayout();
//     }
//     super.stopLayout();
//   }
//
//   @override
//   void dispose() {
//     for (var combo in _comboList) {
//       combo.layout.dispose();
//     }
//     _comboList = [];
//     super.dispose();
//   }
//
//   @override
//   Offset getTranslationOffset(num width, num height) {
//     return Offset(width / 2, height / 2);
//   }
// }
//
// class Combo extends GraphNode {
//   final Graph graph;
//   final GraphLayout layout;
//   Offset? _lastOffset;
//
//   Combo(this.layout, this.graph, {super.id, super.label, super.data});
// }
