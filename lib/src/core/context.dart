import 'package:flutter/widgets.dart';

import '../chart.dart';
import '../charts/series.dart';
import '../component/axis/base_axis.dart';
import '../component/legend/layout.dart';
import '../component/title/title_view.dart';
import '../component/tooltip/context_menu_builder.dart';
import '../component/tooltip/tool_tip_view.dart';
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
import '../gesture/chart_gesture.dart';
import '../gesture/gesture_dispatcher.dart';
import '../model/enums/coordinate.dart';
import '../series_factory.dart';
import 'view.dart';
import 'view_group.dart';

///存放整个图表的运行相关的数据
class Context {
  final ViewParent root;
  final ChartConfig config;
  final TickerProvider tickerProvider;

  late final GestureDispatcher _gestureDispatcher;

  GestureDispatcher get gestureDispatcher => _gestureDispatcher;

  ///坐标轴
  final Map<BaseAxis, View> _axisMap = {};

  ///坐标系
  final Map<Coordinate, CoordinateLayout> _coordMap = {};

  ///存放普通的视图
  final Map<ChartSeries, View> _seriesMap = {};

  /// 存放渲染的布局组件
  final List<CoordinateLayout> _renderList = [];

  List<CoordinateLayout> get renderList => _renderList;

  ///Title(全局只会存在一个)
  TitleView? _title;
  TitleView? get title => _title;

  ///图例(全局一个实例)
  LegendViewGroup? _legend;

  LegendViewGroup? get legend => _legend;

  ///整个图表只有一个
  ToolTipView? _toolTip;

  ToolTipView? get toolTip => _toolTip;

  //GridLayout
  late GridInner _innerGrid;

  Context(this.root, this.config, this.tickerProvider, [GestureDispatcher? dispatcher]) {
    _gestureDispatcher = dispatcher ?? GestureDispatcher();
  }

  Context copy({
    ChartConfig? config,
    TickerProvider? tickerProvider,
    Size? canvasSize,
    ViewParent? root,
    GestureDispatcher? dispatcher,
  }) {
    return Context(
      root ?? this.root,
      config ?? this.config,
      tickerProvider ?? this.tickerProvider,
      dispatcher ?? _gestureDispatcher,
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
    _seriesMap.clear();
    _axisMap.clear();
    _coordMap.clear();
    _renderList.clear();
    _legend?.detach();
    _legend = null;
  }

  void _initChart() {
    _seriesMap.clear();
    _coordMap.clear();
    _axisMap.clear();
    _renderList.clear();

    ///初始化Series
    for (var series in config.series) {
      View? view = SeriesFactory.instance.convert(series);
      if (view == null) {
        throw FlutterError('${series.runtimeType} init fail,you must provide series convert');
      }
      view.bindSeries(series);
      _seriesMap[series] = view;
    }

    ///组合坐标系视图
    List<Coordinate> layoutList = [
      ...config.polarList,
      ...config.radarList,
      ...config.calendarList,
      ...config.parallelList,
    ];

    for (var ele in layoutList) {
      _coordMap[ele] = ele.toLayout();
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
    _coordMap[_innerGrid] = gridLayout;

    ///将某些特定的Series和坐标系绑定
    Set<CoordinateLayout> viewList = {};
    for (var series in config.series) {
      View view = _seriesMap[series]!;
      CoordinateLayout? layout = _findCoordLayout(view, series);
      layout ??= SingleLayout();
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

  CoordinateLayout? _findCoordLayout(View view, ChartSeries series) {
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
    _legend?.attach(this, root);
    for (var element in _renderList) {
      element.attach(this, root);
    }
  }

  void _detach() {
    _legend?.detach();
    _gestureDispatcher.dispose();
    for (var element in _renderList) {
      element.unBindSeries();
      element.detach();
    }
  }

  /// 坐标系查找相关函数
  GridLayout findGridCoord() {
    return _coordMap[_innerGrid] as GridLayout;
  }

  PolarLayout findPolarCoord([int polarIndex = 0]) {
    if (polarIndex > config.polarList.length) {
      polarIndex = 0;
    }
    if (config.polarList.isEmpty) {
      throw FlutterError('暂无Polar坐标系');
    }
    return _coordMap[config.polarList[polarIndex]]! as PolarLayout;
  }

  RadarLayout findRadarCoord([int radarIndex = 0]) {
    if (radarIndex > config.radarList.length) {
      radarIndex = 0;
    }
    if (config.radarList.isEmpty) {
      throw FlutterError('暂无Radar坐标系');
    }
    return _coordMap[config.radarList[radarIndex]]! as RadarLayout;
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
    return _coordMap[parallel]! as ParallelLayout;
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
    return _coordMap[calendar]! as CalendarLayout;
  }

  void addGesture(ChartGesture gesture) {
    _gestureDispatcher.addGesture(gesture);
  }

  void removeGesture(ChartGesture gesture) {
    _gestureDispatcher.removeGesture(gesture);
  }

  void setToolTip(ToolTipBuilder builder) {
    _toolTip?.detach();
    _toolTip = ToolTipView(builder);
  }

  void unRegisterToolTip() {
    _toolTip?.detach();
    _toolTip = null;
  }
}
