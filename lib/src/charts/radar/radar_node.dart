import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class RadarGroupNode extends DataNode<Path, GroupData> {
  static final Path emptyPath = Path();
  final List<RadarNode> nodeList;
  double scale = 1;
  Offset center = Offset.zero;

  RadarGroupNode(
    this.nodeList,
    super.data,
    super.dataIndex,
    super.groupIndex,
    super.attr,
    super.itemStyle,
    super.borderStyle,
    super.labelStyle,
  );

  Path? get pathOrNull {
    if (attr == emptyPath) {
      return null;
    }
    return attr;
  }

  Path get path {
    if (attr == emptyPath) {
      attr = buildPath();
    }
    return attr;
  }

  void updatePath() {
    attr = buildPath();
  }

  Path buildPath() {
    Path path = Path();
    for (int i = 0; i < nodeList.length; i++) {
      RadarNode node = nodeList[i];
      if (i == 0) {
        path.moveTo(node.attr.dx, node.attr.dy);
      } else {
        path.lineTo(node.attr.dx, node.attr.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool contains(Offset offset) {
    return attr.contains(offset);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    if (!data.show) {
      return;
    }

    Path? path = pathOrNull;
    if (path != null) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.scale(scale);
      canvas.translate(-center.dx, -center.dy);
      itemStyle.drawPath(canvas, paint, path);
      borderStyle.drawPath(canvas, paint, path, drawDash: true, needSplit: false);
      canvas.restore();
    }

    each(nodeList, (node, p1) {
      node.onDraw(canvas, paint);
    });
  }

  @override
  void updateStyle(Context context, covariant RadarSeries series) {
    itemStyle = series.getAreaStyle(context, data, dataIndex, status) ?? AreaStyle.empty;
    borderStyle = series.getLineStyle(context, data, dataIndex, status) ?? LineStyle.empty;
    label.style=LabelStyle.empty;
    label.updatePainter();
  }
}

class RadarNode extends DataNode<Offset, ItemData> {
  final RadarGroupNode parent;

  ChartSymbol? symbol;

  RadarNode(
    this.parent,
    this.symbol,
    ItemData data,
    int dataIndex,
    int groupIndex,
  ) : super.empty(data, dataIndex, groupIndex, Offset.zero);

  @override
  bool contains(Offset offset) {
    var sb = symbol;
    if (sb == null) {
      return false;
    }
    return sb.contains(attr, offset);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    var sb = symbol;
    if (sb == null) {
      return;
    }
    sb.draw(canvas, paint, attr);
  }

  @override
  void updateStyle(Context context, covariant RadarSeries series) {
    symbol = series.getSymbol(context, data, parent.data, dataIndex, status);
  }
}
