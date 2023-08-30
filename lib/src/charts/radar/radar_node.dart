import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class RadarGroupNode extends DataNode<Path, GroupData> {
  static final Path emptyPath = Path();
  final List<RadarNode> nodeList;

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
  void onDraw(Canvas canvas, Paint paint) {
    if (!data.show) {
      return;
    }
    Path? path = pathOrNull;
    if (path != null) {
      itemStyle.drawPath(canvas, paint, path);
      borderStyle.drawPath(canvas, paint, path, drawDash: true, needSplit: false);
    }

    each(nodeList, (node, p1) {
      node.onDraw(canvas, paint);
    });
  }
}

class RadarNode extends DataNode<Offset, ItemData> {
  final RadarGroupNode parent;

  ChartSymbol? symbol;

  RadarNode(
    this.parent,
    this.symbol,
    super.data,
    super.dataIndex,
    super.groupIndex,
    super.attr,
    super.itemStyle,
    super.borderStyle,
    super.labelStyle,
  );

  @override
  bool contains(Offset offset) {
    var sb = symbol;
    if (sb == null) {
      return false;
    }
    return sb.internal2(attr, sb.size, offset);
  }

  @override
  void onDraw(Canvas canvas, Paint paint) {
    var sb = symbol;
    if (sb == null) {
      return;
    }
    sb.draw(canvas, paint, attr);
  }
}
