import 'package:e_chart/src/ext/offset_ext.dart';
import 'package:e_chart/src/ext/tree_node_ext.dart';
import 'package:flutter/material.dart';
import 'package:chart_xutil/chart_xutil.dart';

import '../../animation/animator_props.dart';
import '../../animation/chart_tween.dart';
import '../../animation/tween/double_tween.dart';
import '../../core/view.dart';
import '../../gesture/chart_gesture.dart';
import '../../gesture/gesture_event.dart';
import '../../model/enums/select_mode.dart';
import '../../model/enums/sort.dart';
import '../../model/text_position.dart';
import '../../model/tree_data.dart';
import '../../shape/arc.dart';
import '../../style/area_style.dart';
import '../../style/label.dart';
import 'layout.dart';
import 'sunburst_series.dart';
import 'sunburst_tween.dart';

/// 旭日图
class SunburstView extends View {
  final SunburstSeries series;
  final SunburstLayout _layout = SunburstLayout();
  late final SunburstNode root;
  late SunburstNode _drawRoot;
  final RectGesture _gesture = RectGesture();
  SunburstNode? backNode;

  SunburstView(this.series) {
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
    _gesture.click = (e) {
      _handleClick(e);
    };
    _gesture.hoverMove = _handleHoverMove;
    _gesture.hoverEnd = (e) {
      //  _drawRoot.updateSelectStatus(false, mode: SelectedMode.all);
      invalidate();
    };
  }

  void _handleClick(NormalEvent e) {
    Offset offset = toLocalOffset(e.globalPosition).translate(-width / 2, -height / 2);
    if (backNode != null) {
      Arc arc = backNode!.cur.arc;
      if (offset.inSector(arc.innerRadius, arc.outRadius, arc.startAngle, arc.sweepAngle)) {
        back();
        return;
      }
    }
    SunburstNode? clickNode;
    _drawRoot.eachBefore((tmp, index, startNode) {
      Arc arc = tmp.cur.arc;
      if (offset.inSector(arc.innerRadius, arc.outRadius, arc.startAngle, arc.sweepAngle)) {
        clickNode = tmp;
        return true;
      }
      return false;
    });
    if (clickNode == null || clickNode == _drawRoot) {
      return;
    }
    _forward(clickNode!);
  }

  void _handleHoverMove(NormalEvent e) {
    Offset offset = toLocalOffset(e.globalPosition);
    offset = offset.translate(-width / 2, -height / 2);
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
    _drawRoot.updateSelectStatus(false, mode: SelectedMode.all);
    node!.updateSelectStatus(true, mode: series.selectedMode);
    invalidate();
  }

  ///前进
  void _forward(SunburstNode clickNode) {
    bool hasOldBackNode = backNode != null;
    var oldBackNode = backNode;
    backNode = SunburstNode(null, clickNode.data);
    backNode!.cur = SunburstInfo(_layout.buildBackArc(series, root, clickNode, width, height));
    if (hasOldBackNode) {
      backNode!.start = oldBackNode!.start;
      backNode!.end = backNode!.cur.copy();
    } else {
      Arc arc = backNode!.cur.arc;
      Arc startArc = arc.copy(outRadius: arc.innerRadius);
      backNode!.start = SunburstInfo(startArc);
      backNode!.end = SunburstInfo(arc.copy());
    }
    clickNode.each((node, index, startNode) {
      node.start = node.cur.copy();
      return false;
    });
    _layout.layout(series, root, clickNode, width, height);
    clickNode.each((node, index, startNode) {
      node.end = node.cur.copy();
      return false;
    });
    _drawRoot = clickNode;
    executeTween(clickNode, backNode);
  }

  ///后退
  void back() {
    if (_drawRoot.parent == null) {
      backNode = null;
      return;
    }
    var oldBackNode = backNode;
    backNode = null;
    SunburstNode rootNode = _drawRoot.parent!;
    rootNode.each((node, index, startNode) {
      node.start = node.cur.copy();
      return false;
    });
    if (rootNode.parent != null) {
      backNode = SunburstNode(null, _drawRoot.data);
      backNode!.cur = SunburstInfo(_layout.buildBackArc(series, root, rootNode, width, height));
      if (oldBackNode != null) {
        backNode!.start = oldBackNode.cur;
        backNode!.end = backNode!.cur.copy();
      } else {
        Arc arc = backNode!.cur.arc;
        Arc copyArc = arc.copy(outRadius: arc.innerRadius);
        backNode!.start = SunburstInfo(copyArc);
        backNode!.end = backNode!.cur.copy();
      }
    }

    ///布局
    _layout.layout(series, root, rootNode, width, height);
    rootNode.each((node, index, startNode) {
      node.end = node.cur.copy();
      return false;
    });

    ///节点替换
    _drawRoot = rootNode;

    ///执行动画
    executeTween(rootNode, backNode);
  }

  ///执行动画
  ChartTween? _oldTween;

  void executeTween(SunburstNode node, [SunburstNode? other]) {
    _oldTween?.stop();
    Duration duration = const Duration(milliseconds: 800);
    Curve curve = Curves.linear;
    ChartDoubleTween tween = ChartDoubleTween(0, 1, duration: duration, curve: curve);
    SunburstTween tweenTmp = SunburstTween(node.start, node.end, duration: duration, curve: curve);
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
    tween.start(context.tickerProvider);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    _gesture.rect = globalAreaBound;
    root.leaves().forEach((element) {
      element.computeHeight(element);
    });
    _layout.layout(series, root, root, width, height);
    _drawRoot = root;
    AnimatorProps? info = series.animation;
    if (info != null) {
      ChartDoubleTween tween = ChartDoubleTween.fromAnimator(info);
      tween.addListener(() {
        double v = tween.value;
        _drawRoot.each((node, index, startNode) {
          node.updatePath(series, v);
          return false;
        });
        invalidate();
      });
      _oldTween = tween;
      tween.start(context.tickerProvider);
    }
  }

  @override
  void onDraw(Canvas canvas) {
    canvas.save();
    canvas.translate(width / 2, height / 2);
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
    AreaStyle? style = series.areaStyleFun.call(node, null);
    style?.drawPath(canvas, paint, node.cur.shapePath!, colorOpacity: node.cur.alpha >= 1 ? null : node.cur.alpha);
  }

  void _drawText(Canvas canvas, SunburstNode node) {
    Arc arc = node.cur.arc;
    if (node.data.label == null || node.data.label!.isEmpty) {
      return;
    }
    LabelStyle? style = series.labelStyleFun?.call(node, null);
    if (style == null || arc.sweepAngle <= style.minAngle) {
      return;
    }
    TextDrawConfig config = TextDrawConfig(node.cur.textPosition,
        align: Alignment.center, maxWidth: arc.outRadius - arc.innerRadius, rotate: node.cur.textRotateAngle);
    style.draw(canvas, paint, node.data.label!, config);
  }

  void _drawBackArea(Canvas canvas) {
    if (backNode == null) {
      return;
    }
    AreaStyle style = series.backStyle ?? const AreaStyle(color: Colors.grey);
    style.drawPath(canvas, paint, backNode!.cur.arc.path(true));
  }

  @override
  void onAttach() {
    super.onAttach();
    context.gestureDispatcher.addGesture(_gesture);
  }

  @override
  void onDetach() {
    super.onDetach();
    _oldTween?.stop();
  }
}
