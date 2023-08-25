import 'package:e_chart/e_chart.dart';
import 'package:flutter/cupertino.dart';

class SankeyNode with ViewStateProvider{
  final List<SankeyLink> outLinks; //已当前节点为源的输出边(source)
  final List<SankeyLink> inputLinks; // 已当前节点为尾的输入边(target)
  final ItemData data;
  double? value; //节点数值(传入链接的总和)

  ///标识坐标
  double left = 0; //节点left 坐标
  double top = 0; // 节点top 坐标
  double right = 0; // 节点 right 坐标
  double bottom = 0; // 节点bottom坐标
  Rect rect=Rect.zero;

  ///布局过程中的标示量
  int heightIndex = 0;
  int layerIndex = 0;
  int depth = -1; //图深度
  int index = 0;

  bool select=false;
  double? colorAlpha;
  SankeyNode(this.data, this.outLinks, this.inputLinks);

  @override
  int get hashCode {
    return data.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is SankeyNode && other.data == data;
  }
}

class SankeyLink with ViewStateProvider{
  final SankeyNode source;
  final SankeyNode target;
  final double value;

  int index = 0; // 链在数组中的索引位置

  /// 下面这两个位置都是中心点位置,需要注意
  double sourceY = 0; //在源结点的起始Y位置
  double targetY = 0; // 在目标节点的垂直结束位置

  double width = 0;

  /// 绘制相关所需的坐标点数据
  Offset leftTop = Offset.zero;
  Offset rightTop = Offset.zero;
  Offset leftBottom = Offset.zero;
  Offset rightBottom = Offset.zero;

  late Path path;

  bool select=false;
  double? colorAlpha;

  SankeyLink(this.source, this.target, this.value);
}
