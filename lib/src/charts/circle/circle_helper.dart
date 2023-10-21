import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class CircleHelper extends LayoutHelper2<CircleData, CircleSeries> {
  CircleHelper(super.context, super.view, super.series);

  Offset center = Offset.zero;
  double ir = 0;
  double maxRadius = 0;

  @override
  void onLayout(LayoutType type) {
    if (series.center.isEmpty) {
      throw ChartError("center must not null");
    }
    var oldList = nodeList;
    var newList = [...series.data];
    initData(newList);
    var an = DiffUtil.diff<CircleData>(
      getAnimation(type),
      oldList,
      newList,
      (dataList) => layoutData(dataList, type),
      (node, type) {
        if (type == DiffType.remove || type == DiffType.update) {
          return {'arc': node.attr};
        }
        return {'arc': node.attr.copy(sweepAngle: 0)};
      },
      (node, type) {
        if (type == DiffType.add || type == DiffType.update) {
          return {'arc': node.attr};
        }
        return {'arc': node.attr.copy(sweepAngle: 0)};
      },
      (node, s, e, t, type) {
        var sa = s['arc'] as Arc;
        var ea = e['arc'] as Arc;
        node.attr = Arc.lerp(sa, ea, t);
      },
      (dataList, t) {
        nodeList = dataList;
        notifyLayoutUpdate();
      },
      onStart: () => inAnimation = true,
      onEnd: () => inAnimation = false,
    );
    context.addAnimationToQueue(an);
  }

  void layoutData(List<CircleData> dataList, LayoutType type) {
    center = Offset(series.center.first.convert(width), series.center.last.convert(height));
    num size = min([width, height]);
    ir = series.innerRadius.convert(size);
    maxRadius = size * 0.5;
    if (dataList.isEmpty) {
      return;
    }
    var start = ir;
    final int len = dataList.length;
    each(dataList, (data, i) {
      var percent = data.value / data.max;
      if (percent.isNaN || percent.isInfinite) {
        percent = 1;
      }
      percent = percent.abs();
      var r = getRadius(data, i, len);
      var gap = getGap(data, i, len);
      data.attr = Arc(
        startAngle: data.offsetAngle,
        sweepAngle: (series.clockWise ? 360 : -360) * percent,
        innerRadius: start,
        outRadius: start + r,
        cornerRadius: series.corner,
        center: center,
      );
      start += r + gap;
    });
  }

  num getRadius(CircleData data, int index, int allCount) {
    var fun = series.radiusFun;
    if (fun != null) {
      return fun.call(data, index, ir, maxRadius);
    }
    var r = series.radius;
    if (r != null) {
      return r.convert(maxRadius);
    }
    return (maxRadius - ir) / allCount;
  }

  num getGap(CircleData data, int index, int allCount) {
    var fun = series.radiusGapFun;
    if (fun != null) {
      return fun.call(data, index, ir, maxRadius);
    }
    var r = series.radiusGap;
    return r.convert(maxRadius - ir);
  }

  @override
  void initData(List<CircleData> dataList) {
    each(dataList, (data, p1) {
      data.dataIndex = p1;
      data.updateStyle(context, series);
      data.backgroundStyle = series.getBackStyle(context, data);
    });
  }
}
