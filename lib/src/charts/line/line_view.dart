import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/line/helper/grid_helper.dart';
import 'package:e_chart/src/charts/line/helper/polar_helper.dart';

import 'helper/line_helper.dart';
import 'line_node.dart';

class LineView extends CoordChildView<LineSeries, StackHelper<StackItemData, LineGroupData, LineSeries>>
    with GridChild, PolarChild {
  late LineHelper helper;

  LineView(super.series);

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    layoutHelper.doMeasure(parentWidth, parentHeight);
    return super.onMeasure(parentWidth, parentHeight);
  }

  @override
  void onDraw(CCanvas canvas) {
    if (series.coordType == CoordType.polar) {
      drawForPolar(canvas);
    } else {
      drawForGrid(canvas);
    }
  }

  void drawForGrid(CCanvas canvas) {
    Offset offset = layoutHelper.getTranslation();
    Rect clipRect = Rect.fromLTWH(offset.dx.abs(), 0, width, height);
    double t = helper.getAnimatorPercent();
    if (t != 1) {
      clipRect = Rect.fromLTWH(clipRect.left, clipRect.top, clipRect.width * t, clipRect.height);
    }
    var lineList = helper.getLineNodeList();
    canvas.save();
    canvas.translate(offset.dx, 0);
    canvas.clipRect(clipRect);
    each(lineList, (lineNode, p1) {
      drawArea(canvas, lineNode, clipRect, offset);
      drawLine(canvas, lineNode, clipRect);
      drawSymbol(canvas, lineNode);
    });
    canvas.restore();
    drawMakeLineAndMarkPoint(canvas, clipRect);
  }

  void drawForPolar(CCanvas canvas) {
    double t = helper.getAnimatorPercent();
    if (t == 0) {
      return;
    }
    Offset offset = layoutHelper.getTranslation();
    var lineList = helper.getLineNodeList();

    canvas.save();
    canvas.translate(offset.dx, 0);
    each(lineList, (lineNode, p1) {
      drawSymbol(canvas, lineNode);
    });
    canvas.restore();
    drawMakeLineAndMarkPoint(canvas, null);
  }

  void drawLine(CCanvas canvas, LineNode lineNode, Rect clipRect) {
    var path = lineNode.path;
    if (path == null) {
      return;
    }
    lineNode.data.borderStyle.drawPath(canvas, mPaint, path, drawDash: false);
  }

  void drawArea(CCanvas canvas, LineNode lineNode, Rect clipRect, Offset scroll) {
    var path = lineNode.areaPath;
    if (path == null) {
      return;
    }
    lineNode.data.itemStyle.drawPath(canvas, mPaint, path);
  }

  void drawSymbol(CCanvas canvas, LineNode lineNode) {
    var symbol = lineNode.symbol;
    if (symbol == null) {
      return;
    }
    symbol.draw(canvas, mPaint, lineNode.data.position);
  }

  /// 绘制标记线和点
  void drawMakeLineAndMarkPoint(CCanvas canvas, Rect? clipRect) {
    var markLineFun = series.markLineFun;
    var markPointFun = series.markPointFun;
    var markPoint = series.markPoint;
    var markLine = series.markLine;
    if (markLineFun == null && markPointFun == null && markPoint == null && markLine == null) {
      return;
    }
    var offset = layoutHelper.getTranslation();
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    if (markLineFun != null || markLine != null) {
      each(layoutHelper.markLineList, (ml, i) {
        ml.line.draw(canvas, mPaint, ml.start.offset, ml.end.offset);
      });
    }
    each(layoutHelper.markPointList, (mp, i) {
      if (clipRect != null && clipRect.contains(mp.offset)) {
        mp.markPoint.draw(canvas, mPaint, mp.offset);
      }
    });
    canvas.restore();
  }

  @override
  int getAxisDataCount(int axisIndex, bool isXAxis) {
    int count = 0;
    for (var data in series.data) {
      if (data.data.length > count) {
        count = data.data.length;
      }
    }
    return count;
  }

  @override
  List<dynamic> getAxisExtreme(int axisIndex, bool isXAxis) {
    return layoutHelper.getAxisExtreme(axisIndex, isXAxis);
  }

  @override
  List getViewPortAxisExtreme(int axisIndex, bool isXAxis, BaseScale scale) {
    return layoutHelper.getViewPortAxisExtreme(axisIndex, isXAxis, scale);
  }

  @override
  List getPolarExtreme(bool radius) {
    if (radius) {
      return getAxisExtreme(0, true);
    }
    return getAxisExtreme(0, false);
  }

  @override
  StackHelper<StackItemData, LineGroupData, LineSeries> buildLayoutHelper(var oldHelper) {
    oldHelper?.clearRef();
    if (series.coordType == CoordType.polar) {
      var h = LinePolarHelper(context, this, series);
      helper = h;
      return h;
    } else {
      var h = LineGridHelper(context, this, series);
      helper = h;
      return h;
    }
  }

  @override
  int allocateDataIndex(int index) {
    each(series.data, (p0, p1) {
      p0.styleIndex = index + p1;
    });
    return series.data.length;
  }

}
