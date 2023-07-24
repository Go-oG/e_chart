import 'dart:ui';
import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/component/theme/chart/line_theme.dart';

import 'layout_helper.dart';
import 'line_node.dart';

class LineView extends CoordChildView<LineSeries> with GridChild {
  final LineLayoutHelper helper = LineLayoutHelper();

  LineView(super.series);

  @override
  void onHoverStart(Offset offset) {
    helper.handleHoverOrClick(offset, false);
  }

  @override
  void onHoverMove(Offset offset, Offset last) {
    helper.handleHoverOrClick(offset, false);
  }

  @override
  void onHoverEnd() {
    helper.clearHover();
  }

  @override
  void onClick(Offset offset) {
    helper.handleHoverOrClick(offset, true);
  }

  @override
  void onStart() {
    super.onStart();
    helper.addListener(invalidate);
  }

  @override
  void onStop() {
    helper.removeListener(invalidate);
    super.onStop();
  }

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    helper.doMeasure(context, series, series.data, parentWidth, parentHeight);
    return super.onMeasure(parentWidth, parentHeight);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    helper.doLayout(context, series, series.data, selfBoxBound, LayoutType.layout);
  }

  @override
  void onDraw(Canvas canvas) {
    Offset offset = helper.getTranslation();
    Rect clipRect = Rect.fromLTWH(offset.dx.abs(), 0, width, height);
    var lineList = helper.lineList;
    var theme = context.config.theme.lineTheme;
    canvas.save();
    canvas.translate(offset.dx, 0);
    each(lineList, (lineNode, p1) {
      drawArea(canvas, lineNode, clipRect, offset, theme);
      drawLine(canvas, lineNode, clipRect, theme);
      if (series.symbolFun != null || theme.showSymbol) {
        drawSymbol(canvas, lineNode, clipRect, theme);
      }
    });
    canvas.restore();
  }

  void drawLine(Canvas canvas, LineNode lineNode, Rect clipRect, LineTheme theme) {
    if (lineNode.borderList.isEmpty) {
      return;
    }
    var ls = helper.getLineStyle(lineNode.data, lineNode.groupIndex);
    if (ls == null) {
      return;
    }
    lineNode.lineStyle = ls;
    for (var border in lineNode.borderList) {
      if (!clipRect.overlaps(border.rect)) {
        continue;
      }
      for (var subPath in border.subPathList) {
        if (!clipRect.overlaps(subPath.bound)) {
          continue;
        }
        ls.drawPath(canvas, mPaint, subPath.path, needSplit: false, drawDash: false);
      }
    }
  }

  void drawArea(Canvas canvas, LineNode lineNode, Rect clipRect, Offset scroll, LineTheme theme) {
    if (lineNode.areaList.isEmpty) {
      return;
    }
    var style = helper.getAreaStyle(lineNode.data, lineNode.groupIndex);
    if (style == null) {
      return;
    }
    lineNode.areaStyle = style;

    for (var area in lineNode.areaList) {
      List<Path> cl = area.getAreaPath(width, height, scroll);
      for (var p in cl) {
        style.drawPath(canvas, mPaint, p);
      }
    }
  }

  void drawSymbol(Canvas canvas, LineNode lineNode, Rect clipRect, LineTheme theme) {
    SymbolDesc desc = SymbolDesc();
    lineNode.symbolMap.forEach((key, node) {
      if (!clipRect.contains(node.offset)) {
        return;
      }
      var cl = helper.getLineStyle(node.group, node.groupIndex)?.color;
      if (cl != null) {
        desc.fillColor = [cl];
      }
      desc.center = node.offset;
      if (series.symbolFun != null) {
        ChartSymbol? symbol = series.symbolFun?.call(node.data, node.group);
        symbol?.draw(canvas, mPaint, desc);
      } else if (theme.showSymbol) {
        theme.symbol.draw(canvas, mPaint, desc);
      }
    });
  }

  /// 绘制柱状图
  void drawBarElement(Canvas canvas) {}

  /// 绘制标记点
  void drawMakePoint(Canvas canvas) {}

  /// 绘制标记线
  void drawMakeLine(Canvas canvas) {}

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
  List<DynamicData> getAxisExtreme(int axisIndex, bool isXAxis) {
    return helper.getAxisExtreme(series, axisIndex, isXAxis);
  }

  @override
  void onGridScrollChange(Offset scroll) {
    helper.onGridScrollChange(scroll);
  }

  @override
  void onGridScrollEnd(Offset scroll) {
    super.onGridScrollEnd(scroll);
    helper.onGridScrollEnd(scroll);
  }
}
