import 'package:flutter/widgets.dart';

import '../animation/index.dart';
import '../chart.dart';
import '../model/index.dart';
import '../utils/log_util.dart';
import 'series.dart';
import '../component/axis/base_axis.dart';
import '../component/legend/layout.dart';
import '../component/title/title_view.dart';
import '../component/tooltip/context_menu_builder.dart';
import '../component/tooltip/tool_tip_view.dart';
import '../coord/calendar/calendar_config.dart';
import '../coord/calendar/calendar_child.dart';
import '../coord/calendar/calendar_coord.dart';
import '../coord/coord.dart';
import '../coord/coord_config.dart';
import '../coord/grid/grid_child.dart';
import '../coord/grid/grid_coord.dart';
import '../coord/parallel/parallel_config.dart';
import '../coord/parallel/parallel_child.dart';
import '../coord/parallel/parallel_coord.dart';
import '../coord/polar/polar_child.dart';
import '../coord/polar/polar_coord.dart';
import '../coord/radar/radar_child.dart';
import '../coord/radar/radar_coord.dart';
import '../coord/single/single_layout.dart';
import '../coord_factory.dart';
import '../gesture/chart_gesture.dart';
import '../gesture/gesture_dispatcher.dart';
import '../series_factory.dart';
import 'view.dart';
import 'view_group.dart';

///存放整个图表的配置.包含所有的图形实例和动画、手势
///一个Context 对应一个 GestureDispatcher和一个AnimationManager

class Context {
  final ViewParent root;
  final ChartConfig config;

  ///这里不将其暴露出去是为了能更好的管理动画的生命周期
  late TickerProvider _provider;
  final GestureDispatcher _gestureDispatcher = GestureDispatcher();
  final AnimationManager _animationManager = AnimationManager();
  double devicePixelRatio;

  GestureDispatcher get gestureDispatcher => _gestureDispatcher;

  Context(this.root, this.config, TickerProvider provider, [this.devicePixelRatio = 1]) {
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
  final Map<CoordConfig, Coord> _coordMap = {};

  ///存放普通的渲染组件
  final Map<ChartSeries, ChartView> _seriesViewMap = {};

  ///存放坐标系组件
  final List<Coord> _coordList = [];

  List<Coord> get coordList => _coordList;

  ///Title(全局只会存在一个)
  TitleView? _title;

  TitleView? get title => _title;

  ///图例(全局一个实例)
  LegendViewGroup? _legend;

  LegendViewGroup? get legend => _legend;

  ///整个图表只有一个
  ToolTipView? _toolTip;

  ToolTipView? get toolTip => _toolTip;

  /// 创建Chart组件
  /// 组件是除了渲染视图之外的全部控件
  void _createComponent() {
    ///图例
    if (config.legend != null) {
      _legend = LegendViewGroup(config.legend!);
      _legend?.create(this, root);
      //TODO 这里不知道是否需要回调[bindSeriesCommand]
    }

    ///title
    if (config.title != null) {
      _title = TitleView(config.title!);
      _title?.create(this, root);
      //TODO 这里不知道是否需要回调[bindSeriesCommand]
    }

    ///Coord
    ///转换CoordConfig 到Coord
    List<CoordConfig> coordConfigList = [
      config.grid,
      ...config.polarList,
      ...config.radarList,
      ...config.calendarList,
      ...config.parallelList,
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
    for (var series in config.series) {
      ChartView? view = SeriesFactory.instance.convert(series);
      if (view == null) {
        throw FlutterError('${series.runtimeType} init fail,you must provide series convert');
      }
      _seriesViewMap[series] = view;
    }

    ///将指定了坐标系的View和坐标系绑定
    _seriesViewMap.forEach((key, view) {
      Coord? layout = _findCoord(view, key);
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
  }

  void onStart() {
    _legend?.onStart();
    _title?.onStart();
    _toolTip?.onStart();
    for (var coord in coordList) {
      try {
        coord.onStart();
      } catch (e) {
        logPrint('$e');
      }
    }
  }

  void onStop() {
    _legend?.onStop();
    _title?.onStop();
    _toolTip?.onStop();
    for (var coord in coordList) {
      try {
        coord.onStop();
      } catch (e) {
        logPrint('$e');
      }
    }
  }

  void destroy() {
    _gestureDispatcher.dispose();
    _animationManager.dispose();
    _destroyView();
    _axisMap.clear();
    _coordMap.clear();
    _coordList.clear();
    _seriesViewMap.clear();
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
    _toolTip?.destroy();
    _toolTip = null;
  }

  Coord? _findCoord(ChartView view, ChartSeries series) {
    if (series.coordSystem != null) {
      var coord = series.coordSystem!;
      if (coord == CoordSystem.grid) {
        return findGridCoord();
      }
      if (coord == CoordSystem.polar) {
        return findPolarCoord(series.polarAxisIndex);
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
  GridCoord findGridCoord() {
    return _coordMap[config.grid]! as GridCoord;
  }

  PolarCoord findPolarCoord([int polarIndex = 0]) {
    if (polarIndex > config.polarList.length) {
      polarIndex = 0;
    }
    if (config.polarList.isEmpty) {
      throw FlutterError('暂无Polar坐标系');
    }
    return _coordMap[config.polarList[polarIndex]]! as PolarCoord;
  }

  RadarCoord findRadarCoord([int radarIndex = 0]) {
    if (radarIndex > config.radarList.length) {
      radarIndex = 0;
    }
    if (config.radarList.isEmpty) {
      throw FlutterError('暂无Radar坐标系');
    }
    return _coordMap[config.radarList[radarIndex]]! as RadarCoord;
  }

  ParallelCoord findParallelCoord([int parallelIndex = 0]) {
    int index = parallelIndex;
    if (index > config.parallelList.length) {
      index = 0;
    }
    if (config.parallelList.isEmpty) {
      throw FlutterError('当前未配置Parallel 坐标系无法查找');
    }
    ParallelConfig parallel = config.parallelList[index];
    return _coordMap[parallel]! as ParallelCoord;
  }

  CalendarCoord findCalendarCoord([int calendarIndex = 0]) {
    int index = calendarIndex;
    if (index > config.calendarList.length) {
      index = 0;
    }
    if (config.calendarList.isEmpty) {
      throw FlutterError('当前未配置Calendar 坐标系无法查找');
    }
    CalendarConfig calendar = config.calendarList[index];
    return _coordMap[calendar]! as CalendarCoord;
  }

  void setToolTip(ToolTipBuilder builder) {
    _toolTip?.onStop();
    _toolTip?.destroy();
    _toolTip = ToolTipView(builder);
    _toolTip?.create(this, root);
  }

  void unRegisterToolTip() {
    _toolTip?.onStop();
    _toolTip?.destroy();
    _toolTip = null;
  }

  void addGesture(ChartGesture gesture) {
    _gestureDispatcher.addGesture(gesture);
  }

  void removeGesture(ChartGesture gesture) {
    _gestureDispatcher.removeGesture(gesture);
  }

  AnimationController boundedAnimation(AnimatorProps props, [bool useUpdate = false]) {
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
}
