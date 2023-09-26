import 'package:e_chart/e_chart.dart';
import 'package:flutter/cupertino.dart';

class SankeyNode extends DataNode<Rect, BaseItemData> {
  final List<SankeyLink> outLinks; //以当前节点为源的输出边(source)
  final List<SankeyLink> inputLinks; //以当前节点为尾的输入边(target)
  num? fixedValue;
  num value = 0;

  ///标识坐标
  double left = 0;
  double top = 0;
  double right = 0;
  double bottom = 0;

  ///布局过程中的标示量
  ///列位置索引
  int layer = 0;

  ///图深度
  int deep = -1;

  ///图高度
  int graphHeight = 0;

  int index = 0;

  SankeyNode(
    ItemData data,
    this.outLinks,
    this.inputLinks,
    int dataIndex,
    AreaStyle itemStyle,
    LineStyle borderStyle,
    LabelStyle labelStyle,
  ) : super(data, dataIndex, 0, Rect.zero, itemStyle, borderStyle, labelStyle);

  @override
  bool contains(Offset offset) {
    return attr.contains2(offset);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    itemStyle.drawRect(canvas, paint, attr);
    borderStyle.drawRect(canvas, paint, attr);
  }

  @override
  void updateStyle(Context context, SankeySeries series) {
    itemStyle = series.getItemStyle(context, data, dataIndex, status) ?? AreaStyle.empty;
    borderStyle = series.getBorderStyle(context, data, dataIndex, status) ?? LineStyle.empty;
    var style = series.getLabelStyle(context, data, dataIndex, status) ?? LabelStyle.empty;
    label.updatePainter(style: style);
  }
}

class SankeyLink extends DataNode<Area, Pair<SankeyNode>> {
  final SankeyNode source;
  final SankeyNode target;
  final num value;
  int index = 0; // 链在数组中的索引位置
  /// 下面这两个位置都是中心点位置,需要注意
  double sourceY = 0; //在源结点的起始Y位置
  double targetY = 0; //在目标节点的起始Y坐标
  ///边宽度
  double width = 0;

  SankeyLink(
    this.source,
    this.target,
    this.value,
    int dataIndex,
    int groupIndex,
    AreaStyle itemStyle,
    LineStyle borderStyle,
    LabelStyle labelStyle,
  ) : super(Pair(source, target), dataIndex, groupIndex, Area([], []), itemStyle, borderStyle, labelStyle);

  void computeAreaPath(num smooth) {
    Offset sourceTop = Offset(source.right, sourceY);
    Offset sourceBottom = sourceTop.translate(0, width);

    Offset targetTop = Offset(target.left, targetY);
    Offset targetBottom = targetTop.translate(0, width);

    attr = Area([sourceTop, targetTop], [sourceBottom, targetBottom], upSmooth: smooth, downSmooth: smooth);
  }

  @override
  bool contains(Offset offset) {
    return attr.toPath().contains(offset);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    Path path = attr.toPath();
    itemStyle.drawPath(canvas, paint, path);
    borderStyle.drawPath(canvas, paint, path);
  }

  @override
  void updateStyle(Context context, SankeySeries series) {
    itemStyle =
        series.getLinkStyle(context, source.data, source.dataIndex, target.data, target.dataIndex, dataIndex, status);
    borderStyle = series.getLinkBorderStyle(
        context, source.data, source.dataIndex, target.data, target.dataIndex, dataIndex, status);
    var s = series.getLinkLabelStyle(
        context, source.data, source.dataIndex, target.data, target.dataIndex, dataIndex, status);
    label.updatePainter(style: s);
  }

  @override
  DataType get dataType => DataType.edgeData;
}
