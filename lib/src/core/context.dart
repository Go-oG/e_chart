import 'package:flutter/widgets.dart';

import '../animation/index.dart';
import '../chart.dart';
import '../charts/series.dart';
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
import '../model/enums/coordinate.dart';
import '../series_factory.dart';
import 'view.dart';
import 'view_group.dart';

///存放整个图表的配置以及相关的图形实例
///和运行所必须的组件
class Context {
  final ViewParent root;
  final ChartConfig config;

  ///这里不将其暴露出去是为了能更好的管理动画的生命周期
  late TickerProvider _provider;
  final GestureDispatcher _gestureDispatcher = GestureDispatcher();
  final AnimationManager _animationManager = AnimationManager();
  double devicePixelRatio;

  GestureDispatcher get gestureDispatcher => _gestureDispatcher;

  AnimationManager get animationManager => _animationManager;

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

  ///存放普通的视图
  final Map<ChartSeries, ChartView> _seriesMap = {};

  /// 存放渲染的布局组件
  final List<Coord> _renderList = [];

  List<Coord> get renderList => _renderList;

  ///Title(全局只会存在一个)
  TitleView? _title;

  TitleView? get title => _title;

  ///图例(全局一个实例)
  LegendViewGroup? _legend;

  LegendViewGroup? get legend => _legend;

  ///整个图表只有一个
  ToolTipView? _toolTip;

  ToolTipView? get toolTip => _toolTip;

  void init() {
    _initComponent();
    _initTitle();
    _initChart();
    _attach();
  }

  void destroy() {
    _gestureDispatcher.dispose();
    _animationManager.dispose();
    _detach();
    _seriesMap.clear();
    _axisMap.clear();
    _coordMap.clear();
    _renderList.clear();
  }

  void _initChart() {
    _seriesMap.clear();
    _coordMap.clear();
    _axisMap.clear();
    _renderList.clear();

    ///转换Series到View
    for (var series in config.series) {
      ChartView? view = SeriesFactory.instance.convert(series);
      if (view == null) {
        throw FlutterError('${series.runtimeType} init fail,you must provide series convert');
      }
      view.bindSeriesCommand(series);
      _seriesMap[series] = view;
    }

    ///转换CoordConfig 到Coord
    List<CoordConfig> layoutList = [
      config.grid,
      ...config.polarList,
      ...config.radarList,
      ...config.calendarList,
      ...config.parallelList,
    ];
    for (var ele in layoutList) {
      var c = CoordFactory.instance.convert(ele);
      if (c != null) {
        _coordMap[ele] = c;
      }
    }

    ///将指定了坐标系的View和坐标系绑定
    Set<Coord> viewList = {};
    for (var series in config.series) {
      ChartView view = _seriesMap[series]!;
      Coord? layout = _findCoord(view, series);
      layout ??= SingleCoordImpl();
      layout.addView(view);
      viewList.add(layout);
    }
    _renderList.addAll(viewList);
  }

  void _initComponent() {
    if (config.legend != null) {
      _legend = LegendViewGroup(config.legend!);
    }
  }

  void _initTitle() {}

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

  void _attach() {
    _legend?.attach(this, root);
    for (var element in _renderList) {
      element.attach(this, root);
    }
  }

  void _detach() {
    _legend?.detach();
    _legend = null;
    _toolTip?.detach();
    _toolTip = null;
    _gestureDispatcher.dispose();

    for (var element in _renderList) {
      element.unBindSeries();
      element.detach();
    }
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
    _toolTip?.detach();
    _toolTip = ToolTipView(builder);
  }

  void unRegisterToolTip() {
    _toolTip?.detach();
    _toolTip = null;
  }

  void addGesture(ChartGesture gesture) {
    _gestureDispatcher.addGesture(gesture);
  }

  void removeGesture(ChartGesture gesture) {
    _gestureDispatcher.removeGesture(gesture);
  }

  AnimationController boundedAnimation(AnimatorProps props) {
    return _animationManager.bounded(_provider, props);
  }

  AnimationController unboundedAnimation() {
    return _animationManager.unbounded(_provider);
  }
}
