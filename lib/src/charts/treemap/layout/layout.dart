import 'dart:ui';

import 'package:e_chart/e_chart.dart';

abstract class TreemapLayout extends LayoutHelper<TreeMapSeries> {
  TreemapLayout() : super.lazy();

  TreeMapData? _rootNode;

  TreeMapData? get rootNode => _rootNode;

  @override
  void doLayout(Rect boxBound, Rect globalBoxBound, LayoutType type) {
    this.boxBound = boxBound;
    this.globalBoxBound = globalBoxBound;
    _rootNode = series.data;
    initData(series.data);
    _rootNode!.attr = Rect.fromLTWH(0, 0, width, height);
    onLayout2(_rootNode!, type);
  }

  void initData(TreeMapData root) {
    root.removeWhere((p0) => p0.value <= 0, true);
    root.each((node, index, startNode) {
      node.dataIndex = index;
      return false;
    });
    root.sum((p0) => p0.value);
    root.computeHeight();
    int maxDeep = root.height;
    root.each((node, index, startNode) {
      node.maxDeep = maxDeep;
      return false;
    });
  }

  @override
  void onLayout(LayoutType type) {
    throw ChartError("不应该调用该方法");
  }

  void onLayout2(TreeMapData root, LayoutType type);
}

///计算所有子节点的比例和
///因为(parent节点的数据>=children的数据和)
///因此会出现无法占满的情况，因此在treeMap中需要归一化
double computeAllRatio(List<TreeMapData> list) {
  double area = 0;
  for (var element in list) {
    area += element.areaRatio;
  }
  return area;
}
