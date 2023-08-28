import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import 'parallel_helper.dart';

//平行坐标系
class ParallelView extends CoordChildView<ParallelSeries, ParallelHelper> implements ParallelChild {
  ParallelView(super.series);

  @override
  void onDraw(Canvas canvas) {
    var direction = layoutHelper.findParallelCoord().direction;
    Rect clipRect;
    var ap = layoutHelper.animationProcess;
    if (direction == Direction.horizontal) {
      clipRect = Rect.fromLTWH(0, 0, width * ap, height);
    } else {
      clipRect = Rect.fromLTWH(0, 0, width, height * ap);
    }
    canvas.save();
    canvas.clipRect(clipRect);
    var nodeList = layoutHelper.nodeList;
    for (var ele in nodeList) {
      LineStyle? style = getLineStyle(ele);
      if (style == null) {
        continue;
      }
      var optPath = ele.attr.getPath(style.smooth, series.connectNull, style.dash);
      for (var path in optPath.segmentList) {
        if (!path.bound.overlaps(clipRect)) {
          continue;
        }
        style.drawPath(canvas, mPaint, path.path, drawDash: false, needSplit: false);
      }
    }
    if (series.symbolFun != null) {
      for (var ele in nodeList) {
        var symbolStyle = getSymbol(ele);
        if (symbolStyle == null) {
          continue;
        }
        for (var symbol in ele.symbolList) {
          if (symbol.data == null) {
            continue;
          }
          if (!clipRect.contains2(symbol.attr)) {
            break;
          }
          symbolStyle.draw(canvas, mPaint, symbol.attr);
        }
      }
    }
    canvas.restore();
  }

  @override
  List<dynamic> getDimDataSet(int dim) {
    List<dynamic> list = [];
    for (var group in series.data) {
      if (dim < group.data.length) {
        var data = group.data[dim];
        list.add(data);
      }
    }
    return list;
  }

  @override
  int get parallelIndex => series.parallelIndex;

  @override
  ParallelHelper buildLayoutHelper() {
    return ParallelHelper(context, series);
  }

  LineStyle? getLineStyle(ParallelNode node) {
    var fun = series.styleFun;
    if (fun != null) {
      return fun.call(node.data, node.dataIndex, node.status);
    }
    var theme = context.option.theme;
    var ptheme = theme.parallelTheme;
    num w = ptheme.lineWidth;
    if (w <= 0) {
      w = 1;
    }
    Color color;
    int index = node.dataIndex;
    if (ptheme.colors.isNotEmpty) {
      color = ptheme.colors[index % ptheme.colors.length];
    } else {
      color = theme.getColor(index);
    }
    return LineStyle(color: color, width: w, smooth: ptheme.smooth, dash: ptheme.dash);
  }

  ChartSymbol? getSymbol(ParallelNode node) {
    var fun = series.symbolFun;
    if (fun != null) {
      return fun.call(node.data, node.dataIndex, node.status);
    }
    return null;
  }
}
