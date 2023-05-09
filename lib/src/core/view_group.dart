import 'package:flutter/material.dart';

import 'context.dart';
import 'view.dart';

/// ViewGroup
abstract class ViewGroup extends View implements ViewParent {
  final List<View> _children = [];

  ViewGroup({super.paint, super.zIndex});

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
  void measure(double parentWidth, double parentHeight) {
    if (measureCompleted && (boundRect.width - parentWidth).abs() < 1 && (boundRect.height - parentHeight).abs() < 1) {
      return;
    }
    Size size = onMeasure(parentWidth, parentHeight);
    oldBoundRect = boundRect;
    boundRect = Rect.fromLTWH(0, 0, size.width, size.height);
    for (var element in children) {
      element.measure(size.width, size.height);
    }
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    for (var element in children) {
      element.layout(element.translationX, element.translationY, element.width, element.height);
    }
  }

  @override
  void dispatchDraw(Canvas canvas) {
    List<View> childList = List.from(children);
    childList.sort((a, b) {
      return a.zIndex.compareTo(b.zIndex);
    });
    for (var element in childList) {
      int count = canvas.getSaveCount();
      drawChild(element, canvas);
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
    List<View> first = List.from(children.getRange(
      0,
      index,
    ));
    List<View> end = List.from(children.getRange(index, children.length));
    children.clear();
    children.addAll(first);
    children.add(child);
    children.addAll(end);
    for (int i = 1; i < children.length; i++) {
      children[i].index = i;
    }
  }

  void clearChildren() {
    children.clear();
  }

  @override
  Rect getGlobalAreaBounds() {
    if(parent==null){return boundRect;}
    Rect parentRect=parent!.getGlobalAreaBounds();
    double l=parentRect.left+boundRect.left;
    double t=parentRect.top+boundRect.top;
    return Rect.fromLTWH(l, t, boundRect.width, boundRect.height);
  }

}

abstract class ViewParent {

  void parentInvalidate();

  void requestLayout();

  void clearChildFocus(View child);

  void changeChildToFront(View child);

  Rect getGlobalAreaBounds();


}
