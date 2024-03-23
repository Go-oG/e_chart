import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/core/model/visibility.dart' as m;
import 'package:flutter/rendering.dart';

import 'package:flutter/widgets.dart';

import '../view/attach_info.dart';
import '../view/view_parent.dart';

///该类负责将Flutter原生的布局、渲染流程映射到我们的ChartRender中
final class RenderAdapter extends RenderBox implements ViewParent {
  ChartOption option;
  TickerProvider provider;
  final Paint _paint = Paint();
  late final AttachInfo attachInfo;

  RenderAdapter(this.option, this.provider, Size? size) {
    attachInfo = AttachInfo(this);
    var dp = WidgetsBinding.instance.platformDispatcher.displays.first.devicePixelRatio;
    _context = Context(option, provider, dp);
    _initRender(option, provider, size);
  }

  bool oldHasSize = false;

  Size oldSize = Size.zero;

  Size? configSize;

  BoxConstraints? oldConstraints;

  double mHeight = 0;

  double mWidth = 0;

  Context? _context;
  ChartView? _rootView;

  ///坐标系
  Map<Coord, CoordLayout> _coordMap = {};

  ///存放坐标系组件
  List<CoordLayout> _coordList = [];

  ///存放普通的渲染组件
  Map<ChartSeries, ChartView> _seriesViewMap = {};

  ///创建视图树
  ChartViewGroup createViewTree() {
    _seriesViewMap.clear();
    _coordMap.clear();
    _coordList.clear();

    ///分配索引
    each(option.series, (series, i) {
      series.seriesIndex = i;
    });

    ///创建坐标系组件
    List<Coord> coordConfigList = [
      ...option.gridList,
      ...option.polarList,
      ...option.radarList,
      ...option.calendarList,
      ...option.parallelList,
    ];
    for (var ele in coordConfigList) {
      CoordLayout<Coord>? c = CoordFactory.instance.convert(_context!, ele);
      c ??= ele.toCoord(_context!);
      if (c == null) {
        throw ChartError('无法转换对应的坐标系:$ele');
      }
      _coordMap[ele] = c;
      _coordList.add(c);
    }

    ///创建渲染视图
    _createRenderView(_context!);

    ChartViewGroup rootView = FrameLayout(_context!);
    for (var item in _coordList) {
      rootView.addView(item);
    }

    rootView.dispatchAttachInfo(attachInfo);
    rootView.created();

    return rootView;
  }

  ///创建渲染视图
  void _createRenderView(Context context) {
    ///转换Series到View
    each(option.series, (series, i) {
      series.seriesIndex = i;
      ChartView? view = SeriesFactory.instance.convert(context, series);
      view ??= series.toView(context);
      if (view == null) {
        throw FlutterError('${series.runtimeType} init fail,you must provide series convert');
      }
      _seriesViewMap[series] = view;
    });

    ///将指定了坐标系的View和坐标系绑定
    _seriesViewMap.forEach((key, view) {
      CoordLayout? layout = _findCoord(view, key);
      if (layout == null) {
        layout = SingleCoordImpl(_context!);
        var config = SingleCoordConfig();
        _coordMap[config] = layout;
        _coordList.add(layout);
      }
      layout.addView(view);
    });

    each(_coordList, (coord, p1) {
      int index = 0;
      for (var ele in coord.children) {
        if (ele.ignoreAllocateDataIndex()) {
          continue;
        }
        var old = index;
        index += ele.allocateDataIndex(old);
      }
    });
  }

  CoordLayout? _findCoord(ChartView view, ChartSeries series) {
    if (view is! CoordChild) {
      return null;
    }
    var coordInfo = (view as CoordChild).getEmbedCoord();
    var coord = coordInfo.type;
    var index = coordInfo.index;
    if (coord == CoordType.grid) {
      return findGridCoord();
    }
    if (coord == CoordType.polar) {
      return findPolarCoord(index);
    }
    if (coord == CoordType.radar) {
      return findRadarCoord(index);
    }
    if (coord == CoordType.parallel) {
      return findParallelCoord(index);
    }
    if (coord == CoordType.calendar) {
      return findCalendarCoord(index);
    }
    return null;
  }

  /// 坐标系查找相关函数
  GridCoord findGridCoord([int gridIndex = 0]) {
    var r = findGridCoordNull(gridIndex);
    if (r == null) {
      throw FlutterError('暂无Grid坐标系');
    }
    return r;
  }

