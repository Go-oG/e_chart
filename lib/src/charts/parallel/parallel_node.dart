import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class ParallelNode extends DataNode<List<SymbolNode>, ParallelGroup> {
  bool connectNull = true;
  Rect? clipRect;
  late Path path;

  ParallelNode(
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
    return path.contains(offset);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    borderStyle.drawPath(canvas, paint, path, drawDash: false, needSplit: false);
  }

  @override
  void onDrawSymbol(CCanvas canvas, Paint paint) {
    for (var ele in attr) {
      var cr = clipRect;
      if (cr != null && !cr.contains2(ele.center)) {
        break;
      }
      ele.onDraw(canvas, paint);
    }
  }

  @override
  void updateStyle(Context context, ParallelSeries series) {
    var old = borderStyle;
    itemStyle = AreaStyle.empty;
    borderStyle = series.getBorderStyle(context, data, dataIndex, status);
    label.style = series.getLabelStyle(context, data, dataIndex, status);
    if (old.changeEffect(borderStyle)) {
      updatePath(context, series);
    }
  }

  void updatePath(Context context, ParallelSeries series) {
    List<List<Offset>> ol = [];
    if (connectNull) {
      List<Offset> tmp = [];
      for (var symbol in attr) {
        tmp.add(symbol.center);
      }
      if (tmp.length >= 2) {
        ol.add(tmp);
      }
    } else {
      List<List<SymbolNode>> sl = splitListForNull(attr);
      ol = List.from(sl.map((e) => List.from(e.map((e) => e.center))));
    }
    var path = Path();
    for (var list in ol) {
      if (list.length < 2) {
        continue;
      }
      var first = list.first;
      path.moveTo(first.dx, first.dy);
      if (borderStyle.smooth > 0) {
        Line(list, smooth: borderStyle.smooth).appendToPathEnd(path);
      } else {
        for (int i = 1; i < list.length; i++) {
          path.lineTo(list[i].dx, list[i].dy);
        }
      }
    }
    this.path = path;
  }
}
