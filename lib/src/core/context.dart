import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/component/title/title_view.dart';
import 'package:flutter/widgets.dart';
import 'package:e_chart/e_chart.dart' as ec;

///存放整个图表的配置.包含所有的图形实例和动画、手势
///一个Context 对应一个图表实例
///每个Context各包含一个 TickerProvider
/// GestureDispatcher、AnimationManager、EventDispatcher、ActionDispatcher
class Context {
  final ViewParent root;
  final ChartOption option;

  ///这里不将其暴露出去是为了能更好的管理动画的生命周期
  late TickerProvider _provider;
  final GestureDispatcher _gestureDispatcher = GestureDispatcher();

  GestureDispatcher get gestureDispatcher => _gestureDispatcher;

  final AnimationManager _animationManager = AnimationManager();
  final EventDispatcher _eventDispatcher = EventDispatcher();
  final ec.ActionDispatcher _actionDispatcher = ec.ActionDispatcher();
  double devicePixelRatio;

  Context(this.root, this.option, TickerProvider provider, [this.devicePixelRatio = 1]) {
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

  ///坐标轴
  final Map<BaseAxis, ChartView> _axisMap = {};

  ///坐标系
  final Map<Coord, CoordLayout> _coordMap = {};

  ///存放普通的渲染组件
  final Map<ChartSeries, ChartView> _seriesViewMap = {};

  ///存放坐标系组件
  final List<CoordLayout> _coordList = [];

  List<CoordLayout> get coordList => _coordList;

  ///Title(全局只会存在一个)
  TitleView? _title;

  TitleView? get title => _title;

  ///图例(全局一个实例)
  LegendViewGroup? _legend;

  LegendViewGroup? get legend => _legend;


  /// 创建Chart组件
  /// 组件是除了渲染视图之外的全部控件
  void _createComponent() {
    ///图例
    if (option.legend != null) {
      _legend = LegendViewGroup(option.legend!);
      _legend?.create(this, root);
      //TODO 这里不知道是否需要回调[bindSeriesCommand]
    }

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
      var c = CoordFactory.instance.convert(ele);
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
      series.seriesIndex=i;
      ChartView? view = SeriesFactory.instance.convert(series);
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
      view.bindSeries(key);
      layout.addView(view);
    });
  }

  ///====生命周期函数=====
  void onCreate() {
    _seriesViewMap.clear();
    _coordMap.clear();
    _axisMap.clear();
    _coordList.clear();

    ///创建组件
    _createComponent();

    ///创建渲染视图
    _createRenderView();

    ///绑定事件
    if (option.eventCall != null) {
      _eventDispatcher.addCall(option.eventCall!);
    }
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
    _legend?.onStop();
    _title?.onStop();
    for (var coord in coordList) {
      try {
        coord.onStop();
      } catch (e) {
        Logger.e(e);
      }
    }
  }

  void destroy() {
    _eventDispatcher.dispose();
    _actionDispatcher.dispose();
    _gestureDispatcher.dispose();
    _animationManager.dispose();
    _destroyView();
    _seriesViewMap.clear();
    _axisMap.clear();
    _coordMap.clear();
    _coordList.clear();
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
    if (series.coordSystem != null) {
      var coord = series.coordSystem!;
      if (coord == CoordSystem.grid) {
        return findGridCoord();
      }
      if (coord == CoordSystem.polar) {
        return findPolarCoord(series.polarIndex);
      }
      if (coord == CoordSystem.radar) {
        return findRadarCoord(series.radarIndex);
      }
      if (coord == CoordSystem.parallel) {
        return findParallelCoord(series.parallelIndex);
      }
      if (coord == CoordSystem.calendar) {
        return findCalendarCoord(series.calendarIndex);
      }
    }

    if (view is RadarChild) {
      return findRadarCoord((view as RadarChild).radarIndex);
    }
    if (view is ParallelChild) {
      return findParallelCoord((view as ParallelChild).parallelIndex);
    }
    if (view is PolarChild) {
      return findPolarCoord((view as PolarChild).polarIndex);
    }
    if (view is GridChild) {
      return findGridCoord();
    }
    if (view is CalendarChild) {
      return findCalendarCoord((view as CalendarChild).calendarIndex);
    }
    return null;
  }

  /// 坐标系查找相关函数
  GridCoord findGridCoord([int gridIndex = 0]) {
    if (option.gridList.isEmpty) {
      throw FlutterError('暂无Grid坐标系');
    }
    if (gridIndex < 0) {
      gridIndex = 0;
    }
    if (gridIndex > option.polarList.length) {
      gridIndex = option.polarList.length - 1;
    }
    return _coordMap[option.gridList[gridIndex]]! as GridCoord;
  }

  PolarCoord findPolarCoord([int polarIndex = 0]) {
    if (option.polarList.isEmpty) {
      throw FlutterError('暂无Polar坐标系');
    }
    if (polarIndex < 0) {
      polarIndex = 0;
    }
    if (polarIndex > option.polarList.length) {
      polarIndex = 0;
    }
    return _coordMap[option.polarList[polarIndex]]! as PolarCoord;
  }

  RadarCoord findRadarCoord([int radarIndex = 0]) {
    if (radarIndex > option.radarList.length) {
      radarIndex = 0;
    }
    if (option.radarList.isEmpty) {
      throw FlutterError('暂无Radar坐标系');
    }
    return _coordMap[option.radarList[radarIndex]]! as RadarCoord;
  }

  ParallelCoord findParallelCoord([int parallelIndex = 0]) {
    int index = parallelIndex;
    if (index > option.parallelList.length) {
      index = 0;
    }
    if (option.parallelList.isEmpty) {
      throw FlutterError('当前未配置Parallel 坐标系无法查找');
    }
    Parallel parallel = option.parallelList[index];
    return _coordMap[parallel]! as ParallelCoord;
  }

  CalendarCoord findCalendarCoord([int calendarIndex = 0]) {
    int index = calendarIndex;
    if (index > option.calendarList.length) {
      index = 0;
    }
    if (option.calendarList.isEmpty) {
      throw FlutterError('当前未配置Calendar 坐标系无法查找');
    }
    Calendar calendar = option.calendarList[index];
    return _coordMap[calendar]! as CalendarCoord;
  }


  ///=======手势监听处理===============
  void addGesture(ChartGesture gesture) {
    _gestureDispatcher.addGesture(gesture);
  }

  void removeGesture(ChartGesture gesture) {
    _gestureDispatcher.removeGesture(gesture);
  }

  ///=========动画管理==================
  AnimationController boundedAnimation(AnimatorAttrs props, [bool useUpdate = false]) {
    return _animationManager.bounded(_provider, props, useUpdate: useUpdate);
  }

  AnimationController unboundedAnimation() {
    return _animationManager.unbounded(_provider);
  }

  void removeAnimation(AnimationController? c, [bool cancel = true]) {
    if (c == null) {
      return;
    }
    _animationManager.remove(c, cancel);
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

  ///=======Event分发和监听

  void addEventCall(VoidFun1<ChartEvent> call) {
    _eventDispatcher.addCall(call);
  }

  void removeEventCall(VoidFun1<ChartEvent> call) {
    _eventDispatcher.removeCall(call);
  }

  void dispatchEvent(ChartEvent event) {
    _eventDispatcher.dispatch(event);
  }
}
