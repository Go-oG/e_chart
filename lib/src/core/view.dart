import 'package:flutter/material.dart';

import '../charts/series.dart';
import '../component/tooltip/tool_tip.dart';
import '../component/tooltip/tool_tip_item.dart';
import '../component/tooltip/tool_tip_listener.dart';
import '../functions.dart';
import 'context.dart';
import 'draw_node.dart';
import 'view_group.dart';

abstract class View extends DrawNode implements ToolTipListener {
  late Context context;
  int index = 0;

  Rect boundRect = const Rect.fromLTRB(0, 0, 0, 0);
  Rect oldBoundRect = const Rect.fromLTRB(0, 0, 0, 0); //记录旧的边界位置，实现动画相关的计算
  Rect _globalBoundRect = Rect.zero;
  ViewParent? _parent;

  //缩放
  double _scaleX = 1;
  double _scaleY = 1;

  //滚动
  double _scrollX = 0;
  double _scrollY = 0;

  // 平移
  double _translationX = 0;
  double _translationY = 0;

  late Paint paint;

  int zIndex = 0;
  bool inLayout = false;
  bool inDrawing = false;
  bool _dirty = false; // 标记视图区域是否 需要重绘

  @protected
  bool layoutCompleted = false;

  @protected
  bool measureCompleted = false;

  @protected
  bool forceLayout = false;

  @protected
  bool forceMeasure = false;

  View({Paint? paint, this.zIndex = 0}) {
    if (paint != null) {
      this.paint = paint;
    } else {
      this.paint = Paint();
    }
  }

  ValueCallback<int>? _viewRefreshCallback;

  ChartSeries? _series;

  void bindSeries(ChartSeries series) {
    _series = series;
    _viewRefreshCallback ??= (value) {
      if (value == ChartSeries.actionInvalidate.value) {
        invalidate();
      } else if(value==ChartSeries.actionReLayout.value) {
        requestLayout();
      }
    };
    series.addListener(_viewRefreshCallback!);
  }

  void unBindSeries() {
    if (_viewRefreshCallback != null) {
      _series?.removeListener(_viewRefreshCallback!);
    }
    _series = null;
  }

  void attach(Context context, ViewParent parent) {
    this.context = context;
    _parent = parent;
    if (_series != null && _series!.tooltip != null) {
      context.registerToolTip(this);
    }
    onAttach();
  }

  void onAttach() {}

  void detach() {
    context.unRegisterToolTip(this);
    onDetach();
  }

  void onDetach() {}

  @override
  void measure(double parentWidth, double parentHeight) {
    bool force = forceMeasure || forceLayout;
    bool minDiff = (boundRect.width - parentWidth).abs() <= 0.00001 && (boundRect.height - parentHeight).abs() <= 0.00001;
    if (measureCompleted && minDiff && !force) {
      return;
    }
    oldBoundRect = boundRect;
    Size size = onMeasure(parentWidth, parentHeight);
    boundRect = Rect.fromLTWH(0, 0, size.width, size.height);
    measureCompleted = true;
  }

  Size onMeasure(double parentWidth, double parentHeight) {
    return Size(parentWidth, parentHeight);
  }

  @override
  void layout(double left, double top, double right, double bottom) {
    if (layoutCompleted && !forceLayout) {
      bool b1 = (left - boundRect.left).abs() < 1;
      bool b2 = (top - boundRect.top).abs() < 1;
      bool b3 = (right - boundRect.right).abs() < 1;
      bool b4 = (bottom - boundRect.bottom).abs() < 1;
      if (b1 && b2 && b3 && b4) {
        return;
      }
    }

    inLayout = true;
    oldBoundRect = boundRect;
    boundRect = Rect.fromLTRB(left, top, right, bottom);

    if (parent == null) {
      _globalBoundRect = boundRect;
    } else {
      Rect parentRect = parent!.getGlobalAreaBounds();
      double l = parentRect.left + boundRect.left;
      double t = parentRect.top + boundRect.top;
      _globalBoundRect = Rect.fromLTWH(l, t, boundRect.width, boundRect.height);
    }
    onLayout(left, top, right, bottom);
    inLayout = false;
    forceLayout = false;
    layoutCompleted = true;
    onLayoutEnd();
  }

  void onLayout(double left, double top, double right, double bottom) {}
  void onLayoutEnd(){}

  void debugDraw(Canvas canvas, Offset offset) {
    Paint mPaint = Paint();
    mPaint.color = Colors.red;
    mPaint.style = PaintingStyle.fill;
    canvas.drawCircle(offset, 3, mPaint);
  }

  void debugDraw2(Canvas canvas) {
    Paint mPaint = Paint();
    mPaint.color = Colors.red;
    mPaint.style = PaintingStyle.fill;
    canvas.drawRect(areaBounds, mPaint);
  }

  @mustCallSuper
  @override
  void draw(Canvas canvas) {
    inDrawing = true;
    onDrawPre();
    final int sx = _scrollX.toInt();
    final int sy = _scrollY.toInt();
    if ((sx | sy) == 0) {
      drawBackground(canvas, 1);
    } else {
      canvas.translate(_scrollX, _scrollY);
      drawBackground(canvas, 1);
      canvas.translate(-_scrollX, -_scrollY);
    }
    onDraw(canvas);
    dispatchDraw(canvas);
    onDrawEnd(canvas);
    onDrawHighlight(canvas);
    onDrawForeground(canvas);
    inDrawing = false;
  }

