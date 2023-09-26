import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///整个图表渲染的开始
abstract class ChartRender extends RenderNode {
  late final Context context;
  final ChartNotifier<Command> _notifier = ChartNotifier(Command.none);

  ChartRender(
    ChartOption option,
    TickerProvider tickerProvider, [
    double devicePixelRatio = 1,
  ]) {
    context = Context(this, option, tickerProvider, devicePixelRatio);
    context.onCreate();
  }

  @override
  void draw(CCanvas canvas) {
    inDrawing = true;
    try {
      onDraw(canvas);
    } catch (e) {
      Logger.e(e);
      rethrow;
    } finally {
      inDrawing = false;
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

  void onDraw(CCanvas canvas);

  @override
  void invalidate() {
    if (inDrawing) {
      return;
    }
    _notifier.value = Command.invalidate;
  }

  @override
  void requestLayout() {
    _notifier.value = Command.reLayout;
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

  void addListener(VoidCallback call) => _notifier.addListener(call);

  void clearListener() => _notifier.clearListener();

  Command get value => _notifier.value;
}
