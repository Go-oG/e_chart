import 'package:e_chart/e_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

abstract class ChartView extends RenderNode {
  Context? _context;

  Context get context => _context!;

  ///绘图缓存(可以优化绘制效率)
  LayerHandle<Layer> cacheLayer = LayerHandle();

  ///=========生命周期回调方法开始==================
  ///所有的生命周期函数都是由Context进行调用

  ///该回调只会发生在视图创建后，且只会回调一次
  ///绝大部分子类都不应该覆写该方法
  void create(Context context, RenderNode parent) {
    _context = context;
    this.parent = parent;
    onCreate();
  }

  ///创建后的回调，在该方法后可以安全的使用Context
  void onCreate() {}

  ///视图进入已开始状态
  void onStart() {}

  ///视图进入停止状态
  void onStop() {}

  ///由Context负责回调
  ///当该方法被调用时标志着当前View即将被销毁
  ///你可以在这里进行资源释放等操作
  void destroy() {
    if (cacheLayer.layer != null) {
      cacheLayer.layer == null;
    }
    unBindSeries();
    onDestroy();
    _context = null;
  }

  void onDestroy() {}

  ///=======布局测量相关方法==============
  @override
  void measure(double parentWidth, double parentHeight) {
    if (inMeasure || inLayout) {
      return;
    }
    inMeasure = true;
    bool minDiff = (boxBound.width - parentWidth).abs() <= 0.00001 && (boxBound.height - parentHeight).abs() <= 0.00001;
    if (minDiff && !forceLayout) {
      inMeasure = false;
      return;
    }
    oldBound = boxBound;
    margin.clear();
    padding.clear();
    Size size = onMeasure(parentWidth, parentHeight);
    boundRect = Rect.fromLTWH(0, 0, size.width, size.height);
    inMeasure = false;
  }

  Size onMeasure(double parentWidth, double parentHeight) {
    LayoutParams lp = layoutParams;
    double w = lp.width.convert(parentWidth);
    double h = lp.height.convert(parentHeight);
    if (lp.width.isWrap) {
      padding.left = lp.getLeftPadding(parentWidth);
      padding.right = lp.getRightPadding(parentWidth);
      w += padding.horizontal;
    }
    if (lp.height.isWrap) {
      padding.top = lp.getTopPadding(parentHeight);
      padding.bottom = lp.getBottomPadding(parentHeight);
      h += padding.vertical;
    }
    return Size(w, h);
  }

  @override
  void layout(double left, double top, double right, double bottom) {
    if (inLayout) {
      Logger.i("$runtimeType layout inLayout:$inLayout  inMeasure:$inMeasure");
      return;
    }
    inLayout = true;
    if (!forceLayout && boxBound.width > 0 && boxBound.height > 0) {
      bool b1 = (left - boxBound.left).abs() < 1;
      bool b2 = (top - boxBound.top).abs() < 1;
      bool b3 = (right - boxBound.right).abs() < 1;
      bool b4 = (bottom - boxBound.bottom).abs() < 1;
      if (b1 && b2 && b3 && b4) {
        inLayout = false;
        return;
      }
    }

    oldBound = boxBound;
    boundRect = Rect.fromLTRB(left, top, right, bottom);
    globalBound = getGlobalBounds();
    onLayout(left, top, right, bottom);
    onLayoutEnd();
    inLayout = false;
    forceLayout = false;
  }

  void onLayout(double left, double top, double right, double bottom) {}

  void onLayoutEnd() {}

  @mustCallSuper
  @override
  void draw(CCanvas canvas) {
    inDrawing = true;
    if (notShow) {
      inDrawing = false;
      clearDirty();
      return;
    }
    onDrawPre();
    onDrawBackground(canvas);
    onDraw(canvas);
    dispatchDraw(canvas);
    onDrawEnd(canvas);
    onDrawHighlight(canvas);
    onDrawForeground(canvas);
    inDrawing = false;
    clearDirty();
  }

  @protected
  bool drawSelf(CCanvas canvas, ChartViewGroup parent) {
    if (notShow) {
      return false;
    }
    var layer = cacheLayer.layer;
    if (useSingleLayer && layer != null && !isDirty) {
      canvas.paintContext.addLayer(layer);
      return true;
    }

    if (!useSingleLayer) {
      _drawInner(canvas, Offset(left, top), true);
      return false;
    }

    var oldLayer = cacheLayer.layer;
    cacheLayer.layer = null;

    cacheLayer.layer = canvas.paintContext.pushClipRect(
      true,
      globalBound.topLeft,
      Rect.fromLTWH(0, 0, width, height),
      (context, offset) {
        _drawInner(CCanvas(context), offset, true);
      },
      oldLayer: oldLayer as ClipRectLayer?,
    );
    return false;
  }

