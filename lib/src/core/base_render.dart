import 'package:flutter/material.dart';
import '../chart.dart';
import 'context.dart';
import 'view_group.dart';

abstract class BaseRender extends ChangeNotifier implements CustomPainter, ViewParent {
  late final Context context;
  bool useSaveLayer = false;
  bool _inLayout = false;
  bool _inDrawing = false;
  Rect _boundRect = Rect.zero;

  Size get size => _boundRect.size;

  BaseRender(ChartConfig config, TickerProvider tickerProvider, [double devicePixelRatio = 1]) {
    context = Context(this, config, tickerProvider,devicePixelRatio);
    context.init();
  }

  @override
  SemanticsBuilderCallback? get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) => false;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    for (var c in context.renderList) {
      if (c.isDirty) {
        return true;
      }
    }
    return false;
  }

  @protected
  @override
  void paint(Canvas canvas, Size size) {
    if (_inLayout) {
      return;
    }
    if (_boundRect.height != size.height || _boundRect.width != size.width) {
      _inLayout = true;
      _boundRect = Rect.fromLTWH(0, 0, size.width, size.height);
      try {
        onMeasure(size.width, size.height);
        onLayout(size.width, size.height);
      } catch (e) {
        rethrow;
      } finally {
        _inLayout = false;
      }
    }
    if (_inDrawing) {
      return;
    }
    _inDrawing = true;
    try {
      ///限制绘制范围在当前控件之内
      if (useSaveLayer) {
        canvas.saveLayer(_boundRect, Paint());
      } else {
        canvas.save();
        canvas.clipRect(_boundRect);
      }
      onDraw(canvas);
      canvas.restore();
    } catch (e) {
      rethrow;
    } finally {
      _inDrawing = false;
    }
    _inDrawing = false;
  }

  @override
  Rect getGlobalAreaBounds() {
    return _boundRect;
  }

  @override
  bool? hitTest(Offset position) => true;

  @override
  void parentInvalidate() {
    updateUI();
  }

  @override
  void requestLayout() {
    if (_inLayout) {
      return;
    }
    _boundRect = Rect.zero;
    updateUI();
  }

  void updateUI({bool animator = false}) {
    if (_inDrawing || _inLayout) {
      debugPrint('阻挡绘制 $_inDrawing  $_inLayout');
      return;
    }
    notifyListeners();
  }

  void destroy() {
    ///changeNotifier
    context.destroy();
    dispose();
  }

  void onMeasure(double parentWidth, double parentHeight);

  void onLayout(double width, double height);

  void onDraw(Canvas canvas);
}
