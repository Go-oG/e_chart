import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/component/title/title_view.dart';
import 'package:flutter/widgets.dart';
import 'package:e_chart/e_chart.dart' as ec;

///存放整个图表的配置.包含所有的图形实例和动画、手势
///一个Context 对应一个图表实例
///每个Context各包含一个 TickerProvider
/// GestureDispatcher、AnimationManager、EventDispatcher、ActionDispatcher
class Context extends Disposable {
  RenderNode get root => _root!;
  RenderNode? _root;

  ChartOption get option => _option!;
  ChartOption? _option;

  ///这里不将其暴露出去是为了能更好的管理动画的生命周期
  TickerProvider? _provider;

  GestureDispatcher get gestureDispatcher => _gestureDispatcher;
  final GestureDispatcher _gestureDispatcher = GestureDispatcher();
  final AnimationManager _animationManager = AnimationManager();
  final EventDispatcher _eventDispatcher = EventDispatcher();
  final ec.ActionDispatcher _actionDispatcher = ec.ActionDispatcher();

  double devicePixelRatio;

  Context(this._root, this._option, TickerProvider provider, [this.devicePixelRatio = 1]) {
    _provider = provider;
  }

  ///更新TickerProvider
  set tickerProvider(TickerProvider p) {
    if (p == _provider) {
      return;
    }
    _provider = p;
    _animationManager.updateTickerProvider(p);
  }

  ///坐标系
  Map<Coord, CoordLayout> _coordMap = {};

  ///存放坐标系组件
  List<CoordLayout> _coordList = [];

  List<CoordLayout> get coordList => _coordList;

  ///存放普通的渲染组件
  Map<ChartSeries, ChartView> _seriesViewMap = {};

  ///Title(全局只会存在一个)
  TitleView? _title;

  TitleView? get title => _title;

  ///图例(全局一个实例)
  LegendComponent? _legend;

  LegendComponent get legend => _legend!;

  ///分配索引
  void allocateIndex() {
    //给Series 分配索引
    //同时包含了样式索引
    int styleIndex = 0;
    each(option.series, (series, i) {
      series.seriesIndex = i;
      styleIndex += series.onAllocateStyleIndex(styleIndex);
    });
  }

  /// 创建Chart组件
  /// 组件是除了渲染视图之外的全部控件
  void _createComponent() {
    ///图例
    _legend = LegendComponent(option.legend);
    _legend!.create(this, root);

    ///title
    if (option.title != null) {
      // _title = TitleView(option.title!);
      // _title?.create(this, root);
      //TODO 这里不知道是否需要回调[bindSeriesCommand]
    }

    ///Coord
    ///转换CoordConfig 到Coord
    List<Coord> coordConfigList = [
      ...option.gridList,
      ...option.polarList,
      ...option.radarList,
      ...option.calendarList,
      ...option.parallelList,
    ];

    for (var ele in coordConfigList) {
      CoordLayout<Coord>? c = CoordFactory.instance.convert(ele);
      c ??= ele.toCoord();
      if (c == null) {
        throw ChartError('无法转换对应的坐标系:$ele');
      }
      c.create(this, root);
      _coordMap[ele] = c;
      _coordList.add(c);
    }
  }

