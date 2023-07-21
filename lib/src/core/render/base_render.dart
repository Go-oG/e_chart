import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

abstract class BaseRender extends ChangeNotifier implements CustomPainter, ViewParent {
  late final Context context;

  ///控制是使用saveLayer 还是 clipRect
  bool useSaveLayer = false;

  ///标识是否在布局
  bool _inLayout = false;

  ///标识是否在绘制
  bool _inDrawing = false;

  ///Canvas 画布大小
  Rect _boundRect = Rect.zero;

  Size get size => _boundRect.size;

  BaseRender(
    ChartConfig config,
    TickerProvider tickerProvider, [
    double devicePixelRatio = 1,
  ]) {
    context = Context(this, config, tickerProvider, devicePixelRatio);
    context.onCreate();
  }

  @override
  SemanticsBuilderCallback? get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) => false;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    for (var c in context.coordList) {
      if (c.isDirty) {
        return true;
      }
    }
    return false;
  }

  final Stopwatch _stopwatch = Stopwatch();

  @protected
  @override
  void paint(Canvas canvas, Size size) {
    if (_inLayout) {
      return;
    }
    if (_boundRect.height != size.height || _boundRect.width != size.width) {
      _stopwatch.start();
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
      _stopwatch.stop();
      logPrint('Layout耗时:${_stopwatch.elapsedMilliseconds}');
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

  void onStart() {
    context.onStart();
  }

  void onStop() {
    context.onStop();
  }

  @override
  void dispose() {
    context.destroy();
    super.dispose();
  }

  void onMeasure(double parentWidth, double parentHeight);

  void onLayout(double width, double height);

  void onDraw(Canvas canvas);
}