  void _drawInner(CCanvas canvas, Offset offset, bool clip) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    if (clip) {
      canvas.clipRect(Rect.fromLTRB(0, 0, width, height));
    }
    draw(canvas);
    canvas.restore();
  }

  void clearCacheLayer() {
    cacheLayer.layer = null;
    cacheLayer = LayerHandle();
  }

  @override
  void markDirty() {
    clearCacheLayer();
    super.markDirty();
  }

  bool get useSingleLayer => false;

  bool? get clipSelf => null;

  void onDrawBackground(CCanvas canvas) {}

  ///绘制时最先调用的方法，可以在这里面更改相关属性从而实现动画视觉效果
  void onDrawPre() {}

  void onDraw(CCanvas canvas) {}

  void onDrawEnd(CCanvas canvas) {}

  ///用于ViewGroup覆写
  void dispatchDraw(CCanvas canvas) {}

  /// 覆写实现重绘高亮相关的
  void onDrawHighlight(CCanvas canvas) {}

  ///实现绘制前景色
  void onDrawForeground(CCanvas canvas) {}

  ///=============处理Series和其绑定时相关的操作=============
  ChartSeries? _series;

  ///存储命令执行相关的操作
  final Map<Command, VoidFun1<Command>> _commandMap = {};

  void clearCommand() {
    _commandMap.clear();
  }

  void registerCommand(Command c, VoidFun1<Command> callback, [bool allowReplace = true]) {
    var old = _commandMap[c];
    if (!allowReplace && callback != old) {
      throw ChartError('not allow replace');
    }
    _commandMap[c] = callback;
  }

  void removeCommand(int code) {
    _commandMap.remove(code);
  }

  ///绑定Series 主要是将Series相关的命令传递到当前View
  VoidCallback? _defaultCommandCallback;

  void bindSeries(covariant ChartSeries series) {
    unBindSeries();
    _series = series;
    _defaultCommandCallback = () {
      onReceiveCommand(_series?.value);
    };
    series.addListener(_defaultCommandCallback!);
    registerCommandHandler();
  }

  void unBindSeries() {
    _commandMap.clear();
    if (_defaultCommandCallback != null) {
      _series?.removeListener(_defaultCommandCallback!);
    }
    _series = null;
  }

  void registerCommandHandler() {
    _commandMap[Command.updateData] = onUpdateDataCommand;
    _commandMap[Command.invalidate] = onInvalidateCommand;
    _commandMap[Command.reLayout] = onRelayoutCommand;
    _commandMap[Command.configChange] = onSeriesConfigChangeCommand;
  }

  void unregisterCommandHandler() {
    _commandMap.remove(Command.updateData);
    _commandMap.remove(Command.invalidate);
    _commandMap.remove(Command.reLayout);
    _commandMap.remove(Command.configChange);
  }

  void onReceiveCommand(covariant Command? c) {
    if (c == null) {
      return;
    }

    var op = _commandMap[c];
    if (op == null) {
      Logger.w('$c 无法找到能出来该命令相关的回调');
      return;
    }
    try {
      op.call(c);
    } catch (e) {
      Logger.e(e);
    }
  }

  void onInvalidateCommand(covariant Command c) {
    invalidate();
  }

  void onRelayoutCommand(covariant Command c) {
    requestLayout();
  }

  void onSeriesConfigChangeCommand(covariant Command c) {
    ///自身配置改变我们只更新当前的配置和节点布局
    onStop();
    onStart();
    requestLayoutSelf();
  }

  void onUpdateDataCommand(covariant Command c) {
    invalidate();
  }

  ///分配索引
  ///返回值表示消耗了好多的索引
  int allocateDataIndex(int index) {
    return 0;
  }

  ///是否忽略索引分配
  bool ignoreAllocateDataIndex() {
    return false;
  }

  ///=======由坐标系回调=========
  void onCoordScrollStart(CoordScroll scroll) {}

  void onCoordScrollUpdate(CoordScroll scroll) {}

  void onCoordScrollEnd(CoordScroll scroll) {}

  void onCoordScaleStart(CoordScale scale) {}

  void onCoordScaleUpdate(CoordScale scale) {}

  void onCoordScaleEnd(CoordScale scale) {}

  void onLayoutByParent(LayoutType type) {}
}
