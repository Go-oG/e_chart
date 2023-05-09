import 'package:flutter/widgets.dart';

import '../chart.dart';
import '../charts/series.dart';
import '../component/axis/base_axis.dart';
import '../component/legend/layout.dart';
import '../component/tooltip/tool_tip_listener.dart';
import '../component/tooltip/tool_tip_node.dart';
import '../coord/calendar/calendar.dart';
import '../coord/calendar/calendar_child.dart';
import '../coord/calendar/calendar_layout.dart';
import '../coord/coord.dart';
import '../coord/coord_layout.dart';
import '../coord/grid/grid.dart';
import '../coord/grid/grid_child.dart';
import '../coord/grid/grid_inner.dart';
import '../coord/grid/grid_layout.dart';
import '../coord/parallel/parallel.dart';
import '../coord/parallel/parallel_child.dart';
import '../coord/parallel/parallel_layout.dart';
import '../coord/polar/polar_child.dart';
import '../coord/polar/polar_layout.dart';
import '../coord/radar/radar_child.dart';
import '../coord/radar/radar_layout.dart';
import '../coord/single/single_layout.dart';
import '../gesture/gesture_dispatcher.dart';
import '../model/enums/coordinate.dart';
import '../series_factory.dart';
import 'view.dart';
import 'view_group.dart';

///存放整个图表的运行相关的数据
class Context {
  late final ViewParent root;
  final ChartConfig config;
  final TickerProvider tickerProvider;

  late final GestureDispatcher gestureDispatcher;

  ///存放普通的视图
  final Map<ChartSeries, View> _seriesViewMap = {};

  ///坐标轴
  final Map<BaseAxis, View> _axisMap = {};

  ///存放坐标系
  final Map<Coordinate, CoordinateLayout> _coordinateViewMap = {};

  /// 存放渲染的布局组件
  final List<CoordinateLayout> _renderViewList = [];

  ///Legend
  final LegendNode _legendNode = LegendNode();

  ///ToolTip
  final ToolTipNode _toolTipNode = ToolTipNode();

  late GridInner _innerGrid;

  Context(this.config, this.tickerProvider, GestureDispatcher? dispatcher, ViewParent rootViewGroup) {
    root = rootViewGroup;
    gestureDispatcher = dispatcher ?? GestureDispatcher();
  }

  Context copy({
    ChartConfig? config,
    TickerProvider? tickerProvider,
    Size? canvasSize,
    ViewParent? rootViewGroup,
    GestureDispatcher? dispatcher,
  }) {
    return Context(
      config ?? this.config,
      tickerProvider ?? this.tickerProvider,
      dispatcher,
      rootViewGroup ?? root,
    );
  }

  void init() {
    _initComponent();
    _initTitle();
    _initChart();
    _attach();
  }

  void destroy() {
    _detach();
    _seriesViewMap.clear();
    _axisMap.clear();
    _coordinateViewMap.clear();
    _renderViewList.clear();
    _legendNode.detach();
    _toolTipNode.detach();
  }

  void _initChart() {
    _seriesViewMap.clear();
    _coordinateViewMap.clear();
    _axisMap.clear();
    _renderViewList.clear();

    ///初始化Series
    for (var series in config.series) {
      View? view = SeriesFactory.instance.convert(series);
      if (view == null) {
        throw FlutterError('${series.runtimeType} init fail,you must provide series convert');
      }
      view.bindSeries(series);
      _seriesViewMap[series] = view;
    }

    ///组合坐标系视图
    List<Coordinate> layoutList = [
      ...config.polarList,
      ...config.radarList,
      ...config.calendarList,
      ...config.parallelList,
    ];

    for (var ele in layoutList) {
      _coordinateViewMap[ele] = ele.toLayout();
    }

    Grid grid = config.grid;
    _innerGrid = GridInner(
      containLabel: grid.containLabel,
      style: grid.style,
      toolTip: grid.toolTip,
      xAxisList: [...config.xAxisList],
      yAxisList: [...config.yAxisList],
      topMargin: grid.topMargin,
      leftMargin: grid.leftMargin,
      rightMargin: grid.rightMargin,
      bottomMargin: grid.bottomMargin,
      id: grid.id,
      show: grid.show,
    );

    GridLayout gridLayout = GridLayout(_innerGrid);
    _coordinateViewMap[_innerGrid] = gridLayout;

    ///将某些特定的Series和坐标系绑定
    Set<CoordinateLayout> viewList = {};
    for (var series in config.series) {
      View view = _seriesViewMap[series]!;
      CoordinateLayout? layout = _getLayout(view, series);
      layout ??= SingleLayout();
      layout.addView(view);
      viewList.add(layout);
    }
    _renderViewList.addAll(viewList);
  }

