import 'dart:math' as m;
import 'package:flutter/rendering.dart';

import '../../event/index.dart';
import '../../utils/log_util.dart';
import '../index.dart';

/// ViewGroup
abstract class ChartViewGroup extends GestureView {
  late List<ChartView> _children = [];

  ChartViewGroup() : super();

  @override
  void attach(Context context, RenderNode parent) {
    super.attach(context, parent);
    for (var c in _children) {
      c.attach(context, this);
    }
  }

  @override
  void onStart() {
    super.onStart();
    for (var c in _children) {
      try {
        c.onStart();
      } catch (e) {
        Logger.e(e);
      }
    }
  }

  @override
  void onStop() {
    for (var c in _children) {
      try {
        c.onStop();
      } catch (e) {
        Logger.e(e);
      }
    }
    super.onStop();
  }

  @override
  void onDispose() {
    var cl = _children;
    _children = [];
    for (var c in cl) {
      c.dispose();
    }
    super.onDispose();
  }

  @override
  set forceLayout(bool f) {
    super.forceLayout = f;
    for (var c in children) {
      c.forceLayout = f;
    }
  }

  @override
  void markDirtyWithChild() {
    super.markDirtyWithChild();
    for (var c in children) {
      c.markDirtyWithChild();
    }
  }

  ///=========Event和Action分发处理==================
  bool dispatchAction(ChartAction action) {
    return false;
  }

  ///=========布局测量相关============
  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    var oldW = parentWidth;
    var oldH = parentHeight;
    if (layoutParams.width.isNormal) {
      parentWidth = layoutParams.width.convert(parentWidth);
    }
    if (layoutParams.height.isNormal) {
      parentHeight = layoutParams.height.convert(parentHeight);
    }

    double maxHeight = 0;
    double maxWidth = 0;
    padding.left = layoutParams.getLeftPadding(parentWidth);
    padding.right = layoutParams.getRightPadding(parentWidth);
    padding.top = layoutParams.getTopPadding(parentHeight);
    padding.bottom = layoutParams.getBottomPadding(parentHeight);
    var pw = parentWidth - padding.horizontal;
    var ph = parentHeight - padding.vertical;

    ///第一次测量
    for (var child in children) {
      child.measure(pw, ph);
      var childLP = child.layoutParams;
      child.margin.left = childLP.getLeftMargin(pw);
      child.margin.right = childLP.getRightMargin(pw);
      child.margin.top = childLP.getTopMargin(ph);
      child.margin.bottom = childLP.getBottomMargin(ph);
      maxWidth = m.max(maxWidth, child.width + child.margin.horizontal);
      maxHeight = m.max(maxHeight, child.height + child.margin.vertical);
    }
    maxWidth += padding.horizontal;
    maxHeight += padding.vertical;

    var oldMaxWidth = maxWidth;
    var oldMaxHeight = maxHeight;

    if (layoutParams.width.isNormal) {
      maxWidth = layoutParams.width.convert(oldW);
    } else if (layoutParams.width.isMatch) {
      maxWidth = oldW;
    }
    if (layoutParams.height.isNormal) {
      maxHeight = layoutParams.height.convert(oldH);
    } else if (layoutParams.height.isMatch) {
      maxHeight = oldH;
    }
    if (oldMaxHeight == maxHeight && oldMaxWidth == maxWidth) {
      return Size(maxWidth, maxHeight);
    }

    padding.left = layoutParams.getLeftPadding(maxWidth);
    padding.right = layoutParams.getRightPadding(maxWidth);
    padding.top = layoutParams.getTopPadding(maxHeight);
    padding.bottom = layoutParams.getBottomPadding(maxHeight);
    pw = maxWidth - padding.horizontal;
    ph = maxHeight - padding.vertical;
    for (var child in children) {
      var childLP = child.layoutParams;
      child.margin.left = childLP.getLeftMargin(pw);
      child.margin.right = childLP.getRightMargin(pw);
      child.margin.top = childLP.getTopMargin(ph);
      child.margin.bottom = childLP.getBottomMargin(ph);
      double childWidth = pw;
      if (childLP.width.isMatch) {
        childWidth = m.max(0, pw - child.margin.horizontal);
      }
      double childHeight = ph;
      if (childLP.height.isMatch) {
        childHeight = m.max(0, ph - child.margin.vertical);
      }
      child.measure(childWidth, childHeight);
    }
    return Size(maxWidth, maxHeight);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    var parentLeft = padding.left;
    var parentTop = padding.top;
    for (var child in children) {
      var margin = child.margin;
      double childLeft = parentLeft + margin.left;
      double childTop = parentTop + margin.top;
      child.layout(childLeft, childTop, childLeft + child.width, childTop + child.height);
    }
  }

  @override
  void dispatchDraw(CCanvas canvas) {
    for (var child in children) {
      drawChild(child, canvas);
    }
  }

  /// 负责绘制单独的一个ChildView，同时负责Canvas的坐标的正确转换
  /// 如果在方法中调用了[requestDraw]则返回true
  bool drawChild(ChartView child, CCanvas canvas) {
    child.drawSelf(canvas, this);
    return false;
  }

  ///========================管理子View相关方法=======================
  void addView(ChartView view) {
    addViewInner(view);
    if (!nodeStatus.inLayout) {
      requestLayout();
    }
  }

  void addViews(Iterable<ChartView> views) {
    for (var c in views) {
      c.parent = this;
      children.add(c);
    }
    sortChildView();
    if (!nodeStatus.inLayout) {
      requestLayout();
    }
  }

  void addViewInner(ChartView child) {
    if (child.parent != null && child.parent != this) {
      Logger.w("The specified child already has a parent. You must call removeView() on the child's parent first.");
    }
    child.parent = this;
    children.add(child);
    sortChildView();
  }

  void sortChildView() {
    children.sort((a, b) {
      return a.zLevel.compareTo(b.zLevel);
    });
  }

  void removeView(ChartView view) {
    children.remove(view);
    if (!nodeStatus.inLayout) {
      requestLayout();
    }
  }

  ChartView childAt(int index) {
    return children[index];
  }

  List<ChartView> get children {
    return _children;
  }

  int get childCount => _children.length;

  bool get hasChild => _children.isNotEmpty;

  ChartView get firstChild => _children.first;

  ChartView get lastChild => _children.last;

  bool containsChild(ChartView view) {
    for (var element in _children) {
      if (element == view) {
        return true;
      }
    }
    return false;
  }

  void clearChildren() {
    _children = [];
  }

  @override
  bool get enableClick => false;

  @override
  bool get enableDrag => false;

  @override
  bool get enableHover => false;

  @override
  bool get enableScale => false;

  @override
  int allocateDataIndex(int index) {
    int u = 0;
    for (var c in children) {
      if (c.ignoreAllocateDataIndex()) {
        continue;
      }
      u += c.allocateDataIndex(index + u);
    }
    return u;
  }
}
