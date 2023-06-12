import 'dart:math';
import 'dart:ui';

import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/ext/offset_ext.dart';
import 'package:flutter/material.dart';

import '../../action/hover_action.dart';
import '../../animation/animator_props.dart';
import '../../animation/tween/double_tween.dart';
import '../../core/command.dart';
import '../../core/view.dart';
import '../../model/enums/circle_align.dart';
import '../../style/area_style.dart';
import '../../utils/log_util.dart';
import 'layout.dart';
import 'pie_series.dart';
import 'pie_tween.dart';

/// 饼图
class PieView extends SeriesView<PieSeries> {
  final PieLayout pieLayer = PieLayout();

  PieView(super.series);

  @override
  bool get enableDrag => false;

  @override
  void onClick(Offset offset) {
    _handleClickWithHover(offset);
  }

  @override
  void onHoverStart(Offset offset) {
    _handleClickWithHover(offset);
  }

  @override
  void onHoverMove(Offset offset, Offset last) {
    _handleClickWithHover(offset);
  }

  PieNode? hoverNode;

  void _handleClickWithHover(Offset offset) {
    List<PieNode> nodeList = pieLayer.nodeList;
    if (nodeList.isEmpty) {
      return;
    }
    PieNode? clickNode = pieLayer.findNode(offset);
    if (clickNode == null) {
      logPrint('无法找到点击节点');
    }

    bool hasSame = clickNode == hoverNode;
    if (hasSame) {
      logPrint('相同节点无需处理');
      return;
    }
    hoverNode = clickNode;
    Map<PieNode, PieProps> oldPropsMap = {};
    each(nodeList, (node, p1) {
      node.select = node == clickNode;
      oldPropsMap[node] = node.props;
    });

    ///二次布局
    pieLayer.layoutNode(nodeList);
    Map<PieNode, PieProps> propsMap = {};
    each(nodeList, (node, p1) {
      if (node == clickNode) {
        PieProps p;
        if (series.scaleExtend.percent) {
          var or = node.props.or * (1 + series.scaleExtend.percentRatio());
          p = node.props.clone(or: or);
        } else {
          p = node.props.clone(or: node.props.or + series.scaleExtend.number);
        }
        propsMap[node] = p;
        node.select = true;
      } else {
        propsMap[node] = node.props;
        node.select = false;
      }
    });
    PieNode firstNode = nodeList[0];
    PieTween tween = PieTween(firstNode.props, firstNode.props);
    ChartDoubleTween doubleTween = ChartDoubleTween(0, 1, duration: const Duration(milliseconds: 150));
    doubleTween.addListener(() {
      for (var node in nodeList) {
        tween.changeValue(oldPropsMap[node]!, propsMap[node]!);
        node.props = tween.safeGetValue(doubleTween.value);
      }
      invalidate();
    });
    doubleTween.start(context);
  }

  @override
  void onUpdateDataCommand(Command c) {
    super.onUpdateDataCommand(c);
    pieLayer.doLayout(context, series, series.data, width, height);
    if (c.runAnimation) {
      doAnimator();
    } else {
      invalidate();
    }
  }

  @override
  void onStart() {
    super.onStart();
    pieLayer.addListener(invalidate);
  }

  @override
  void onStop() {
    pieLayer.removeListener(invalidate);
    super.onStop();
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    pieLayer.doLayout(context, series, series.data, width, height);
    doAnimator();
  }

  ChartTween? tween;

  void doAnimator() {
    List<PieNode> nodeList = pieLayer.nodeList;
    AnimatorProps? info = series.animation;
    if (info == null || nodeList.isEmpty) {
      return;
    }

    this.tween?.dispose();
    this.tween = null;

    PieAnimatorStyle style = series.animatorStyle;
    Map<PieNode, PieProps> startMap = {};
    Map<PieNode, PieProps> endMap = {};
    for (var ele in nodeList) {
      endMap[ele] = ele.props;
      PieProps start = ele.props.clone(sweepAngle: 0);
      if (style == PieAnimatorStyle.expand || style == PieAnimatorStyle.expandScale) {
        start = start.clone(startAngle: series.offsetAngle);
      }
      if (style == PieAnimatorStyle.expandScale || style == PieAnimatorStyle.originExpandScale) {
        start = start.clone(or: start.ir);
      }
      startMap[ele] = start;
    }
    PieNode first = nodeList.first;

    ChartDoubleTween tween = ChartDoubleTween.fromAnimator(info);
    PieTween pieTween = PieTween(first.props, first.props);
    tween.addListener(() {
      double v = tween.value;
      each(nodeList, (node, i) {
        pieTween.changeValue(startMap[node]!, endMap[node]!);
        node.props = pieTween.safeGetValue(v);
      });
      invalidate();
    });
    this.tween = tween;
    tween.start(context);
  }