  void _initComponent() {
    if (config.legend != null) {
      _legendNode.legend = config.legend!;
    }
  }

  void _initTitle() {}

  CoordinateLayout? _getLayout(View view, ChartSeries series) {
    if (series.coordSystem != null) {
      var coord = series.coordSystem!;
      if (coord == CoordSystem.grid) {
        return findGridCoord();
      }
      if (coord == CoordSystem.polar) {
        return findPolarCoord();
      }
      if (coord == CoordSystem.radar) {
        return findRadarCoord();
      }
      if (coord == CoordSystem.parallel) {
        return findParallelCoord();
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
    _legendNode.attach(this, root);
    _toolTipNode.attach(this, root);
    for (var element in _renderViewList) {
      element.attach(this, root);
    }
  }

  void _detach() {
    _legendNode.detach();
    _toolTipNode.detach();
    for (var element in _renderViewList) {
      element.unBindSeries();
      element.detach();
    }
  }

  GridLayout findGridCoord() {
    return _findCoordInner(_innerGrid) as GridLayout;
  }

  PolarLayout findPolarCoord([int polarIndex = 0]) {
    if (polarIndex > config.polarList.length) {
      polarIndex = 0;
    }
    if (config.polarList.isEmpty) {
      throw FlutterError('暂无Polar坐标系');
    }
    return _findCoordInner(config.polarList[polarIndex]) as PolarLayout;
  }

  RadarLayout findRadarCoord([int radarIndex = 0]) {
    if (radarIndex > config.radarList.length) {
      radarIndex = 0;
    }
    if (config.radarList.isEmpty) {
      throw FlutterError('暂无Radar坐标系');
    }

    return _findCoordInner(config.radarList[radarIndex]) as RadarLayout;
  }

  ParallelLayout findParallelCoord([int parallelIndex = 0]) {
    int index = parallelIndex;
    if (index > config.parallelList.length) {
      index = 0;
    }
    if (config.parallelList.isEmpty) {
      throw FlutterError('当前未配置Parallel 坐标系无法查找');
    }
    Parallel parallel = config.parallelList[index];

    CoordinateLayout layout = _findCoordInner(parallel);
    return layout as ParallelLayout;
  }

  CalendarLayout findCalendarCoord([int calendarIndex = 0]) {
    int index = calendarIndex;
    if (index > config.calendarList.length) {
      index = 0;
    }
    if (config.calendarList.isEmpty) {
      throw FlutterError('当前未配置Calendar 坐标系无法查找');
    }
    Calendar calendar = config.calendarList[index];
    return _findCoordInner(calendar) as CalendarLayout;
  }

  ///给定坐标系返回坐标系视图
  CoordinateLayout _findCoordInner(Coordinate coordinate) {
    return _coordinateViewMap[coordinate]!;
  }

  ///返回渲染的View节点
  List<CoordinateLayout> get renderList => _renderViewList;

  ///整个图标最多只有一个
  ToolTipNode get toolTipNode => _toolTipNode;

  void registerToolTip(ToolTipListener listener) {
    _toolTipNode.add(listener);
  }

  void unRegisterToolTip(ToolTipListener listener) {
    _toolTipNode.remove(listener);
  }
}
