import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import '../stack_view.dart';

abstract class GridView<T extends StackItemData, G extends StackGroupData<T>, S extends StackSeries<T, G>,
    L extends GridHelper<T, G, S>> extends StackView<T, G, S, L> with GridChild {
  GridView(super.series);

  @override
  void onDrawGroupBk(Canvas canvas) {
    Set<GroupNode> rectSet = {};
    AreaStyle s2 = AreaStyle(color: series.groupHoverColor);
    Offset offset = layoutHelper.getTranslation();
    canvas.save();
    canvas.translate(offset.dx, 0);
    var nodeMap = layoutHelper.showNodeMap;
    nodeMap.forEach((key, node) {
      var group = node.parentNode.parentNode;
      if (rectSet.contains(group)) {
        return;
      }
      AreaStyle? style;
      if (series.groupStyleFun != null) {
        style = series.groupStyleFun?.call(node.data, node.parent, node.status);
      } else if (group.isHover) {
        style = s2;
      }
      if (style != null) {
        if (series.coordType == CoordType.polar) {
          style.drawPath(canvas, mPaint, group.arc.toPath(false));
        } else {
          style.drawRect(canvas, mPaint, group.rect);
        }
      }
      rectSet.add(group);
    });
    canvas.restore();
    return;
  }

  @override
  void onDrawBar(Canvas canvas) {
    Offset offset = layoutHelper.getTranslation();
    final map = layoutHelper.showNodeMap;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    map.forEach((key, node) {
      if (node.data == null) {
        return;
      }
      if (node.rect.isEmpty) {
        return;
      }
      var data = node.data!;
      var group = node.parent;
      var as = layoutHelper.buildAreaStyle(data, group, node.styleIndex, node.status);
      var ls = layoutHelper.buildLineStyle(data, group, node.styleIndex, node.status);
      node.areaStyle = as;
      node.lineStyle = ls;
      Corner? corner;
      if (as != null && ls != null) {
        corner = series.corner;
        if (series.cornerFun != null) {
          corner = series.cornerFun!.call(data, group, node.status);
        }
      }
      as?.drawRect(canvas, mPaint, node.rect, corner);
      ls?.drawRect(canvas, mPaint, node.rect, corner);
    });
    canvas.restore();
  }

  @override
  void onDrawBarLabel(Canvas canvas) {
    Offset offset = layoutHelper.getTranslation();
    final map = layoutHelper.showNodeMap;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    map.forEach((key, node) {
      if (node.data == null || node.rect.isEmpty) {
        return;
      }
      var data = node.data!;
      var group = node.parent;
      LabelStyle? style = series.getLabelStyle(context, data, group);
      if (style == null || !style.show) {
        return;
      }
      DynamicText? text;
      if (node.dynamicLabel != null) {
        text = formatData(node.dynamicLabel!, data, group, node.status);
      } else {
        text = series.formatData(context, data, group);
      }
      if (text == null || text.isEmpty) {
        return;
      }
      ChartAlign align = series.getLabelAlign(context, data, group);
      TextDrawInfo drawInfo = align.convert(node.rect, style, series.direction);
      style.draw(canvas, mPaint, text, drawInfo);
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

  DynamicText? formatData(dynamic data, T node, G group, Set<ViewState> status) {
    if (data is DynamicText) {
      return data;
    }
    if (series.labelFormatFun != null) {
      return series.labelFormatFun?.call(data, node, group, status);
    }

    if (data is String) {
      return DynamicText(data);
    }
    if (data is DateTime) {
      return data.toString().toText();
    }
    if (data is num) {
      return DynamicText.fromString(formatNumber(data, 2));
    }
    return data.toString().toText();
  }
}
