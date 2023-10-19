import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class CircleHelper extends LayoutHelper2<CircleNode, CircleSeries> {
  CircleHelper(super.context, super.view, super.series);

  Offset center = Offset.zero;
  double ir = 0;
  double maxRadius = 0;

  @override
  void onLayout(LayoutType type) {
    if (series.center.isEmpty) {
      throw ChartError("center must not null");
    }
    center = Offset(series.center.first.convert(width), series.center.last.convert(height));
    num size = min([width, height]);
    ir = series.innerRadius.convert(size);
    maxRadius = size * 0.5;

    var newList = convert2Node(series.data);
    layoutNode(newList);
    var an = DiffUtil.diffLayout3(
      getAnimation(type),
      nodeList,
      newList,
      (node, type) {
        if (type == DiffType.remove || type == DiffType.update) {
          return {'arc': node.attr};
        }
        var arc = node.attr.copy(
          sweepAngle: (type == DiffType.add) ? 0 : node.attr.sweepAngle,
        );
        return {'arc': arc};
      },
      (node, type) {
        if (type == DiffType.add || type == DiffType.update) {
          return {'arc': node.attr};
        }
        return {'arc': node.attr.copy(sweepAngle: 0, outRadius: node.attr.innerRadius)};
      },
      (node, s, e, t, type) {
        var sa = s['arc'] as Arc;
        var ea = e['arc'] as Arc;
        node.attr = Arc.lerp(sa, ea, t);
      },
      (resultList, t) {
        nodeList = resultList;
        notifyLayoutUpdate();
      },
      onStart: () => inAnimation = true,
      onEnd: () => inAnimation = false,
    );
    context.addAnimationToQueue(an);
  }

  void layoutNode(List<CircleNode> list) {
    if (list.isEmpty) {
      return;
    }
    var start = ir;
    each(list, (node, i) {
      var data = node.data;
      var percent = data.value / data.max;
      if (percent.isNaN || percent.isInfinite) {
        percent = 1;
      }
      percent = percent.abs();
      var r = getRadius(data, i, list.length);
      var gap = getGap(data, i, list.length);
      node.attr = Arc(
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

  num getRadius(CircleItemData data, int index, int allCount) {
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

  num getGap(CircleItemData data, int index, int allCount) {
    var fun = series.radiusGapFun;
    if (fun != null) {
      return fun.call(data, index, ir, maxRadius);
    }
    var r = series.radiusGap;
    return r.convert(maxRadius - ir);
  }

  List<CircleNode> convert2Node(List<CircleItemData> list) {
    List<CircleNode> nl = [];
    final Set<ViewState> emptyVS = {};
    each(list, (data, p1) {
      var node = CircleNode(
        data,
        p1,
        0,
        Arc.zero,
        series.getAreaStyle(context, data, p1, emptyVS),
        series.getBorderStyle(context, data, p1, emptyVS),
        series.getLabelStyle(context, data, p1, emptyVS),
      );
      node.backgroundStyle = series.getBackStyle(context, data);
      nl.add(node);
    });

    return nl;
  }
}