  GridCoord? findGridCoordNull([int gridIndex = 0]) {
    if (option.gridList.isEmpty) {
      return null;
    }
    if (gridIndex < 0) {
      gridIndex = 0;
    }
    if (gridIndex > option.gridList.length) {
      gridIndex = option.gridList.length - 1;
    }
    return _coordMap[option.gridList[gridIndex]] as GridCoord?;
  }

  PolarCoord findPolarCoord([int polarIndex = 0]) {
    var r = findPolarCoordNull(polarIndex);
    if (r == null) {
      throw ChartError('暂无Polar坐标系');
    }
    return r;
  }

  PolarCoord? findPolarCoordNull([int polarIndex = 0]) {
    if (option.polarList.isEmpty) {
      return null;
    }
    if (polarIndex < 0) {
      polarIndex = 0;
    }
    if (polarIndex > option.polarList.length) {
      polarIndex = 0;
    }
    return _coordMap[option.polarList[polarIndex]] as PolarCoord?;
  }

  RadarCoord findRadarCoord([int radarIndex = 0]) {
    var r = findRadarCoordNull(radarIndex);
    if (r == null) {
      throw ChartError('暂无Radar坐标系');
    }
    return r;
  }

  RadarCoord? findRadarCoordNull([int radarIndex = 0]) {
    if (option.radarList.isEmpty) {
      return null;
    }
    if (radarIndex > option.radarList.length) {
      radarIndex = 0;
    }
    return _coordMap[option.radarList[radarIndex]] as RadarCoord?;
  }

  ParallelCoord findParallelCoord([int parallelIndex = 0]) {
    var r = findParallelCoordNull(parallelIndex);
    if (r == null) {
      throw ChartError('当前未配置Parallel 坐标系无法查找');
    }
    return r;
  }

  ParallelCoord? findParallelCoordNull([int parallelIndex = 0]) {
    if (option.parallelList.isEmpty) {
      return null;
    }
    int index = parallelIndex;
    if (index > option.parallelList.length) {
      index = 0;
    }
    Parallel parallel = option.parallelList[index];
    return _coordMap[parallel] as ParallelCoord?;
  }

  CalendarCoord findCalendarCoord([int calendarIndex = 0]) {
    var r = findCalendarCoordNull(calendarIndex);
    if (r == null) {
      throw FlutterError('当前未配置Calendar 坐标系无法查找');
    }
    return r;
  }

  CalendarCoord? findCalendarCoordNull([int calendarIndex = 0]) {
    if (option.calendarList.isEmpty) {
      return null;
    }
    int index = calendarIndex;
    if (index > option.calendarList.length) {
      index = 0;
    }

    Calendar calendar = option.calendarList[index];
    return _coordMap[calendar] as CalendarCoord?;
  }

  void onUpdateRender(ChartOption option, Size? size, TickerProvider provider) {
    Logger.i('onUpdateRender');
    // var oldRender = _render;
    // if (oldRender != null && option == oldRender.context.option) {
    //   ///相同的对象
    //   if (size != null && configSize != size) {
    //     configSize = size;
    //     markNeedsLayout();
    //   } else {
    //     markNeedsPaint();
    //   }
    //   markNeedsCompositingBitsUpdate();
    //   markNeedsSemanticsUpdate();
    //   return;
    // }
    // Logger.i('onUpdateRender 重建');
    //
    // ///直接重建
    // _provider = provider;
    // _disposeRender(_render);
    // _render = null;
    //
    // _initRender(option, provider, size);
    // _clearOldLayoutSize();
    // _render?.onStart();
    // markNeedsLayout();
    // markNeedsCompositingBitsUpdate();
    // markNeedsSemanticsUpdate();
  }

  void _initRender(ChartOption option, TickerProvider provider, Size? size) {
    configSize = size;
    oldSize = Size.zero;
    option.addListener(() {
      var c = option.value;
      if (c == Command.configChange) {
        onUpdateRender(option, configSize, provider);
      }
    });
  }

  void _clearOldLayoutSize() {
    oldConstraints = null;
    oldSize = Size.zero;
  }

