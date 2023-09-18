import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../utils/uuid_util.dart';
import '../render/ccanvas.dart';
import '../model/view_size.dart';

///渲染节点
abstract class RenderNode with ViewSize {
  final String id = randomId();

  RenderNode? _parent;

  RenderNode? get parent => _parent;

  @protected
  set parent(RenderNode? p) => _parent = p;

  Paint mPaint = Paint();

  ///索引层次
  int zLevel = -1;

  bool inMeasure = false;
  bool inLayout = false;

  bool inDrawing = false;

  bool _dirty = true;

  bool _forceLayout = true;

  bool get forceLayout => _forceLayout;

  @protected
  set forceLayout(bool f) => _forceLayout = f;

  void measure(double parentWidth, double parentHeight);

  void layout(double left, double top, double right, double bottom);

  void draw(CCanvas canvas);

  void invalidate() {
    if (inDrawing) {
      return;
    }
    markDirty();
    parent?.invalidate();
  }

  void markDirty() {
    _dirty = true;
  }

  void markDirtyWithChild(){
    _dirty=true;
  }

  bool get isDirty => _dirty;

  void clearDirty() {
    _dirty = false;
  }

  void requestLayout() {
    if (inLayout) {
      return;
    }
    markDirty();
    parent?.requestLayout();
  }

  void requestLayoutSelf() {
    if (inLayout) {
      return;
    }
    markDirty();
    _forceLayout = true;
    layout(left, top, right, bottom);
    invalidate();
  }

  Rect getGlobalBounds() {
    if (parent == null) {
      return boxBound;
    }
    var boundRect = boxBound;
    Rect parentRect = parent!.getGlobalBounds();
    double l = parentRect.left + boundRect.left;
    double t = parentRect.top + boundRect.top;
    return Rect.fromLTWH(l, t, boundRect.width, boundRect.height);
  }

  bool _show = true;

  bool get isShow => _show;

  bool get notShow => !_show;

  void show() {
    if (_show) {
      return;
    }
    _show = true;
    invalidate();
  }

  void hide() {
    if (!_show) {
      _show = false;
      invalidate();
    }
  }

  void dispose() {}

  ///=====Debug 相关方法===============
  void debugDraw(CCanvas canvas, Offset offset, {Color color = const Color(0xFF673AB7), bool fill = true, num r = 6}) {
    if (!kDebugMode) {
      return;
    }
    Paint mPaint = Paint();
    mPaint.color = color;
    mPaint.style = fill ? PaintingStyle.fill : PaintingStyle.stroke;
    canvas.drawCircle(offset, r.toDouble(), mPaint);
  }

  void debugDrawRect(CCanvas canvas, Rect rect, {Color color = const Color(0xFF673AB7), bool fill = false}) {
    if (!kDebugMode) {
      return;
    }
    Paint mPaint = Paint();
    mPaint.color = color;
    mPaint.style = fill ? PaintingStyle.fill : PaintingStyle.stroke;
    mPaint.strokeWidth = 1;
    canvas.drawRect(rect, mPaint);
  }

  void debugDrawRulerLine(CCanvas canvas, {Color color = const Color(0xFF000000)}) {
    if (!kDebugMode) {
      return;
    }
    Paint mPaint = Paint();
    mPaint.color = color;
    mPaint.style = PaintingStyle.stroke;
    mPaint.strokeWidth = 1;
    canvas.drawLine(Offset(width / 2, 0), Offset(width / 2, height), mPaint);
    canvas.drawLine(Offset(0, height / 2), Offset(width, height / 2), mPaint);
  }

  void debugDrawPath(CCanvas canvas, Path path, {Color color = const Color(0xFF673AB7), bool fill = false}) {
    if (!kDebugMode) {
      return;
    }
    Paint mPaint = Paint();
    mPaint.color = color;
    mPaint.style = fill ? PaintingStyle.fill : PaintingStyle.stroke;
    mPaint.strokeWidth = 1;
    canvas.drawPath(path, mPaint);
  }
}
