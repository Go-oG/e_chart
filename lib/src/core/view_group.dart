import 'dart:math';

import 'package:flutter/material.dart';

import 'context.dart';
import 'view.dart';

/// ViewGroup
abstract class ViewGroup extends View implements ViewParent {
  final List<View> _children = [];

  ViewGroup();

  @override
  void attach(Context context, ViewParent parent) {
    super.attach(context, parent);
    for (var element in _children) {
      element.attach(context, this);
    }
  }

  @override
  void detach() {
    super.detach();
    for (var element in _children) {
      element.detach();
    }
  }

  @override
  void changeChildToFront(View child) {
    int index = children.indexOf(child);
    if (index != -1) {
      children.removeAt(index);
    }
    _addViewInner(child, -1);
    requestLayout();
  }

  @override
  void clearChildFocus(View child) {
    invalidate();
  }

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    double maxHeight = 0;
    double maxWidth = 0;
    num php = layoutParams.leftPadding.convert(parentWidth) + layoutParams.rightPadding.convert(parentWidth);
    num pvp = layoutParams.topPadding.convert(parentHeight) + layoutParams.bottomPadding.convert(parentHeight);
    double pw = parentWidth - php;
    double ph = parentHeight - pvp;
    for (var child in children) {
      child.measure(pw, ph);
      final LayoutParams lp = child.layoutParams;
      num hp = lp.leftMargin.convert(pw) + lp.rightMargin.convert(pw);
      num vp = lp.topMargin.convert(ph) + lp.bottomMargin.convert(ph);
      maxWidth = max(maxWidth, child.width + hp);
      maxHeight = max(maxHeight, child.height + vp);
    }
    maxWidth += php;
    maxHeight += pvp;
    maxWidth = min(maxWidth, parentWidth);
    maxHeight = min(maxHeight, parentHeight);

    php = layoutParams.leftPadding.convert(maxWidth) + layoutParams.rightPadding.convert(maxWidth);
    pvp = layoutParams.topPadding.convert(maxHeight) + layoutParams.bottomPadding.convert(maxHeight);
    pw = maxWidth - php;
    ph = maxHeight - pvp;

    for (var child in children) {
      final LayoutParams lp = child.layoutParams;
      num hm = lp.leftMargin.convert(maxWidth) + lp.rightMargin.convert(maxWidth);
      num vm = lp.topMargin.convert(maxHeight) + lp.bottomMargin.convert(maxHeight);
      double childWidth = child.width;
      if (lp.width.number == LayoutParams.matchParent) {
        childWidth = max(0, pw - hm);
      }
      double childHeight = child.height;
      if (lp.height.number == LayoutParams.matchParent) {
        childHeight = max(0, ph - vm);
      }
      child.measure(childWidth, childHeight);
    }

    return Size(maxWidth, maxHeight);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    double parentLeft = layoutParams.leftPadding.convert(width);
    double parentTop = layoutParams.topPadding.convert(height);
    for (var child in children) {
      LayoutParams lp = child.layoutParams;
      double childLeft = parentLeft + lp.leftMargin.convert(width);
      double childTop = parentTop + lp.topMargin.convert(height);
      child.layout(childLeft, childTop, childLeft + child.width, childTop + child.height);
    }
  }

  @override
  void dispatchDraw(Canvas canvas) {
    for (var child in children) {
      int count = canvas.getSaveCount();
      drawChild(child, canvas);
      if (canvas.getSaveCount() != count) {
        throw FlutterError('you should call canvas.restore when after call canvas.save');
      }
    }
  }

  @override
  void parentInvalidate() {
    if (inDrawing) {
      return;
    }
    markDirty(); //标记为需要重绘
    parent?.parentInvalidate();
  }

  /// 负责绘制单独的一个ChildView，同时负责Canvas的坐标的正确转换
  /// 如果在方法中调用了[invalidate]则返回true
  bool drawChild(View child, Canvas canvas) {
    return child.drawSelf(canvas, this);
  }

  ///========================管理子View相关方法=======================
  void addView(View view, {int index = -1}) {
    _addViewInner(view, index);
    requestLayout();
  }

  void removeView(View view) {
    children.remove(view);
  }

  View getChildAt(int index) {
    return children[index];
  }

  List<View> get children {
    return _children;
  }

  bool hasChildView(View view) {
    for (var element in _children) {
      if (element == view) {
        return true;
      }
    }
    return false;
  }

  void _addViewInner(View child, int index) {
    if (child.parent != null && child.parent != this) {
      throw FlutterError("The specified child already has a parent. You must call removeView() on the child's parent first.");
    }
    _addInArray(child, index);
  }

  void _addInArray(View child, int index) {
    if (index >= children.length || index < 0 || children.isEmpty) {
      children.add(child);
      return;
    }
    children.insert(index, child);
  }

  void clearChildren() {
    children.clear();
  }

  @override
  Rect getGlobalAreaBounds() {
    if (parent == null) {
      return boundRect;
    }
    Rect parentRect = parent!.getGlobalAreaBounds();
    double l = parentRect.left + boundRect.left;
    double t = parentRect.top + boundRect.top;
    return Rect.fromLTWH(l, t, boundRect.width, boundRect.height);
  }
}

abstract class ViewParent {
  void parentInvalidate();

  void requestLayout();

  Rect getGlobalAreaBounds();
}
