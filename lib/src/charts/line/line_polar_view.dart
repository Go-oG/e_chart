import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/common/stack/polar/polar_view.dart';
import 'package:e_chart/src/charts/line/helper/polar_helper.dart';

import 'helper/line_helper.dart';
import 'line_node.dart';

class LinePolarView extends PolarView<StackItemData, LineGroupData, LineSeries, LinePolarHelper> {
  late LineHelper helper;

  LinePolarView(super.context, super.series);

  @override
  void onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec) {
    layoutHelper.doMeasure(widthSpec, heightSpec);
    super.onMeasure(widthSpec, heightSpec);
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
    Rect clipRect = selfViewPort;
    double t = helper.getAnimatorPercent();
    if (t != 1) {
      clipRect = Rect.fromLTWH(clipRect.left, clipRect.top, clipRect.width * t, clipRect.height);
    }
    var lineList = helper.getLineNodeList();
    canvas.save();
    canvas.clipRect(clipRect);
    each(lineList, (lineNode, p1) {
      drawArea(canvas, lineNode, clipRect);
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

    var lineList = helper.getLineNodeList();
    each(lineList, (lineNode, p1) {
      drawSymbol(canvas, lineNode);
    });
    drawMakeLineAndMarkPoint(canvas, null);
  }

  void drawLine(CCanvas canvas, LineNode lineNode, Rect clipRect) {
    var path = lineNode.path;
    if (path == null) {
      return;
    }
    lineNode.data.borderStyle.drawPath(canvas, mPaint, path, drawDash: false);
  }

  void drawArea(CCanvas canvas, LineNode lineNode, Rect clipRect) {
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
  }

  @override
  LinePolarHelper buildLayoutHelper(var oldHelper) {
    oldHelper?.clearRef();
    var h = LinePolarHelper(context, this, series);
    helper = h;
    return h;
  }
}
