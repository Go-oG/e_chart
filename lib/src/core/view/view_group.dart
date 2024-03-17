import 'dart:math' as m;
import 'package:e_chart/src/core/view/AttachInfo.dart';
import 'package:e_chart/src/core/view/models.dart';
import 'package:flutter/rendering.dart';

import '../../event/index.dart';
import '../../utils/log_util.dart';
import '../index.dart';
import 'view_parent.dart';

/// ViewGroup
abstract class ChartViewGroup extends GestureView implements ViewParent {
  ChartViewGroup(super.context);

  List<ChartView> _children = [];

  ///存放当前ViewGroup中 需要布局的孩子
  ///可能会存在不需要布局的孩子
  List<ChartView> getChildren() => children;

  ChartView? _mFocusedView;

  @override
  void dispatchAttachInfo(AttachInfo attachInfo) {
    super.dispatchAttachInfo(attachInfo);
    for (var item in _children) {
      item.dispatchAttachInfo(attachInfo);
    }
  }

  @override
  void attachToWindow() {
    super.attachToWindow();
    for (var c in _children) {
      c.attachToWindow();
    }
  }

  @override
  void detachFromWindow() {
    super.detachFromWindow();
    for (var c in _children) {
      c.detachFromWindow();
    }
  }

  @override
  void onDispose() {
    super.onDispose();
    var cl = _children;
    _children = [];
    for (var c in cl) {
      c.dispose();
    }
  }

  @override
  set forceLayout(bool f) {
    super.forceLayout = f;
    for (var c in children) {
      c.forceLayout = f;
    }
  }

  ///=========Event和Action分发处理==================
  bool dispatchAction(ChartAction action) {
    return false;
  }

  ///=========布局测量相关============
  @override
  Size onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec) {
    var parentWidth = widthSpec.size;
    var parentHeight = heightSpec.size;
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
    var ws = MeasureSpec(layoutParams.width.toSpecMode(), pw);
    var hs = MeasureSpec(layoutParams.height.toSpecMode(), pw);
    for (var child in children) {
      child.measure(ws, hs);
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
      var wcs = MeasureSpec(layoutParams.width.toSpecMode(), childWidth);
      var hcs = MeasureSpec(layoutParams.height.toSpecMode(), childHeight);
      child.measure(wcs, hcs);
    }
    return Size(maxWidth, maxHeight);
  }

  @override
  void onLayout(bool changed, double left, double top, double right, double bottom) {
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
    var count = canvas.getSaveCount();
    for (var child in children) {
      if (child.needNewLayer || child.alpha != 1) {
        var c = canvas.getSaveCount() - count;
        canvas.restoreToCount(c);
        if (child.alpha != 1) {
          canvas.context.pushOpacity(Offset.zero, (child.alpha * 255).toInt(), (ctx, offset) {
            drawChild(child, CCanvas.fromContext(ctx));
          });
        } else {
          canvas.context.pushLayer(OffsetLayer(), (ctx, offset) {
            count = ctx.canvas.getSaveCount();
            drawChild(child, CCanvas.fromContext(ctx));
          }, Offset.zero);
        }
      } else {
        drawChild(child, canvas);
      }
    }
  }

  void drawChild(ChartView child, CCanvas canvas) {
    int saveCount = 0;
    canvas.save();
    saveCount += 1;
    var tx = child.left + child.translationX - child.scrollX;
    var ty = child.top + child.translationY - child.scrollY;
    canvas.translate(tx, ty);
    if (child.scale != 1) {
      canvas.scale(child.scale);
    }
    canvas.clipRect(Rect.fromLTWH(
        child.translationX + child.scrollX, child.translationY + child.scrollY, child.width, child.height));
    child.draw(canvas);
    canvas.restoreToCount(saveCount);
  }

  ///========================管理子View相关方法=======================
  void addView(ChartView view) {
    addViewInner(view);
  }

  void addViews(Iterable<ChartView> views) {
    for (var c in views) {
      c.parent = this;
      children.add(c);
    }
  }

  void addViewInner(ChartView child) {
    if (child.parent != null && child.parent != this) {
      Logger.w("The specified child already has a parent. You must call removeView() on the child's parent first.");
    }
    child.parent = this;
    children.add(child);
  }

  void removeView(ChartView view) {
    if (children.remove(view)) {
      view.parent = null;
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

  @override
  void changeChildToFront(ChartView child) {
    if (children.last == child) {
      return;
    }
    children.remove(child);
    children.add(child);
    if (child.visibility.needSize) {
      requestLayout();
      return;
    }
  }

  @override
  void childVisibilityChange(ChartView child, Visibility old) {
    if (old.needSize != child.visibility.needSize) {
      requestLayout();
    }
  }

  @override
  void childHasTransientStateChanged(ChartView child, bool hasTransientState) {}

  @override
  void clearChildFocus(ChartView child) {
    _mFocusedView = null;
    parent?.clearChildFocus(this);
  }

  @override
  void clearFocus() {
    if (_mFocusedView == null) {
      super.clearFocus();
    } else {
      var focused = _mFocusedView;
      _mFocusedView = null;
      focused?.clearFocus();
    }
  }

  @override
  void unFocus(ChartView focused) {
    if (_mFocusedView == null) {
      super.unFocus(focused);
    } else {
      _mFocusedView?.unFocus(focused);
      _mFocusedView = null;
    }
  }

  ChartView? getFocusedChild() {
    return _mFocusedView;
  }

  @override
  bool hasFocus() {
    return _mFocusedView != null;
  }

  @override
  bool getChildVisibleRect(ChartView child, Rect r, Offset offset) {
    return false;
  }

  @override
  bool isLayoutRequested() => true;

  @override
  void onDescendantInvalidated(ChartView child, ChartView target) {
    parent?.onDescendantInvalidated(this, target);
  }

  @override
  void recomputeViewAttributes(ChartView child) {
    parent?.recomputeViewAttributes(this);
  }

  @override
  void redrawParentCaches() {}

  @override
  void requestChildFocus(ChartView child, ChartView focused) {
    super.unFocus(focused);
    if (_mFocusedView != child) {
      _mFocusedView?.unFocus(focused);
      _mFocusedView = child;
    }
    parent?.requestChildFocus(this, focused);
  }
}
