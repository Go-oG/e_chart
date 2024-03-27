import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/core/view/overlay.dart';
import 'package:e_chart/src/core/view/view_frame.dart';
import 'package:e_chart/src/core/view/view_parent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import '../render/render_adapter.dart';
import 'attach_info.dart';

abstract class ChartView with ViewFrame {
  final String id = randomId();
  Context context;

  AttachInfo? _attachInfo;

  AttachInfo get attachInfo {
    return _attachInfo!;
  }

  set attachInfo(AttachInfo info) {
    _attachInfo = info;
  }

  ChartView(this.context);

  @protected
  ViewParent? mParent;

  ViewParent? get parent => mParent;

  @protected
  set parent(ViewParent? p) => mParent = p;

  @protected
  ViewOverLay? mOverlay;

  @protected
  late Paint mPaint = Paint();

  ///存储当前节点的布局属性
  LayoutParams layoutParams = LayoutParams.wrapAll();

  double alpha = 1;

  bool get needNewLayer => false;

  bool _dirty = true;

  bool _forceLayout = true;

  bool get isForceLayout => _forceLayout;

  void forceLayout() {
    _forceLayout = true;
  }

  bool _needDraw = true;

  bool get isNeedDraw => _needDraw;

  @override
  bool setVisibility(Visibility vb) {
    var old = visibility;
    bool res = super.setVisibility(vb);
    if (res) {
      parent?.childVisibilityChange(this, old);
    }
    return res;
  }

  @nonVirtual
  void measure(MeasureSpec widthSpec, MeasureSpec heightSpec) {
    onMeasure(widthSpec, heightSpec);
  }

