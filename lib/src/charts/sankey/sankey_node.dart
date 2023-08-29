import 'package:e_chart/e_chart.dart';
import 'package:flutter/cupertino.dart';

class SankeyNode extends DataNode<Rect, BaseItemData> {
  final List<SankeyLink> outLinks; //已当前节点为源的输出边(source)
  final List<SankeyLink> inputLinks; // 已当前节点为尾的输入边(target)
  num? fixedValue;
  num value = 0;

  ///标识坐标
  double left = 0;
  double top = 0;
  double right = 0;
  double bottom = 0;
  Rect rect = Rect.zero;

  ///布局过程中的标示量
  ///列位置索引
  int layer = 0;

  ///图深度
  int deep = -1;

  ///图高度
  int graphHeight = 0;

  int index = 0;

  SankeyNode(ItemData data, this.outLinks, this.inputLinks, int dataIndex) : super(data, dataIndex, 0, Rect.zero);
}

class SankeyLink with ViewStateProvider {
  final SankeyNode source;
  final SankeyNode target;
  final num value;
  int index = 0; // 链在数组中的索引位置
  /// 下面这两个位置都是中心点位置,需要注意
  double sourceY = 0; //在源结点的起始Y位置
  double targetY = 0; //在目标节点的起始Y坐标
  ///边宽度
  double width = 0;
  late Area area;

  SankeyLink(this.source, this.target, this.value);

  void computeAreaPath(bool smooth) {
    Offset sourceTop = Offset(source.right, sourceY);
    Offset sourceBottom = sourceTop.translate(0, width);

    Offset targetTop = Offset(target.left, targetY);
    Offset targetBottom = targetTop.translate(0, width);

    area = Area([sourceTop, targetTop], [sourceBottom, targetBottom], upSmooth: smooth, downSmooth: smooth);
  }
}
