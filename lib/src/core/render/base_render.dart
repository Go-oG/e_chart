import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

abstract class BaseRender extends ChartNotifier<Command> implements ViewParent {
  late final Context context;

  ///标识是否在绘制
  bool _inDrawing = false;

  ///Canvas 画布大小
  Rect _boundRect = Rect.zero;

  Size get size => _boundRect.size;

  BaseRender(
    ChartOption config,
    TickerProvider tickerProvider, [
    double devicePixelRatio = 1,
  ]) : super(Command.none) {
    context = Context(this, config, tickerProvider, devicePixelRatio);
    context.onCreate();
  }

  void draw(CCanvas canvas, Size size) {
    _inDrawing = true;
    try {
      ///限制绘制范围在当前控件之内
      // if (useSaveLayer) {
      //   canvas.saveLayer(_boundRect, Paint());
      // } else {
      //   canvas.save();
      //   canvas.clipRect(_boundRect);
      // }
      onDraw(canvas);
    //  canvas.restore();
    } catch (e) {
      rethrow;
    } finally {
      _inDrawing = false;
    }
    var queue = context.getAndResetAnimationQueue();
    for (var node in queue) {
      try {
        node.start(context);
      } catch (e) {
        Logger.e(e);
      }
    }
  }

  void onMeasure(double parentWidth, double parentHeight);

  void onLayout(double width, double height);

  void onDraw(CCanvas canvas);

  @override
  Rect getGlobalAreaBounds() {
    return _boundRect;
  }

  @override
  void parentInvalidate() {
    updateUI();
  }

  @override
  void requestLayout() {
    _boundRect = Rect.zero;
    value = Command.reLayout;
  }

  void updateUI() {
    if (_inDrawing) {
      debugPrint('阻挡绘制 $_inDrawing');
      return;
    }
    value = Command.invalidate;
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
}
