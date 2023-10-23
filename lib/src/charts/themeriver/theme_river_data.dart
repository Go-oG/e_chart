import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class ThemeRiverData extends RenderData<ThemeRiverAttr> {
  List<num> value;

  ThemeRiverData(
    this.value, {
    super.id,
    super.name,
  }) : super.attr(ThemeRiverAttr([], Area.empty));

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
    itemStyle = series.getItemStyle(context, this);
    borderStyle = series.getBorderStyle(context, this);
    var s = series.getLabelStyle(context, this);
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
