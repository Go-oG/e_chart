import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import 'sunburst_helper.dart';
import 'sunburst_tween.dart';

/// 旭日图
class SunburstView extends SeriesView<SunburstSeries, SunburstHelper> {
  late SunburstNode root;
  late SunburstNode _drawRoot;
  SunburstNode? backNode;

  SunburstView(super.series);

  @override
  void onClick(Offset offset) {
    Offset center = computeCenter();
    offset = offset.translate(-center.dx, -center.dy);
    if (backNode != null) {
      Arc arc = backNode!.cur.arc;
      if (offset.inSector(arc.innerRadius, arc.outRadius, arc.startAngle, arc.sweepAngle)) {
        back();
        return;
      }
    }

    SunburstNode? clickNode = _drawRoot.find((node, index, startNode) {
      Arc arc = node.cur.arc;
      return (offset.inSector(arc.innerRadius, arc.outRadius, arc.startAngle, arc.sweepAngle));
    });
    if (clickNode == null || clickNode == _drawRoot) {
      return;
    }
    _forward(clickNode);
  }

  @override
  void onHoverStart(Offset offset) {
    _handleHoverMove(offset);
  }

  @override
  void onHoverMove(Offset offset, Offset last) {
    _handleHoverMove(offset);
  }

  @override
  void onHoverEnd() {}

  void _handleHoverMove(Offset local) {
    Offset center = computeCenter();
    Offset offset = local.translate(-center.dx, -center.dy);

    SunburstNode? node;
    _drawRoot.eachBefore((tmp, index, startNode) {
      Arc arc = tmp.cur.arc;
      if (offset.inSector(arc.innerRadius, arc.outRadius, arc.startAngle, arc.sweepAngle)) {
        node = tmp;
        return true;
      }
      return false;
    });
    if (node == null || node!.select) {
      return;
    }
    _drawRoot.updateSelectStatus(false, mode: SelectedMode.group);
    node!.updateSelectStatus(true, mode: series.selectedMode);
    invalidate();
  }

  ///前进
  void _forward(SunburstNode clickNode) {
    // bool hasOldBackNode = backNode != null;
    // var oldBackNode = backNode;
    // backNode = SunburstNode(null, clickNode.data);
    // backNode!.cur = SunburstInfo(_layout.buildBackArc(root, clickNode));
    // if (hasOldBackNode) {
    //   backNode!.start = oldBackNode!.start;
    //   backNode!.end = backNode!.cur.copy();
    // } else {
    //   Arc arc = backNode!.cur.arc;
    //   Arc startArc = arc.copy(outRadius: arc.innerRadius);
    //   backNode!.start = SunburstInfo(startArc);
    //   backNode!.end = SunburstInfo(arc.copy());
    // }
    // clickNode.each((node, index, startNode) {
    //   node.start = node.cur.copy();
    //   return false;
    // });
    // _layout.doLayout(context, series, root, clickNode, width, height);
    // clickNode.each((node, index, startNode) {
    //   node.end = node.cur.copy();
    //   return false;
    // });
    // _drawRoot = clickNode;
    // executeTween(clickNode, backNode);
  }

  ///后退
  void back() {
    // if (_drawRoot.parent == null) {
    //   backNode = null;
    //   return;
    // }
    // var oldBackNode = backNode;
    // backNode = null;
    // SunburstNode rootNode = _drawRoot.parent!;
    // rootNode.each((node, index, startNode) {
    //   node.start = node.cur.copy();
    //   return false;
    // });
    // if (rootNode.parent != null) {
    //   backNode = SunburstNode(null, _drawRoot.data);
    //   backNode!.cur = SunburstInfo(_layout.buildBackArc(root, rootNode));
    //   if (oldBackNode != null) {
    //     backNode!.start = oldBackNode.cur;
    //     backNode!.end = backNode!.cur.copy();
    //   } else {
    //     Arc arc = backNode!.cur.arc;
    //     Arc copyArc = arc.copy(outRadius: arc.innerRadius);
    //     backNode!.start = SunburstInfo(copyArc);
    //     backNode!.end = backNode!.cur.copy();
    //   }
    // }
    //
    // ///布局
    // _layout.doLayout(context, series, root, rootNode, width, height);
    // rootNode.each((node, index, startNode) {
    //   node.end = node.cur.copy();
    //   return false;
    // });
    //
    // ///节点替换
    // _drawRoot = rootNode;
    //
    // ///执行动画
    // executeTween(rootNode, backNode);
  }

