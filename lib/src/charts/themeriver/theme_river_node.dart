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
  );

  void update(List<Offset> pList, List<Offset> pList2, bool smooth, Direction direction) {
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
    TextDrawInfo config;
    if (direction == Direction.horizontal) {
      Offset offset = Offset(o1.dx, (o1.dy + o2.dy) * 0.5);
      config = TextDrawInfo(offset, align: Alignment.centerLeft);
    } else {
      Offset offset = Offset((o1.dx + o2.dx) / 2, o1.dy);
      config = TextDrawInfo(offset, align: Alignment.topCenter);
    }
    attr = ThemeRiverAttr(polygonList, area, config);
  }

  Path get drawPath => attr.area.toPath(true);

  @override
  bool contains(Offset offset) {
    return attr.area.contains(offset);
  }

  @override
  void onDraw(Canvas canvas, Paint paint) {
    var path = attr.area.toPath(true);
    itemStyle.drawPath(canvas, paint, path);
    borderStyle.drawPath(canvas, paint, path);
    var label = data.label;
    var config = attr.textConfig;
    if (config == null || label == null || label.isEmpty) {
      return;
    }
    labelStyle.draw(canvas, paint, label, config);
  }

  @override
  void updateStyle(Context context, covariant ThemeRiverSeries series) {
    itemStyle = series.getAreaStyle(context, data, dataIndex, status) ?? AreaStyle.empty;
    borderStyle = series.getBorderStyle(context, data, dataIndex, status) ?? LineStyle.empty;
    labelStyle = series.getLabelStyle(context, data, dataIndex, status) ?? LabelStyle.empty;
  }
}

class ThemeRiverAttr {
  static final empty = ThemeRiverAttr([], Area([], []), null);
  final List<Offset> polygonList;
  final Area area;
  final TextDrawInfo? textConfig;
  int index = 0;

  ThemeRiverAttr(this.polygonList, this.area, this.textConfig);
}
