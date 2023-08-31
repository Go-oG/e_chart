import 'dart:ui';

import 'package:e_chart/e_chart.dart';

abstract class TreemapLayout extends LayoutHelper<TreeMapSeries> {
  TreemapLayout() : super.lazy();

  TreeMapNode? _rootNode;

  TreeMapNode? get rootNode => _rootNode;

  @override
  void doLayout(Rect boxBound, Rect globalBoxBound, LayoutType type) {
    this.boxBound = boxBound;
    this.globalBoxBound = globalBoxBound;
    int i = 0;
    _rootNode = toTree<TreeData, Rect, TreeMapNode>(
      series.data,
      (p0) => p0.children,
      (p0, p1) {
        var node = TreeMapNode(p0, p1, i, Rect.zero, AreaStyle.empty, LineStyle.empty, LabelStyle.empty);
        i += 1;
        return node;
      },
    );
    _rootNode!.sum((p0) => p0.data.value);
    _rootNode!.removeWhere((p0) => p0.value <= 0, true);
    _rootNode!.computeHeight();
    _rootNode!.attr = Rect.fromLTWH(0, 0, width, height);
    onLayout2(_rootNode!, type);
  }

  @override
  void onLayout(LayoutType type) {
    throw ChartError("不应该调用该方法");
  }

  void onLayout2(TreeMapNode root, LayoutType type);

  @override
  SeriesType get seriesType => SeriesType.treemap;
}

///计算所有子节点的比例和
///因为(parent节点的数据>=children的数据和)
///因此会出现无法占满的情况，因此在treeMap中需要归一化
double computeAllRatio(List<TreeMapNode> list) {
  double area = 0;
  for (var element in list) {
    area += element.areaRatio;
  }
  return area;
}