  ///执行动画
  ChartTween? _oldTween;

  void executeTween(SunburstNode node, [SunburstNode? other]) {
    _oldTween?.stop();
    ChartDoubleTween tween = ChartDoubleTween(props: series.animation!);
    SunburstTween tweenTmp = SunburstTween(node.start, node.end, props: series.animation!);
    tween.addListener(() {
      double percent = tween.value;
      node.each((tmp, index, startNode) {
        tweenTmp.changeValue(tmp.start, tmp.end);
        tmp.cur = tweenTmp.safeGetValue(percent);
        tmp.updatePath(series, percent);
        return false;
      });
      if (other != null) {
        tweenTmp.changeValue(other.start, other.end);
        other.cur = tweenTmp.safeGetValue(percent);
        other.updatePath(series, percent);
      }
      invalidate();
    });
    _oldTween = tween;
    tween.start(context);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    convertData();
    layoutHelper.doLayout(selfBoxBound,globalBoxBound, LayoutType.layout);
    _drawRoot = root;
  }

  void convertData() {
    root = toTree<TreeData, SunburstNode>(
      series.data,
      (p0) => p0.children,
      (p0, p1) => SunburstNode(p0, p1, value: p1.value),
      sort: (a, b) {
        if (series.sort == Sort.empty) {
          return 0;
        }
        if (series.sort == Sort.asc) {
          return a.data.value.compareTo(b.data.value);
        } else {
          return b.data.value.compareTo(a.data.value);
        }
      },
    );
    root.sum((p0) => p0.data.value);
    if (series.matchParent) {
      root.each((node, index, startNode) {
        if (node.hasChild) {
          node.value = 0;
        }
        return false;
      });
      root.sum();
    }
    root.computeHeight();
  }

  void runAnimator() {
    AnimatorAttrs? info = series.animation;
    if (info == null) {
      return;
    }
    ChartDoubleTween tween = ChartDoubleTween(props: series.animation!);
    tween.addListener(() {
      double v = tween.value;
      _drawRoot.each((node, index, startNode) {
        node.updatePath(series, v);
        return false;
      });
      invalidate();
    });
    _oldTween = tween;
    tween.start(context);
  }

  @override
  void onDraw(Canvas canvas) {
    Offset center = computeCenter();
    canvas.save();
    canvas.translate(center.dx, center.dy);
    _drawRoot.eachBefore((node, index, startNode) {
      _drawSector(canvas, node);
      return false;
    });
    _drawRoot.eachBefore((node, index, startNode) {
      _drawText(canvas, node);
      return false;
    });
    _drawBackArea(canvas);
    canvas.restore();
  }

  void _drawSector(Canvas canvas, SunburstNode node) {
    if (node == root) {
      return;
    }
    AreaStyle? style = series.areaStyleFun.call(node);
    // style?.drawPath(canvas, mPaint, node.cur.shapePath!, colorOpacity: node.cur.alpha >= 1 ? null : node.cur.alpha);
    style.drawPath(canvas, mPaint, node.cur.shapePath!);
  }

  void _drawText(Canvas canvas, SunburstNode node) {
    Arc arc = node.cur.arc;
    if (node.data.label == null || node.data.label!.isEmpty) {
      return;
    }
    LabelStyle? style = series.labelStyleFun?.call(node);
    if (style == null || arc.sweepAngle <= style.minAngle) {
      return;
    }
    TextDrawInfo config = TextDrawInfo(
      node.cur.textPosition,
      align: Alignment.center,
      maxWidth: arc.outRadius - arc.innerRadius,
      rotate: node.cur.textRotateAngle,
    );
    style.draw(canvas, mPaint, node.data.label!, config);
  }

  void _drawBackArea(Canvas canvas) {
    if (backNode == null) {
      return;
    }
    AreaStyle style = series.backStyle ?? const AreaStyle(color: Colors.grey);
    style.drawPath(canvas, mPaint, backNode!.cur.arc.toPath(true));
  }

  Offset computeCenter() {
    return Offset(series.center[0].convert(width), series.center[1].convert(height));
  }

  @override
  void onDestroy() {
    _oldTween?.stop();
    _oldTween = null;
    super.onDestroy();
  }

  @override
  SunburstHelper buildLayoutHelper() {
    return SunburstHelper(context, series);
  }
}
