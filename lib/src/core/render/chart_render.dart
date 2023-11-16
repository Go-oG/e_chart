import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///整个图表渲染的开始
abstract class ChartRender extends RenderNode {
  Context? _context;
  Context get context => _context!;

  final ChartNotifier<Command> _notifier = ChartNotifier(Command.none);

  Lifecycle _lifecycle = Lifecycle.none;

  Lifecycle get lifecycle => _lifecycle;

  ChartRender(
    ChartOption option,
    TickerProvider tickerProvider, [
    double devicePixelRatio = 1,
  ]) {
    _context = Context(this, option, tickerProvider, devicePixelRatio);
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

    if (context.hasEventListener(EventType.rendered)) {
      context.dispatchEvent(RenderedEvent.rendered);
    }
  }

  void onDraw(CCanvas canvas);

  @override
  void requestDraw() {
    if (inDrawing) {
      return;
    }
    _notifier.value = Command.invalidate;
  }

  @override
  void requestLayout() {
    _notifier.value = Command.reLayout;
  }

  @mustCallSuper
  @override
  void measure(double parentWidth, double parentHeight) {
    _context?.animationManager.cancelAllAnimator();


  }

  void onCreate() {
    _lifecycle = Lifecycle.created;
    context.onCreate();

  }

  void onStart() {
    _lifecycle = Lifecycle.starting;
    context.gestureDispatcher.enable();
    context.onStart();
  }

  void onStop() {
    _lifecycle = Lifecycle.stop;
    context.gestureDispatcher.disable();
    clearListener();
    context.onStop();
  }

  @override
  void dispose() {
    _context?.dispatchEvent(ChartDisposeEvent.single);
    _context?.dispose();
    _context = null;
    _notifier.clearListener();
    super.dispose();
    _lifecycle = Lifecycle.dispose;
  }

  void addListener(VoidCallback call) => _notifier.addListener(call);

  void clearListener() => _notifier.clearListener();

  Command get value => _notifier.value;
}

enum Lifecycle {
  none,
  created,
  starting,
  stop,
  dispose,
}