  ///创建渲染视图
  void _createRenderView() {
    ///转换Series到View
    each(option.series, (series, i) {
      series.seriesIndex = i;
      ChartView? view = SeriesFactory.instance.convert(series);
      view ??= series.toView();
      if (view == null) {
        throw FlutterError('${series.runtimeType} init fail,you must provide series convert');
      }
      _seriesViewMap[series] = view;
    });

    ///将指定了坐标系的View和坐标系绑定
    _seriesViewMap.forEach((key, view) {
      CoordLayout? layout = _findCoord(view, key);
      if (layout == null) {
        layout = SingleCoordImpl();
        layout.create(this, root);
        var config = SingleCoordConfig();
        _coordMap[config] = layout;
        _coordList.add(layout);
      }
      view.create(this, layout);
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

  ///====生命周期函数=====
  void onCreate() {
    _seriesViewMap.clear();
    _coordMap.clear();
    _coordList.clear();
    allocateIndex();

    ///创建组件
    _createComponent();

    ///创建渲染视图
    _createRenderView();

    ///绑定事件
    option.eventCall?.forEach((key, value) {
      for (var c in value) {
        _eventDispatcher.addCall(key, c);
      }
    });
  }

  void onStart() {
    _legend?.onStart();
    _title?.onStart();
    for (var coord in coordList) {
      try {
        coord.onStart();
      } catch (e) {
        Logger.e(e);
      }
    }
  }

  void onStop() {
    _animationManager.cancelAllAnimator();
    _legend?.onStop();
    _title?.onStop();
    for (var coord in coordList) {
      coord.onStop();
    }
  }

  @override
  void dispose() {
    _eventDispatcher.dispose();
    _actionDispatcher.dispose();
    _gestureDispatcher.dispose();
    _animationManager.dispose();
    _destroyView();
    _seriesViewMap = {};
    _coordMap = {};
    _coordList = [];
    _root = null;
    _option = null;
    _provider = null;
    super.dispose();
  }

  void _destroyView() {
    for (var coord in _coordList) {
      coord.destroy();
    }
    _coordList.clear();
    _legend?.destroy();
    _legend = null;
    _title?.destroy();
    _title = null;
  }

  CoordLayout? _findCoord(ChartView view, ChartSeries series) {
    var coord = series.coordType;
    if (coord != null) {
      if (coord == CoordType.grid) {
        return findGridCoord();
      }
      if (coord == CoordType.polar) {
        return findPolarCoord(series.polarIndex);
      }
      if (coord == CoordType.radar) {
        return findRadarCoord(series.radarIndex);
      }
      if (coord == CoordType.parallel) {
        return findParallelCoord(series.parallelIndex);
      }
      if (coord == CoordType.calendar) {
        return findCalendarCoord(series.calendarIndex);
      }
    }
    if (view is GridChild) {
      return findGridCoord();
    }
    if (view is PolarChild) {
      return findPolarCoord((view as PolarChild).polarIndex);
    }
    if (view is RadarChild) {
      return findRadarCoord((view as RadarChild).radarIndex);
    }
    if (view is ParallelChild) {
      return findParallelCoord((view as ParallelChild).parallelIndex);
    }

    if (view is CalendarChild) {
      return findCalendarCoord((view as CalendarChild).calendarIndex);
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
    if (gridIndex > option.polarList.length) {
      gridIndex = option.polarList.length - 1;
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

  ///=======手势监听处理===============
  void addGesture(ChartGesture gesture) {
    _gestureDispatcher.addGesture(gesture);
  }

  void removeGesture(ChartGesture gesture) {
    _gestureDispatcher.removeGesture(gesture);
  }

  ///=========动画管理==================
  AnimationController boundedAnimation(AnimatorOption props, [bool useUpdate = false]) {
    return _animationManager.bounded(_provider!, props, useUpdate: useUpdate);
  }

  AnimationController unboundedAnimation() {
    return _animationManager.unbounded(_provider!);
  }

  void removeAnimation(AnimationController? c, [bool cancel = true]) {
    if (c == null) {
      return;
    }
    _animationManager.remove(c, cancel);
  }

  void addAnimationToQueue(List<AnimationNode> nodes) {
    _animationManager.addAnimators(nodes);
  }

  List<AnimationNode> getAndResetAnimationQueue() {
    return _animationManager.getAndRestAnimatorQueue();
  }

  ///========Action分发监听============

  void addActionCall(Fun2<ChartAction, bool> call) {
    _actionDispatcher.addCall(call);
  }

  void removeActionCall(Fun2<ChartAction, bool> call) {
    _actionDispatcher.removeCall(call);
  }

  void dispatchAction(ChartAction action) {
    _actionDispatcher.dispatch(action);
  }

  ///=======Event分发和监听===============
  void addEventCall(EventType type, VoidFun1<ChartEvent>? call) {
    if (call == null) {
      return;
    }
    _eventDispatcher.addCall(type, call);
  }

  void removeEventCall(VoidFun1<ChartEvent>? call) {
    if (call == null) {
      return;
    }
    _eventDispatcher.removeCall(call);
  }

  void removeEventCall2(EventType type, VoidFun1<ChartEvent>? call) {
    if (call == null) {
      return;
    }
    _eventDispatcher.removeCall2(type, call);
  }

  void dispatchEvent(ChartEvent event) {
    _eventDispatcher.dispatch(event);
  }

  bool hasEventListener(EventType? type) {
    return _eventDispatcher.hasEventListener(type);
  }
}
