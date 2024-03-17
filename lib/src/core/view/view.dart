import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/core/view/view_parent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../model/chart_edgeinset.dart';
import 'AttachInfo.dart';
import 'models.dart';

abstract class ChartView {
  final String id = randomId();

  late AttachInfo attachInfo;

  late Context context;

  ChartView(this.context);

  @protected
  ViewParent? mParent;

  ViewParent? get parent => mParent;

  @protected
  set parent(ViewParent? p) => mParent = p;

  @protected
  late Paint mPaint = Paint();

  ///存储当前节点的布局属性
  LayoutParams layoutParams = const LayoutParams.wrapAll();

  final ChartEdgeInset margin = ChartEdgeInset();

  final ChartEdgeInset padding = ChartEdgeInset();

  Offset toLocal(Offset global) {
    return Offset(global.dx - globalBound.left, global.dy - globalBound.top);
  }

  Offset toGlobal(Offset local) {
    return Offset(local.dx + globalBound.left, local.dy + globalBound.top);
  }

  double get left => boxBound.left;

  double get top => boxBound.top;

  double get right => boxBound.right;

  double get bottom => boxBound.bottom;

  double scrollX = 0;

  double scrollY = 0;

  double translationX = 0;

  double translationY = 0;

  double scale = 1;

  double alpha = 1;

  double get centerX => width / 2.0;

  double get centerY => height / 2.0;

  ///存储当前视图在父视图中的位置属性
  Rect boxBound = Rect.zero;

  ///记录其全局位置
  Rect globalBound = Rect.zero;

  double get width {
    return boxBound.width;
  }

  double get height {
    return boxBound.height;
  }

  double measureWidth = 0;

  double measureHeight = 0;

  bool get needNewLayer => false;

  Visibility _visibility = Visibility.visible;

  set visibility(Visibility vb) {
    if (_visibility == vb) {
      return;
    }
    var old = _visibility;
    _visibility = vb;
    parent?.childVisibilityChange(this, old);
  }

  Visibility get visibility {
    return _visibility;
  }

  bool get isVisibility {
    return _visibility == Visibility.visible;
  }

  bool _dirty = true;

  bool _forceLayout = true;

  bool get forceLayout => _forceLayout;

  @protected
  set forceLayout(bool f) => _forceLayout = f;

  Rect getGlobalBounds() {
    var par = parent;
    if (par is! ChartViewGroup) {
      return boxBound;
    }
    var boundRect = boxBound;
    Rect parentRect = par.globalBound;
    double l = parentRect.left + boundRect.left;
    double t = parentRect.top + boundRect.top;
    return Rect.fromLTWH(l, t, boundRect.width, boundRect.height);
  }

  @nonVirtual
  void measure(MeasureSpec widthSpec, MeasureSpec heightSpec) {
    margin.reset();
    padding.reset();
    var size = onMeasure(widthSpec, heightSpec);

    measureWidth = size.width;
    measureHeight = size.height;
  }

  Size onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec) {
    LayoutParams lp = layoutParams;
    double w = lp.width.convert(widthSpec.size);
    double h = lp.height.convert(heightSpec.size);
    if (lp.width.isWrap) {
      padding.left = lp.getLeftPadding(widthSpec.size);
      padding.right = lp.getRightPadding(widthSpec.size);
      w = padding.horizontal;
    } else {
      padding.left = lp.getLeftPadding(w);
      padding.right = lp.getRightPadding(w);
    }
    if (lp.height.isWrap) {
      padding.top = lp.getTopPadding(heightSpec.size);
      padding.bottom = lp.getBottomPadding(heightSpec.size);
      h = padding.vertical;
    } else {
      padding.top = lp.getTopPadding(h);
      padding.bottom = lp.getBottomPadding(h);
    }
    margin.top = lp.getTopMargin(heightSpec.size);
    margin.left = lp.getLeftMargin(widthSpec.size);
    margin.right = lp.getRightMargin(widthSpec.size);
    margin.bottom = lp.getBottomMargin(heightSpec.size);
    return Size(w, h);
  }

  void layout(double l, double t, double r, double b) {
    var oldR = boxBound;

    bool changed = setFrame(l, t, r, b);
    if (changed) {
      onLayout(changed, l, t, r, b);
      onLayoutChange(l, t, r, b, oldR.left, oldR.top, oldR.right, oldR.bottom);
    }
  }

  @protected
  bool setFrame(double left, double top, double right, double bottom) {
    bool changed = false;

    if (boxBound.left != left || boxBound.right != right || boxBound.top != top || boxBound.bottom != bottom) {
      changed = true;
      double oldWidth = width;
      double oldHeight = height;
      double newWidth = right - left;
      double newHeight = bottom - top;
      bool sizeChanged = (newWidth != oldWidth) || (newHeight != oldHeight);

      requestDrawInner(sizeChanged);
      boxBound = Rect.fromLTRB(left, top, right, bottom);
      var parent = this.parent;
      if (parent is ChartViewGroup) {
        globalBound = boxBound.translate(parent.globalBound.left, parent.globalBound.top);
      } else {
        globalBound = boxBound;
      }
      if (sizeChanged) {
        _sizeChange(newWidth, newHeight, oldWidth, oldHeight);
      }

      if (_visibility.isShow) {
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
    if (_visibility != Visibility.visible) {
      return;
    }
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
  void drawOverlay(CCanvas canvas) {}

  @protected
  void onDrawForeground(CCanvas canvas) {}

  @protected
  void drawFocusHighlight(CCanvas canvas) {}

  void computeScroll() {}

  void requestLayout() {}

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

    ///TODO
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
    this.attachInfo = attachInfo;
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
    // try {
    op.call(c);
    // } catch (e) {
    //   Logger.e(e);
    // }
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

  ///=========Debug 绘制相关方法===============
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
