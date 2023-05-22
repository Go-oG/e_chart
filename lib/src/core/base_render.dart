import 'package:e_chart/src/core/view.dart';
import 'package:flutter/material.dart';
import '../chart.dart';
import 'context.dart';
import 'view_group.dart';

abstract class BaseRender extends ChangeNotifier implements CustomPainter, ViewParent {
  late final Context context;
  bool _inLayout = false;
  bool _inDrawing = false;
  Size? _oldSize;

  Size get size => _oldSize!;

  BaseRender(ChartConfig config, TickerProvider tickerProvider) {
    context = Context(this, config, tickerProvider);
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
    canvas.drawColor(Colors.white, BlendMode.src);
    if (_oldSize == null || size.height != _oldSize!.height || size.width != _oldSize!.width) {
      _inLayout = true;
      _oldSize = size;
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
      onDraw(canvas);
    } catch (e) {
      rethrow;
    } finally {
      _inDrawing = false;
    }
    _inDrawing = false;
  }

  @override
  void changeChildToFront(View child) {}

  @override
  void clearChildFocus(View child) {}

  @override
  Rect getGlobalAreaBounds() {
    if (_oldSize == null) {
      return Rect.zero;
    }
    return Rect.fromLTWH(0, 0, _oldSize!.width, _oldSize!.height);
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
    _oldSize = null;
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
    context.destroy();
  }

  void onMeasure(double parentWidth, double parentHeight);

  void onLayout(double width, double height);

  void onDraw(Canvas canvas);
}
