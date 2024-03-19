import 'package:e_chart/e_chart.dart';
import 'package:flutter/cupertino.dart';

class SankeyData extends RenderData<SankeyAttr> {
  num? _fixedValue;

  num? get fixedValue => _fixedValue;

  set fixedValue(num? v) {
    if (v != null && v <= 0) {
      throw ChartError("fixValue 必须大于0");
    }
    _fixedValue = v;
  }

  SankeyData({
    super.id,
    super.name,
    num? fixedValue,
  }) {
    if (fixedValue != null) {
      if (fixedValue <= 0) {
        throw ChartError("fixValue 必须大于0");
      }
      _fixedValue = fixedValue;
    }
  }

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

  @override
  String toString() {
    return "$runtimeType(${fixedValue?.toStringAsFixed(2)}) ";
  }

  @override
  SankeyAttr initAttr() => SankeyAttr();
}

class SankeyAttr {
  num value = 0;
  List<SankeyLink> outLinks = []; //以当前节点为源的输出边(source)
  List<SankeyLink> inputLinks = []; //以当前节点为尾的输入边(target)

  ///标识坐标
  double _left = 0;

  double get left => _left;

  set left(double v) {
    _left = v;
    if (_left.isNaN || _left.isInfinite) {
      throw ChartError('Left Error');
    }
  }

  double _top = 0;

  double get top => _top;

  set top(double v) {
    _top = v;
    if (_top.isNaN || _top.isInfinite) {
      throw ChartError('Top Error');
    }
  }

  double _right = 0;

  double get right => _right;

  set right(double v) {
    _right = v;
    if (_right.isNaN || _right.isInfinite) {
      throw ChartError('Right Error');
    }
  }

  double _bottom = 0;

  double get bottom => _bottom;

  set bottom(double v) {
    _bottom = v;
    if (_bottom.isNaN || _bottom.isInfinite) {
      throw ChartError('Bottom Error');
    }
  }

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

class SankeyLink extends RenderData<SankeyLinkAttr> {
  SankeyData source;
  SankeyData target;
  num value;

  SankeyLink(
    this.source,
    this.target,
    this.value,
  );

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

  @override
  SankeyLinkAttr initAttr() => SankeyLinkAttr();
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
