import 'package:e_chart/e_chart.dart';
import 'package:flutter/painting.dart';

class ThemeRiverNode extends DataNode<ThemeRiverAttr, GroupData> {
  ThemeRiverNode(
    super.data,
    super.dataIndex,
    super.groupIndex,
    super.attr,
    super.itemStyle,
    super.borderStyle,
    super.labelStyle,
  ) {
    label.text = data.name ?? DynamicText.empty;
  }

  void update(List<Offset> pList, List<Offset> pList2, num smooth, Direction direction) {
    Area area;
    if (direction == Direction.vertical) {
      area = Area.vertical(pList, pList2, upSmooth: smooth, downSmooth: smooth);
    } else {
      area = Area(pList, pList2, upSmooth: smooth, downSmooth: smooth);
    }

    List<Offset> polygonList = [];
    polygonList.addAll(pList);
    polygonList.addAll(pList2.reversed);

    Offset o1 = polygonList.first;
    Offset o2 = polygonList.last;
    if (direction == Direction.horizontal) {
      Offset offset = Offset(o1.dx, (o1.dy + o2.dy) * 0.5);
      label.updatePainter(offset: offset, align: Alignment.centerLeft);
    } else {
      Offset offset = Offset((o1.dx + o2.dx) / 2, o1.dy);
      label.updatePainter(offset: offset, align: Alignment.topCenter);
    }
    attr = ThemeRiverAttr(polygonList, area);
  }

  Path get drawPath => attr.area.toPath();

  @override
  bool contains(Offset offset) {
    return attr.area.contains(offset);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    var path = attr.area.toPath();
    itemStyle.drawPath(canvas, paint, path);
    borderStyle.drawPath(canvas, paint, path);
    label.draw(canvas, paint);
  }

  @override
  void updateStyle(Context context, covariant ThemeRiverSeries series) {
    itemStyle = series.getAreaStyle(context, data, dataIndex, status);
    borderStyle = series.getBorderStyle(context, data, dataIndex, status);
    var s = series.getLabelStyle(context, data, dataIndex, status);
    label.updatePainter(style: s);
  }
}

class ThemeRiverAttr {
  static final empty = ThemeRiverAttr([], Area([], []));
  final List<Offset> polygonList;
  final Area area;
  int index = 0;

  ThemeRiverAttr(this.polygonList, this.area);
}
