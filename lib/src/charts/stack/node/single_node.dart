import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

/// 不可再分的最小绘制单元
/// 其用于极坐标系和二维坐标系下的节点位置表示
class SingleNode<T extends StackItemData, P extends StackGroupData<T>> extends DataNode<SingleAttr, WrapData<T, P>> {
  final CoordType coord;
  final ColumnNode<T, P> parentNode;

  ///标识是否是一个堆叠数据
  final bool stack;

  SingleNode(
    this.coord,
    this.parentNode,
    WrapData<T, P> wrap,
    this.stack,
  ) : super.empty(wrap, wrap.dataIndex, wrap.groupIndex, SingleAttr()) {
    assertCheck(coord == CoordType.grid || coord == CoordType.polar, "Coord must is Grid or Polar");
  }

  ///记录数据的上界和下界
  num _up = 0;

  num get up => _up;

  set up(num u) {
    _up = u;
    data.data?.stackUp = u;
  }

  num _down = 0;

  num get down => _down;

  set down(num d) {
    _down = d;
    data.data?.stackDown = d;
  }

  T? get originData => data.data;

  P get parent => data.parent;

  Arc get arc => attr.arc;

  set arc(Arc a) => attr.arc = a;

  Rect get rect => attr.rect;

  set rect(Rect r) => attr.rect = r;

  Offset get position => attr.position;

  set position(Offset o) => attr.position = o;

  @override
  bool contains(Offset offset) {
    return false;
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    if (coord == CoordType.grid) {
      itemStyle.drawRect(canvas, paint, rect, attr.corner);
      borderStyle.drawRect(canvas, paint, rect, attr.corner);
      return;
    }
    itemStyle.drawPath(canvas, paint, arc.toPath());
    borderStyle.drawPath(canvas, paint, arc.toPath(), drawDash: true, needSplit: false);
  }

  void onDrawText(CCanvas canvas, Paint paint) {
    if (originData == null) {
      return;
    }
    var style = labelStyle;
    var config = labelConfig;
    var label = this.label;
    if (!style.show || config == null || label.isEmpty) {
      return;
    }
    style.draw(canvas, paint, label, config);
  }

  @override
  void updateStyle(Context context, covariant StackSeries<T, P> series) {
    itemStyle = series.getAreaStyle(context, data.data, data.parent, status);
    borderStyle = series.getLineStyle(context, data.data, data.parent, status);
    labelStyle = series.getLabelStyle(context, data.data, data.parent, status);
  }

  void updateTextPosition(Context context, covariant StackSeries<T, P> series) {
    var align = series.getLabelAlign(context, data.data, data.parent, status);
    if (coord == CoordType.polar) {
      labelConfig = align.convert2(arc, labelStyle, series.direction);
    } else {
      labelConfig = align.convert(rect, labelStyle, series.direction);
    }
    label = formatData(series, attr.dynamicLabel ?? data.data?.stackUp);
  }

  DynamicText formatData(StackSeries<T, P> series, dynamic data) {
    if (data == null) {
      return DynamicText.empty;
    }
    if (data is DynamicText) {
      return data;
    }
    var fun = series.labelFormatFun;
    if (fun != null) {
      return fun.call(data, this.data.parent, status) ?? DynamicText.empty;
    }
    if (data is String) {
      return DynamicText(data);
    }
    if (data is DateTime) {
      return data.toString().toText();
    }
    if (data is num) {
      return DynamicText.fromString(formatNumber(data, 2));
    }
    return data.toString().toText();
  }
}

class SingleAttr {
  ///只在二维坐标系下使用
  Rect rect = Rect.zero;
  Corner? corner;

  ///只在极坐标系下使用
  Arc arc = Arc();

  ///通用的节点位置，一般只有折线图和散点图使用
  Offset position = Offset.zero;

  ///动态数据标签(一般使用在动态排序中)
  dynamic dynamicLabel;
}