  void onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec) {
    LayoutParams lp = layoutParams;
    double w = _measureSelfWithParent(widthSpec, lp.hPadding, lp.width);
    double h = _measureSelfWithParent(heightSpec, lp.vPadding, lp.height);
    setMeasuredDimension(w, h);
  }

  double _measureSelfWithParent(MeasureSpec parentSpec, double padding, SizeParams selfParams) {
    if (selfParams.isExactly) {
      return selfParams.size.number.toDouble();
    }
    if (selfParams.isWrap) {
      return padding;
    }
    //match parent
    var mode = parentSpec.mode;
    if (mode == SpecMode.exactly) {
      return parentSpec.size;
    }
    return padding;
  }

  double measureSelfSize(MeasureSpec parentSpec, SizeParams selfParams, double pendingSize) {
    if (selfParams.isExactly) {
      return selfParams.size.number.toDouble();
    }
    if (selfParams.isWrap) {
      return pendingSize;
    }

    //match parent
    var mode = parentSpec.mode;
    if (mode == SpecMode.atMost) {
      return pendingSize;
    }
    if (mode == SpecMode.exactly) {
      return parentSpec.size;
    }

    return pendingSize;
  }

  void layout(double l, double t, double r, double b) {
    var oldL = left;
    var oldT = top;
    var oldR = right;
    var oldB = bottom;
    bool changed = setFrame(l, t, r, b);
    if (changed || _forceLayout) {
      onLayout(changed, l, t, r, b);
      onLayoutChange(l, t, r, b, oldL, oldT, oldR, oldB);
    }
    _forceLayout = false;
  }

  @protected
  bool setFrame(double left, double top, double right, double bottom) {
    bool changed = false;
    if (diff(left, top, right, bottom)) {
      changed = true;
      double oldWidth = width;
      double oldHeight = height;
      double newWidth = right - left;
      double newHeight = bottom - top;
      bool sizeChanged = diffSize(left, top, right, bottom);
      requestDrawInner(sizeChanged);

      this.left = left;
      this.top = top;
      this.right = right;
      this.bottom = bottom;

      var parent = this.parent;
      if (parent is ChartViewGroup) {
        globalTop = parent.globalTop + top;
        globalLeft = parent.globalLeft + left;
      } else {
        globalTop = top;
        globalLeft = left;
      }
      if (sizeChanged) {
        _sizeChange(newWidth, newHeight, oldWidth, oldHeight);
      }
      if (visibility.isShow) {
        requestDrawInner(sizeChanged);
        parent?.redrawParentCaches();
      }
    }
    return changed;
  }

  void onLayout(bool changed, double left, double top, double right, double bottom) {}

  void onLayoutChange(double left, double top, double right, double bottom, double oldLeft, double oldTop,
      double oldRight, double oldBottom) {}

  void _sizeChange(double newWidth, double newHeight, double oldWidth, double oldHeight) {
    onSizeChange(newWidth, newHeight, oldWidth, oldHeight);
  }

  void onSizeChange(double newWidth, double newHeight, double oldWidth, double oldHeight) {}

  void draw(CCanvas canvas) {
    if (visibility.isHide) {
      return;
    }
    //TODO 检查缓存和是否需要二次绘制

    _drawBackground(canvas);
    onDraw(canvas);
    dispatchDraw(canvas);
    drawOverlay(canvas);
    onDrawForeground(canvas);
    drawFocusHighlight(canvas);
  }

  void _drawBackground(CCanvas canvas) {
    final double scrollX = this.scrollX;
    final double scrollY = this.scrollY;
    if (scrollX == 0 && scrollY == 0) {
      //  background.draw(canvas);
    } else {
      canvas.translate(scrollX, scrollY);
      //  background.draw(canvas);
      canvas.translate(-scrollX, -scrollY);
    }
  }

  @protected
  void onDrawBackground(CCanvas canvas) {}

  @protected
  void onDraw(CCanvas canvas) {}

  @protected
  void dispatchDraw(CCanvas canvas) {}

  @protected
  void drawOverlay(CCanvas canvas) {
    mOverlay?.getOverlayView().dispatchDraw(canvas);
  }

  @protected
  void onDrawForeground(CCanvas canvas) {}

  @protected
  void drawFocusHighlight(CCanvas canvas) {}

  void computeScroll() {}

  void requestLayout() {
    //ClearCache
    // if (mMeasureCache != null) mMeasureCache.clear();
    var attachInfo = _attachInfo;
    if (attachInfo != null && attachInfo.viewRequestingLayout == null) {
      var viewRoot = getViewRootImpl();

      if (viewRoot != null && viewRoot.isInLayout()) {
        ///TODO 后续完成
      }
      attachInfo.viewRequestingLayout = this;
    }
    _forceLayout = true;
    _needDraw = true;
    mParent?.requestLayout();

    if (attachInfo != null && attachInfo.viewRequestingLayout == this) {
      attachInfo.viewRequestingLayout = null;
    }
  }

  RenderAdapter? getViewRootImpl() {
    return _attachInfo?.root;
  }

  void requestDraw() {
    requestDrawInner(true);
  }

  @protected
  void requestDrawInner(bool redrawCache) {
    requestDrawInner2(0, 0, width, height, redrawCache, true);
  }

  @protected
  void requestDrawInner2(double l, double t, double r, double b, bool redrawCache, bool fullRedraw) {
    if (skipRedraw()) {
      return;
    }
    _needDraw = true;
    var parent = this.parent;
    if (parent is ChartViewGroup) {
      parent.requestDraw();
    }
  }

  bool skipRedraw() {
    return false;
  }

  void clearFocus() {}

  @protected
  void clearFocusInternal(ChartView? focused, bool propagate, bool refocus) {}

  void unFocus(ChartView focused) {
    clearFocusInternal(focused, false, false);
  }

  bool hasFocus() {
    return false;
  }

  ///=========生命周期回调方法开始==================

  ///该回调只会发生在视图创建后，且只会回调一次
  void dispatchAttachInfo(AttachInfo attachInfo) {
    _attachInfo = attachInfo;
  }

  void created() {
    onCreate();
  }

  void onCreate() {}

  void attachToWindow() {
    onViewAttachToWindow();
  }

  void onViewAttachToWindow() {}

  void detachFromWindow() {
    onViewDetachFromWindow();
  }

  void onViewDetachFromWindow() {}

  ///由Context负责回调
  ///当该方法被调用时标志着当前View即将被销毁
  ///你可以在这里进行资源释放等操作
  void dispose() {
    clearCommand();
    _defaultCommandCallback = null;
    unBindSeries();
    onDispose();
  }

  void onDispose() {}

  ///=============处理Series和其绑定时相关的操作=============
  ChartSeries? _series;

  ///存储命令执行相关的操作
  Map<Command, VoidFun1<Command>> _commandMap = {};

  void clearCommand() {
    _commandMap = {};
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
    op.call(c);
  }

  void onInvalidateCommand(covariant Command c) {
    requestDraw();
  }

  void onRelayoutCommand(covariant Command c) {
    requestLayout();
  }

  void onSeriesConfigChangeCommand(covariant Command c) {}

  void onUpdateDataCommand(covariant Command c) {
    requestDraw();
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

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    return other is ChartView && other.id == id;
  }

  bool get useZeroWhenMeasureSpecModeIsUnLimit => false;
}
