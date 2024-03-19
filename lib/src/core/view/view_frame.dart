import 'dart:ui';

import 'package:flutter/animation.dart';

import '../model/visibility.dart';

///存储View中和视图有关联的数据
mixin ViewFrame {
  double _left = 0;

  double get left => _left;

  set left(double l) => _left = l;

  double _top = 0;

  double get top => _top;

  set top(double t) => _top = t;

  double _right = 0;

  double get right => _right;

  set right(double r) => _right = r;

  double _bottom = 0;

  double get bottom => _bottom;

  set bottom(double b) => _bottom = b;

  double _globalLeft = 0;

  double get globalLeft => _globalLeft;

  set globalLeft(double gl) => _globalLeft = gl;

  double _globalTop = 0;

  double get globalTop => _globalTop;

  set globalTop(double gt) => _globalTop = gt;

  double _measureWidth = 0;

  double get measureWidth => _measureWidth;

  double _measureHeight = 0;

  double get measureHeight => _measureHeight;

  void setMeasuredDimension(double measureWidth, double measureHeight) {
    _measureWidth = measureWidth;
    _measureHeight = measureHeight;
  }

  double get centerX => width / 2.0;

  double get centerY => height / 2.0;

  double get width {
    return right - left;
  }

  double get height {
    return bottom - top;
  }

  double get shortSide {
    return width > height ? height : width;
  }

  double get longSide {
    return width >= height ? width : height;
  }

  Rect get boxBound {
    return Rect.fromLTRB(left, top, right, bottom);
  }

  Rect get globalBound {
    return Rect.fromLTWH(globalLeft, globalTop, width, height);
  }

  Offset toLocal(Offset global) {
    return Offset(global.dx - _globalLeft, global.dy - _globalTop);
  }

  Offset toGlobal(Offset local) {
    return Offset(local.dx + _globalLeft, local.dy + _globalTop);
  }

  double _scrollX = 0;

  double get scrollX => _scrollX;

  set scrollX(double sx) => _scrollX = sx;

  double _scrollY = 0;

  double get scrollY => _scrollY;

  set scrollY(double sy) => _scrollY = sy;

  void setScroll(double? sx, double? sy) {
    if (sx != null) {
      _scrollX = sx;
    }
    if (sy != null) {
      _scrollY = sy;
    }
  }

  void scrollTo(double sx, double sy) {
    _scrollX = sx;
    _scrollY = sy;
  }

  void scrollOff(double dx, double dy) {
    _scrollX += dx;
    _scrollY += dy;
  }

  double _translationX = 0;

  double get translationX => _translationX;

  set translationX(double tx) => _translationX = tx;

  double _translationY = 0;

  double get translationY => _translationY;

  set translationY(double ty) => _translationY = ty;

  double _scaleX = 1;

  double get scaleX => _scaleX;

  set scaleX(double sx) => _scaleX = sx;

  double _scaleY = 1;

  double get scaleY => _scaleY;

  set scaleY(double sy) => _scaleY = sy;

  set scale(double scale) {
    scaleX = scaleY = scale;
  }

  Visibility _visibility = Visibility.visible;

  bool setVisibility(Visibility vb) {
    if (_visibility == vb) {
      return false;
    }
    _visibility = vb;
    return true;
  }

  Visibility get visibility {
    return _visibility;
  }

  bool diff(double l, double t, double r, double b) {
    return l != left || t != top || r != right || b != bottom;
  }

  bool diffSize(double l, double t, double r, double b) {
    return (r - l) != width || (b - t) != height;
  }

  ///获取当前视图自身的可视区域范围
  ///当前可视区域范围只和Scroll有关
  Rect get selfViewPort {
    return Rect.fromLTRB(scrollX, scrollY, width, height);
  }
}
