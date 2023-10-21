import 'package:e_chart/e_chart.dart';
import 'package:flutter/cupertino.dart';

 class SankeyData extends RenderData<SankeyAttr> {
  num? fixedValue;

  SankeyData(
    this.fixedValue, {
    super.id,
    super.name,
  }) : super.attr(SankeyAttr());

  @override
  bool contains(Offset offset) {
    return attr.rect.contains2(offset);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    itemStyle.drawRect(canvas, paint, attr.rect);
    borderStyle.drawRect(canvas, paint, attr.rect);
  }

  @override
  void updateStyle(Context context, SankeySeries series) {
    itemStyle = series.getItemStyle(context, this) ?? AreaStyle.empty;
    borderStyle = series.getBorderStyle(context, this) ?? LineStyle.empty;
    var style = series.getLabelStyle(context, this) ?? LabelStyle.empty;
    label.updatePainter(style: style);
  }
}

class SankeyAttr {
  num value = 0;
  List<SankeyLinkData> outLinks = []; //以当前节点为源的输出边(source)
  List<SankeyLinkData> inputLinks = []; //以当前节点为尾的输入边(target)

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

  Rect rect = Rect.zero;
}

class SankeyLinkData extends RenderData<SankeyLinkAttr> {
  SankeyData source;
  SankeyData target;
  num value;

  SankeyLinkData(
    this.source,
    this.target,
    this.value,
  ) : super.attr(SankeyLinkAttr());

  void computeAreaPath(num smooth) {
    Offset sourceTop = Offset(source.attr.right, attr.sourceY);
    Offset sourceBottom = sourceTop.translate(0, attr.width);

    Offset targetTop = Offset(target.attr.left, attr.targetY);
    Offset targetBottom = targetTop.translate(0, attr.width);

    attr.area = Area([sourceTop, targetTop], [sourceBottom, targetBottom], upSmooth: smooth, downSmooth: smooth);
  }

  @override
  bool contains(Offset offset) {
    return attr.area.contains(offset);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    Path path = attr.area.toPath();
    itemStyle.drawPath(canvas, paint, path);
    borderStyle.drawPath(canvas, paint, path);
  }

  @override
  void updateStyle(Context context, SankeySeries series) {
    itemStyle = series.getLinkStyle(context, this);
    borderStyle = series.getLinkBorderStyle(context, this);
    var s = series.getLinkLabelStyle(context, this);
    label.updatePainter(style: s);
  }

  @override
  DataType get dataType => DataType.edgeData;
}

class SankeyLinkAttr {
  Area area = Area.empty;
  int index = 0; // 链在数组中的索引位置
  /// 下面这两个位置都是中心点位置,需要注意
  double sourceY = 0; //在源结点的起始Y位置
  double targetY = 0; //在目标节点的起始Y坐标
  ///边宽度
  double width = 0;
}