  ///======================父类方法=====================

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    _rootView?.attachToWindow();
    _context?.attach();
    _context?.gestureDispatcher.enable();
  }

  @override
  void detach() {
    _rootView?.detachFromWindow();
    _context?.detach();
    _context?.gestureDispatcher.disable();
    super.detach();
  }

  @override
  void performResize() {
    if (hasSize && oldConstraints != null && constraints == oldConstraints && oldSize == size) {
      Logger.i('performResize() 前后约束不变 不进行测量');
      return;
    }
    oldConstraints = constraints;
    double minW = constraints.minWidth;
    double minH = constraints.minHeight;
    double maxW = constraints.maxWidth;
    double maxH = constraints.maxHeight;
    double w = adjustSize(maxW, minW, configSize?.width);
    double h = adjustSize(maxH, minH, configSize?.height);
    oldHasSize = hasSize;
    oldSize = hasSize ? size : Size.zero;
    size = Size(w, h);
  }

  double adjustSize(double maxSize, double minSize, double? defaultSize) {
    if (maxSize.isFinite && maxSize > 0) {
      return maxSize;
    }
    if (minSize.isFinite && minSize > 0) {
      return minSize;
    }

    if (defaultSize != null && defaultSize > 0) {
      return defaultSize;
    }

    throw ChartError("size constraints is NaN Or Infinite and defaultSize is Null");
  }

  @override
  void performLayout() {
    super.performLayout();
    double w = size.width;
    double h = size.height;
    measure(w, h);
    _rootView?.layout(0, 0, w, h);
  }

  void measure(double parentWidth, double parentHeight) {
    _context?.animationManager.cancelAllAnimator();
    var widthSpec = MeasureSpec.exactly(parentWidth);
    var heightSpec = MeasureSpec.exactly(parentHeight);
    _rootView?.measure(widthSpec, heightSpec);

    mWidth = parentWidth;
    mHeight = parentHeight;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _paint.reset();
    _context?.dispatchEvent(RenderedEvent.rendered);

    var queue = _context?.getAndResetAnimationQueue() ?? [];
    var tmpContext = _context;
    if (tmpContext != null) {
      for (var node in queue) {
        node.start(tmpContext);
      }
    }
    var cc = CCanvas.fromContext(context);
    var bc = tmpContext?.option.theme.backgroundColor;
    if (bc != null) {
      _paint.color = bc;
      _paint.style = PaintingStyle.fill;
      cc.drawRect(Rect.fromLTWH(0, 0, mWidth, mHeight), _paint);
    }

    _rootView?.draw(cc);
  }

  @override
  void handleEvent(PointerEvent event, covariant BoxHitTestEntry entry) {
    _context?.gestureDispatcher.handleEvent(event, entry);
  }

  bool isInLayout() {
    ///TODO 待实现
    return false;
  }

  ///================自定义接口方法开始=============

  void requestDraw() {
    markNeedsCompositingBitsUpdate();
    markNeedsPaint();
  }

  @override
  void requestLayout() {
    markNeedsCompositingBitsUpdate();
    markNeedsLayout();
  }

  @override
  void changeChildToFront(ChartView child) {}

  @override
  void childHasTransientStateChanged(ChartView child, bool hasTransientState) {}

  @override
  bool getChildVisibleRect(ChartView child, Rect r, Offset offset) {
    return r.overlaps(Rect.fromLTWH(0, 0, mWidth, mHeight));
  }

  @override
  bool isLayoutRequested() => true;

  @override
  void onDescendantInvalidated(ChartView child, ChartView target) {
    markNeedsPaint();
  }

  @override
  void recomputeViewAttributes(ChartView child) {}

  @override
  void requestChildFocus(ChartView child, ChartView focused) {
    markNeedsPaint();
  }

  @override
  void redrawParentCaches() {}

  @override
  void childVisibilityChange(ChartView child, m.Visibility old) {}

  @override
  void clearChildFocus(ChartView child) {
    markNeedsPaint();
  }

  @override
  void clearFocus() {
    markNeedsPaint();
  }

  @override
  void unFocus(ChartView focused) {
    markNeedsPaint();
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  bool get sizedByParent => true;

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void dispose() {
    _disposeView();
    _seriesViewMap = {};
    _coordMap = {};
    _coordList = [];

    _rootView?.dispose();
    _rootView = null;
    _context?.dispatchEvent(ChartDisposeEvent.single);
    _context?.dispose();
    _context = null;
    super.dispose();
  }

  void _disposeView() {
    for (var coord in _coordList) {
      coord.dispose();
    }
    _coordList = [];
  }
}