  @protected
  bool drawSelf(Canvas canvas, ViewGroup parent) {
    double sx = 0;
    double sy = 0;
    computeScroll();
    sx = _scrollX;
    sy = _scrollY;
    canvas.save();
    canvas.translate(left - sx, top - sy);
    canvas.scale(scaleX, scaleY);
    canvas.clipRect(Rect.fromLTRB(sx, sy, sx + width, sy + height));
    draw(canvas);
    canvas.restore();
    return false;
  }

  void drawBackground(Canvas canvas, double animatorPercent) {}

  ///绘制时最先调用的方法，可以在这里面更改相关属性从而实现动画视觉效果
  void onDrawPre() {}

  void onDraw(Canvas canvas) {}

  void onDrawEnd(Canvas canvas) {}

  ///用于ViewGroup覆写
  void dispatchDraw(Canvas canvas) {}

  /// 覆写实现重绘高亮相关的
  void onDrawHighlight(Canvas canvas) {}

  ///实现绘制前景色
  void onDrawForeground(Canvas canvas) {}

  ViewParent? get parent {
    return _parent;
  }

  void invalidate() {
    if (inDrawing) {
      return;
    }
    markDirty(); //标记为需要重绘
    if (_parent == null) {
      debugPrint('重绘失败：Paren is NULL');
    }
    _parent?.parentInvalidate();
  }

  void invalidateWithAnimator() {
    invalidate();
  }

  void requestLayout() {
    if (inLayout) {
      return;
    }
    parent?.requestLayout();
  }

  void markDirty() {
    _dirty = true;
  }

  void clearDirty() {
    _dirty = false;
  }

  void scrollTo(double x, double y, {bool redraw = false}) {
    if (x == _scrollX && y == _scrollY) {
      return;
    }
    double oldX = _scrollX;
    double oldY = _scrollY;
    _scrollX = x;
    _scrollY = y;
    onScrollChanged(x, y, oldX, oldY);
    if (redraw) {
      invalidate();
    }
  }

  void scrollBy(int x, int y, {bool redraw = false}) {
    scrollTo(_scrollX + x, _scrollY + y, redraw: redraw);
  }

  void onScrollChanged(double scrollX, double scrollY, double oldScrollX, double oldScrollY) {}

  ///======================= 事件处理=======================

  // 判断当前给定点是否能落在自身区域里
  bool hitTest(Offset localPosition) {
    return localPosition.dx >= 0 && localPosition.dx <= width && localPosition.dy >= 0 && localPosition.dy <= height;
  }

  ///======================处理ToolTip========================
  @override
  ToolTip? getToolTip() {
    return _series?.tooltip;
  }

  @override
  List<ToolTipItem> onCreatedToolTipItem(Offset globalOffset) {
    return [];
  }

  @override
  bool toolTipInArea(Offset globalOffset) {
    return globalAreaBound.contains(globalOffset);
  }

  /// ====================普通属性函数=======================================

  double get width => boundRect.width;

  double get height => boundRect.height;

  // 返回当前View在父Parent中的位置坐标
  double get left => boundRect.left;

  double get top => boundRect.top;

  double get right => boundRect.right;

  double get bottom => boundRect.bottom;

  // 返回自身的中心点坐标
  double get centerX => width / 2.0;

  double get centerY => height / 2.0;

  //返回其矩形边界
  Rect get areaBounds => boundRect;

  Rect get globalAreaBound => _globalBoundRect;

  Offset toLocalOffset(Offset globalOffset) {
    return Offset(globalOffset.dx - _globalBoundRect.left, globalOffset.dy - _globalBoundRect.top);
  }

  Offset toGlobalOffset(Offset localOffset) {
    return Offset(localOffset.dx + _globalBoundRect.left, localOffset.dy + _globalBoundRect.top);
  }

  set scaleX(double scaleX) {
    if (_scaleX == scaleX) {
      return;
    }
    _scaleX = scaleX;
    invalidate();
  }

  set scaleY(double scaleY) {
    if (_scaleY == scaleY) {
      return;
    }
    _scaleY = scaleY;
    invalidate();
  }

  void setScale(double x, double y) {
    if (x == _scaleX && y == _scaleY) {
      return;
    }
    _scaleX = x;
    _scaleY = y;
    invalidate();
  }

  double get scaleX {
    return _scaleX;
  }

  double get scaleY {
    return _scaleY;
  }

  set scrollX(double scrollX) {
    if (_scrollX == scrollX) {
      return;
    }
    _scrollX = scrollX;
    invalidate();
  }

  set scrollY(double scrollY) {
    if (_scrollY == scrollY) {
      return;
    }
    _scrollY = scrollY;
    invalidate();
  }

  void setScroll(double x, double y) {
    if (x == _scrollX && y == _scrollY) {
      return;
    }
    _scrollX = x;
    _scrollY = y;
    invalidate();
  }

  double get scrollX {
    return _scrollX;
  }

  double get scrollY {
    return _scrollY;
  }

  set translationX(double translationX) {
    if (_translationX == translationX) {
      return;
    }
    _translationX = translationX;
    requestLayout();
  }

  set translationY(double translationY) {
    if (_translationY == translationY) {
      return;
    }
    _translationY = translationY;
    requestLayout();
  }

  void setTranslation(double x, double y) {
    if (x == _translationX && y == _translationY) {
      return;
    }
    _translationX = x;
    _translationY = y;
    requestLayout();
  }

  double get translationX {
    return _translationX;
  }

  double get translationY {
    return _translationY;
  }

  bool get isDirty {
    return _dirty;
  }

  void computeScroll() {}
}