  @override
  void onDestroy() {
    pieLayer.dispose();
    super.onDestroy();
  }

  @override
  void onDraw(Canvas canvas) {
    // Offset center = pieLayer.center;
    // double r = 80;
    // double corner = 8;
    // Path path = Path();
    // path.moveTo(center.dx, center.dy - r / 2);
    // path.lineTo(center.dx, center.dy - r);
    //
    // path.arcTo(Rect.fromCircle(center: center, radius: r), -pi / 2, pi / 2, false);
    // path.lineTo(center.dx + r / 2, center.dy);
    // path.arcTo(Rect.fromCircle(center: center, radius: r / 2), 0, -pi / 2, false);
    // path.close();
    //
    // AreaStyle style = AreaStyle(border: LineStyle());
    // style.drawPath(canvas, mPaint, path);
    // InnerOffset offset = _computeLT(r, corner, 270, center);
    // debugDraw(canvas, offset.center, color: Colors.deepPurple, r: 2);
    // debugDraw(canvas, offset.p1, color: Colors.blueAccent, r: 2);
    // debugDraw(canvas, offset.p2, color: Colors.red, r: 2);
    doDraw(canvas);
  }

  void doDraw(Canvas canvas) {
    var action = HoverAction();
    List<PieNode> nodeList = pieLayer.nodeList;
    for (var node in nodeList) {
      AreaStyle? style = series.areaStyleFun.call(node.data, node.select ? action : null);
      if (style == null) {
        continue;
      }
      Path path = node.toPath();
      style.drawPath(canvas, mPaint, path);
    }
    for (var node in nodeList) {
      drawText(canvas, node);
    }
  }

  void drawText(Canvas canvas, PieNode node) {
    node.updateTextPosition(series);
    var labelStyle = node.labelStyle;
    var config = node.textDrawConfig;

    if (node.data.label == null || node.data.label!.isEmpty) {
      return;
    }
    if (labelStyle == null || !labelStyle.show || config == null) {
      return;
    }

    if (series.labelAlign == CircleAlign.center) {
      if (hoverNode == null) {
        return;
      }
      if (node != hoverNode) {
        return;
      }
      labelStyle.draw(canvas, mPaint, node.data.label!, config);
      return;
    }
    labelStyle.draw(canvas, mPaint, node.data.label!, config);

    if (series.labelAlign == CircleAlign.outside) {
      Offset center = pieLayer.center;
      Offset tmpOffset = circlePoint(node.props.or, node.props.startAngle + (node.props.sweepAngle / 2), center);
      Offset tmpOffset2 = circlePoint(
        node.props.or + labelStyle.guideLine.length,
        node.props.startAngle + (node.props.sweepAngle / 2),
        center,
      );
      Path path = Path();
      path.moveTo(tmpOffset.dx, tmpOffset.dy);
      path.lineTo(tmpOffset2.dx, tmpOffset2.dy);
      path.lineTo(config.offset.dx, config.offset.dy);
      labelStyle.guideLine.style.drawPath(canvas, mPaint, path);
    }
  }
}



InnerOffset _computeRB(num ir, num corner, num angle, Offset center) {
  InnerOffset result = InnerOffset();
  num dis = (corner + ir);
  double x = sqrt(dis * dis - corner * corner);
  Offset c = Offset(x, -corner.toDouble());
  result.center = c.translate(center.dx, center.dy);
  result.p1 = Offset(result.center.dx, center.dy);
  result.p2 = computeOutCutPoint(center, ir, result.center, corner);

  ///旋转
  result.center = result.center.rotateOffset(angle, center: center);
  result.p1 = result.p1.rotateOffset(angle, center: center);
  result.p2 = result.p2.rotateOffset(angle, center: center);
  return result;
}

