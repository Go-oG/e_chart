import 'dart:math' as m;
import 'package:flutter/rendering.dart';

import '../../event/index.dart';
import '../../utils/log_util.dart';
import '../index.dart';

/// ViewGroup
abstract class ChartViewGroup extends GestureView  {
  final List<ChartView> _children = [];

  ChartViewGroup() : super();

  @override
  void create(Context context, RenderNode parent) {
    super.create(context, parent);
    for (var c in _children) {
      c.create(context, this);
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
  void destroy() {
    for (var c in _children) {
      c.destroy();
    }
    super.destroy();
  }

  @override
  set forceLayout(bool f) {
    super.forceLayout = f;
    for (var c in children) {
      c.forceLayout=f;
    }
  }

  @override
  void markDirtyWithChild() {
    super.markDirtyWithChild();
    for(var c in children){
      c.markDirtyWithChild();
    }
  }


  void changeChildToFront(ChartView child) {
    int index = children.indexOf(child);
    if (index != -1) {
      children.removeAt(index);
    }
    _addViewInner(child, -1);
    requestLayout();
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
  /// 如果在方法中调用了[invalidate]则返回true
  bool drawChild(ChartView child, CCanvas canvas) {
    child.drawSelf(canvas, this);
    return false;
  }


  ///========================管理子View相关方法=======================
  void addView(ChartView view, {int index = -1}) {
    _addViewInner(view, index);
    if (!inLayout) {
      requestLayout();
    }
  }

  void removeView(ChartView view) {
    children.remove(view);
    if (!inLayout) {
      requestLayout();
    }
  }

  ChartView getChildAt(int index) {
    return children[index];
  }

  List<ChartView> get children {
    return _children;
  }

  int get childCount => _children.length;

  bool get hasChild => childCount > 0;

  ChartView get firstChild => _children.first;

  ChartView get lastChild => _children.last;

  bool hasChildView(ChartView view) {
    for (var element in _children) {
      if (element == view) {
        return true;
      }
    }
    return false;
  }

  void _addViewInner(ChartView child, int index) {
    if (child.parent != null && child.parent != this) {
      throw FlutterError(
          "The specified child already has a parent. You must call removeView() on the child's parent first.");
    }
    _addInArray(child, index);
  }

  void _addInArray(ChartView child, int index) {
    if (index >= children.length || index < 0 || children.isEmpty) {
      children.add(child);
      return;
    }
    children.insert(index, child);
    children.sort((a, b) {
      return a.zLevel.compareTo(b.zLevel);
    });
  }

  void clearChildren() {
    children.clear();
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
