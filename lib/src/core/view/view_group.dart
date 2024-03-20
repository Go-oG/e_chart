import 'dart:math';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/core/view/attach_info.dart';
import 'package:flutter/rendering.dart';
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
  void forceLayout() {
    super.forceLayout();
    for (var c in children) {
      c.forceLayout();
    }
  }

  ///=========Event和Action分发处理==================
  bool dispatchAction(ChartAction action) {
    return false;
  }

  ///=========布局测量相关============
  ///(模拟FrameLayout)
  @override
  void onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec) {
    final bool measureMatchParentChildren = widthSpec.mode != SpecMode.exactly || heightSpec.mode != SpecMode.exactly;

    List<ChartView> matchParentChildren = [];

    double maxHeight = 0;

    double maxWidth = 0;

    for (var child in _children) {
      if (child.visibility == Visibility.gone) {
        continue;
      }
      measureChildWithMargins(child, widthSpec, 0, heightSpec, 0);
      final lp = child.layoutParams;
      maxWidth = max(maxWidth, child.width + lp.hMargin);
      maxHeight = max(maxHeight, child.height + lp.vMargin);
      if (measureMatchParentChildren) {
        if (lp.width.isMatch || lp.height.isMatch) {
          matchParentChildren.add(child);
        }
      }
    }

    maxWidth += layoutParams.hPadding;
    maxHeight += layoutParams.vPadding;

    for (var child in matchParentChildren) {
      final lp = child.layoutParams;
      final MeasureSpec childWidthMeasureSpec;
      if (lp.width.isMatch) {
        final ww = max(0, width - lp.hPadding - lp.hMargin);
        childWidthMeasureSpec = MeasureSpec.exactly(ww.toDouble());
      } else {
        childWidthMeasureSpec = getChildMeasureSpec(widthSpec, lp.hPadding + lp.hMargin, lp.width);
      }

      final MeasureSpec childHeightMeasureSpec;
      if (lp.height.isMatch) {
        final hh = max(0, height - lp.vPadding - lp.vMargin);
        childHeightMeasureSpec = MeasureSpec.exactly(hh.toDouble());
      } else {
        childHeightMeasureSpec = getChildMeasureSpec(heightSpec, lp.vPadding + lp.vMargin, lp.height);
      }
      child.measure(childWidthMeasureSpec, childHeightMeasureSpec);
    }

    setMeasuredDimension(maxWidth, maxHeight);
  }

  void measureChildWithMargins(ChartView child, MeasureSpec parentWidthMeasureSpec, double widthUsed,
      MeasureSpec parentHeightMeasureSpec, double heightUsed) {
    final LayoutParams lp = child.layoutParams;
    final childWidthMeasureSpec =
        getChildMeasureSpec(parentWidthMeasureSpec, lp.hPadding + lp.hMargin + widthUsed, lp.width);
    final childHeightMeasureSpec =
        getChildMeasureSpec(parentHeightMeasureSpec, lp.vPadding + lp.vMargin + heightUsed, lp.height);
    child.measure(childWidthMeasureSpec, childHeightMeasureSpec);
  }

  void measureChildNotMargins(ChartView child, MeasureSpec parentWidthMeasureSpec, double widthUsed,
      MeasureSpec parentHeightMeasureSpec, double heightUsed) {
    final LayoutParams lp = child.layoutParams;
    final childWidthMeasureSpec = getChildMeasureSpec(parentWidthMeasureSpec, lp.hPadding + widthUsed, lp.width);
    final childHeightMeasureSpec = getChildMeasureSpec(parentHeightMeasureSpec, lp.vPadding + heightUsed, lp.height);
    child.measure(childWidthMeasureSpec, childHeightMeasureSpec);
  }

  ///依据父类的spec 和子类的测量模式以及padding生成 孩子的测量规则
  MeasureSpec getChildMeasureSpec(MeasureSpec spec, double padding, SizeParams childDimension) {
    final specMode = spec.mode;
    double specSize = spec.size;
    double canUseSize = max(0, specSize - padding);

    final childSize = childDimension.convert(canUseSize);
    if (specMode == SpecMode.exactly) {
      if (childDimension.isExactly) {
        return MeasureSpec.exactly(childSize);
      } else if (childDimension.isMatch) {
        return MeasureSpec.exactly(canUseSize);
      }
      return MeasureSpec.atMost(canUseSize);
    }
    if (specMode == SpecMode.atMost) {
      if (childDimension.isExactly) {
        return MeasureSpec.exactly(childSize);
      }
      if (childDimension.isMatch) {
        return MeasureSpec.atMost(canUseSize);
      }
      return MeasureSpec.atMost(canUseSize);
    }
    if (specMode == SpecMode.unLimit) {
      if (childDimension.isExactly) {
        return MeasureSpec.exactly(childSize);
      }
      if (childDimension.isMatch) {
        return MeasureSpec.unLimit(useZeroWhenMeasureSpecModeIsUnLimit ? 0 : canUseSize);
      }
      if (childDimension.isWrap) {
        return MeasureSpec.unLimit(useZeroWhenMeasureSpecModeIsUnLimit ? 0 : canUseSize);
      }
    }
    throw ChartError("unknown status error");
  }

  @override
  void onLayout(bool changed, double left, double top, double right, double bottom) {
    final parentLeft = layoutParams.leftPadding;
    final parentRight = right - left - layoutParams.rightPadding;
    final parentTop = layoutParams.topPadding;
    final parentBottom = bottom - top - layoutParams.bottomPadding;

    for (var child in _children) {
      if (child.visibility == Visibility.gone) {
        continue;
      }
      final lp = child.layoutParams;

      final width = child.width;
      final height = child.height;
      double childLeft = 0;
      double childTop = 0;

      var gravity = lp.gravity;
      if (gravity == Gravity.center) {
        childLeft = parentLeft + (parentRight - parentLeft - width) / 2 + lp.leftMargin - lp.rightMargin;
      } else if (gravity.x == 1) {
        childLeft = parentRight - width - lp.rightMargin;
      } else {
        childLeft = parentLeft + lp.leftMargin;
      }

      if (gravity.y == -1) {
        childTop = parentTop + lp.topMargin;
      } else if (gravity.y == 0) {
        childTop = parentTop + (parentBottom - parentTop - height) / 2 + lp.topMargin - lp.bottomMargin;
      } else if (gravity.y == 1) {
        childTop = parentBottom - height - lp.bottomMargin;
      } else {
        childTop = parentTop + lp.topMargin;
      }

      child.layout(childLeft, childTop, childLeft + width, childTop + height);
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
    if (child.scaleX != 1 || child.scaleY != 1) {
      canvas.scale(child.scaleX, child.scaleY);
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

  void removeAllViews() {
    if (children.isEmpty) {
      return;
    }
    var old = _children;
    _children = [];
    for (var item in old) {
      item.parent = null;
    }
    requestLayout();
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