InnerOffset _computeRT(num or, num corner, num angle, Offset center) {
  InnerOffset result = InnerOffset();
  num dis = (or - corner).abs();
  double x = sqrt(dis * dis - corner * corner);
  Offset c = Offset(x, -corner.toDouble());
  result.center = c.translate(center.dx, center.dy);
  result.p1 = computeOutCutPoint(center, or, result.center, corner);
  result.p2 = Offset(result.center.dx, center.dy);

  ///旋转
  result.center = result.center.rotateOffset(angle, center: center);
  result.p1 = result.p1.rotateOffset(angle, center: center);
  result.p2 = result.p2.rotateOffset(angle, center: center);
  return result;
}

InnerOffset _computeLB(num ir, num corner, num angle, Offset center) {
  InnerOffset result = InnerOffset();
  num dis = (ir + corner).abs();
  double x = sqrt(dis * dis - corner * corner);
  Offset c = Offset(x, corner.toDouble());
  result.center = c.translate(center.dx, center.dy);
  result.p1 = computeOutCutPoint(center, ir, result.center, corner);
  result.p2 = Offset(result.center.dx, center.dy);

  ///旋转
  result.center = result.center.rotateOffset(angle, center: center);
  result.p1 = result.p1.rotateOffset(angle, center: center);
  result.p2 = result.p2.rotateOffset(angle, center: center);
  return result;
}

InnerOffset _computeLT(num or, num corner, num angle, Offset center) {
  InnerOffset result = InnerOffset();
  num dis = (or - corner).abs();
  double x = sqrt(dis * dis - corner * corner);
  Offset c = Offset(x, corner.toDouble());
  result.center = c.translate(center.dx, center.dy);
  result.p1 = Offset(result.center.dx, center.dy);
  result.p2 = computeOutCutPoint(center, or, result.center, corner);

  ///旋转
  result.center = result.center.rotateOffset(angle, center: center);
  result.p1 = result.p1.rotateOffset(angle, center: center);
  result.p2 = result.p2.rotateOffset(angle, center: center);
  return result;
}

InnerOffset _computeCornerPoint(Offset center, num r, num corner, num angle, bool left, bool top) {
  InnerOffset result = InnerOffset();
  num dis = (r + corner * (top ? -1 : 1)).abs();
  double x = sqrt(dis * dis - corner * corner);
  Offset c = Offset(x, corner.toDouble() * (left ? 1 : -1));
  result.center = c.translate(center.dx, center.dy);
  Offset o1 = Offset(result.center.dx, center.dy);
  Offset o2 = computeOutCutPoint(center, r, result.center, corner);
  if (left != top) {
    Offset tmp = o1;
    o1 = o2;
    o2 = tmp;
  }
  result.p1 = o1;
  result.p2 = o2;

  ///旋转
  result.center = result.center.rotateOffset(angle, center: center);
  result.p1 = result.p1.rotateOffset(angle, center: center);
  result.p2 = result.p2.rotateOffset(angle, center: center);
  return result;
}

///计算两个圆外切时的切点坐标
Offset computeOutCutPoint(Offset c1, num r1, Offset c2, num r2) {
  double dx = c1.dx - c2.dx;
  double dy = c1.dy - c2.dy;
  num r12 = r1 * r1;
  num r22 = r2 * r2;

  double d = sqrt(dx * dx + dy * dy);
  double l = (r12 - r22 + d * d) / (2 * d);
  double h2 = r12 - l * l;
  double h;
  if (h2.abs() <= 0.00001) {
    h = 0;
  } else {
    h = sqrt(h2);
  }
  double x1 = (c2.dx - c1.dx) * l / d + ((c2.dy - c1.dy) * h / d) + c1.dx;
  double y1 = (c2.dy - c1.dy) * l / d - (c2.dx - c1.dx) * h / d + c1.dy;

  double x2 = (c2.dx - c1.dx) * l / d - ((c2.dy - c1.dy) * h / d) + c1.dx;
  double y2 = (c2.dy - c1.dy) * l / d + (c2.dx - c1.dx) * h / d + c1.dy;

  return Offset(x1, y1);
}

class InnerOffset {
  Offset center = Offset.zero;
  Offset p1 = Offset.zero;
  Offset p2 = Offset.zero;
}
