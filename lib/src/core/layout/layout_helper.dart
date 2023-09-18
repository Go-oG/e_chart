import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/cupertino.dart';

///用于辅助布局相关的抽象类，通常和SeriesView 配合使用
///其包含了Chart事件分发、处理以及手势相关的处理
abstract class LayoutHelper<S extends ChartSeries> extends ChartNotifier<Command> {
  Context? _context;

  Context get context {
    var c = _context;
    if (c == null) {
      throw ChartError("Context is Null, This LayoutHelper($runtimeType) maybe dispose");
    }
    return c;
  }

  set context(Context c) => _context = c;

  Context? get contextNull => _context;

  S? _series;

  set series(S s) => _series = s;

  S get series {
    var s = _series;
    if (s == null) {
      throw ChartError("Series is Null, This LayoutHelper($runtimeType) maybe dispose");
    }
    return s;
  }

  S? get seriesNull => _series;

  ChartView? _view;

  ChartView get view => _view!;

  ChartView? get viewNull => _view;

  set view(ChartView? v) => _view = v;

  void clearRef() {
    clearListener();
    _series = null;
    _context = null;
    _view = null;
  }

  ///布局边界
  Rect boxBound = Rect.zero;
  Rect globalBoxBound = Rect.zero;

  ///标识是否在运行动画
  bool inAnimation = false;

  ///控制在动画期间是否允许手势
  bool allowGestureInAnimation = false;

  ///手势相关的中间量

  ///构造函数
  LayoutHelper(Context context, ChartView view, S series, {bool equalsObject = false})
      : super(Command.none, equalsObject) {
    _context = context;
    _series = series;
    _view = view;
  }

  ///该构造方法用于在无法马上初始化时使用
  ///一般用于Graph等存在多个Layout方式的视图中
  LayoutHelper.lazy({bool equalsObject = false}) : super(Command.none, equalsObject);

  ///==========布局测量相关===========
  void doMeasure(double parentWidth, double parentHeight) {
    this.boxBound = Rect.fromLTWH(0, 0, parentWidth, parentHeight);
    onMeasure();
  }

  void doLayout(Rect boxBound, Rect globalBoxBound, LayoutType type) {
    this.boxBound = boxBound;
    this.globalBoxBound = globalBoxBound;
    onLayout(type);
  }

  void onLayout(LayoutType type);

  void onMeasure() {}

  void stopLayout() {
    unregisterBrushListener();
    unregisterLegendListener();
  }

  @override
  void dispose() {
    unregisterLegendListener();
    unregisterBrushListener();
    _view = null;
    _series = null;
    _context = null;
    super.dispose();
  }

  ///=========手势处理================
  void onClick(Offset localOffset) {}

  void onHoverStart(Offset localOffset) {}

  void onHoverMove(Offset localOffset) {}

  void onHoverEnd() {}

  void onDragStart(Offset offset) {}

  void onDragMove(Offset offset, Offset diff) {}

  void onDragEnd() {}

  ///=========坐标系相关事件处理========
  void onCoordScrollStart(CoordScroll scroll) {}

  void onCoordScrollUpdate(CoordScroll scroll) {}

  void onCoordScrollEnd(CoordScroll scroll) {}

  void onCoordScaleStart(CoordScale scale) {}

  void onCoordScaleUpdate(CoordScale scale) {}

  void onCoordScaleEnd(CoordScale scale) {}

  void onLayoutByParent(LayoutType type) {}

  ///dataZoom
  void onDataZoom(DataZoomEvent event) {}

  ///==============事件发送============
  void sendClickEvent(Offset offset, DataNode node, [ComponentType componentType = ComponentType.series]) {
    var event = UserClickEvent(offset, toGlobal(offset), buildEvent(node, componentType));
    context.dispatchEvent(event);
  }

  bool equalsEvent(EventInfo old, DataNode node, ComponentType type) {
    return old.seriesIndex == series.seriesIndex &&
        old.componentType == type &&
        old.data == node.data &&
        old.dataType == node.dataType &&
        old.dataIndex == node.dataIndex &&
        old.node == node &&
        old.groupIndex == node.groupIndex &&
        old.seriesType == seriesType;
  }

  UserHoverEvent? _lastHoverEvent;

  void sendHoverEvent(Offset offset, DataNode node, [ComponentType componentType = ComponentType.series]) {
    var lastEvent = _lastHoverEvent;
    UserHoverEvent? event;
    if (lastEvent != null) {
      var old = lastEvent.event;
      if (equalsEvent(old, node, componentType)) {
        event = lastEvent;
        event.localOffset = offset;
        event.globalOffset = toGlobal(offset);
      }
    }
    event ??= UserHoverEvent(
      offset,
      toGlobal(offset),
      buildEvent(node, componentType),
    );
    _lastHoverEvent = event;
    context.dispatchEvent(event);
  }

  void sendHoverEndEvent(DataNode node, [ComponentType componentType = ComponentType.series]) {
    context.dispatchEvent(UserHoverEndEvent(buildEvent(node, componentType)));
  }

  EventInfo buildEvent(DataNode node, [ComponentType componentType = ComponentType.series]) {
    return EventInfo(
      componentType: componentType,
      data: node.data,
      node: node,
      dataIndex: node.dataIndex,
      dataType: node.dataType,
      groupIndex: node.groupIndex,
      seriesType: seriesType,
      seriesIndex: series.seriesIndex,
    );
  }

  SeriesType get seriesType;

  ///========查找坐标系函数=======================
  GridCoord findGridCoord() {
    return context.findGridCoord(series.gridIndex);
  }

  GridCoord? findGridCoordNull() {
    return context.findGridCoordNull(series.gridIndex);
  }

  GridAxis findGridAxis(int index, bool isXAxis) {
    return findGridCoord().getAxis(index, isXAxis);
  }

  PolarCoord findPolarCoord() {
    return context.findPolarCoord(series.polarIndex);
  }

  PolarCoord? findPolarCoordNull() {
    return context.findPolarCoordNull(series.polarIndex);
  }

  CalendarCoord findCalendarCoord() {
    return context.findCalendarCoord(series.calendarIndex);
  }

  CalendarCoord? findCalendarCoordNull() {
    return context.findCalendarCoordNull(series.calendarIndex);
  }

  ParallelCoord findParallelCoord() {
    return context.findParallelCoord(series.parallelIndex);
  }

  ParallelCoord? findParallelCoordNull() {
    return context.findParallelCoordNull(series.parallelIndex);
  }

  RadarCoord findRadarCoord() {
    return context.findRadarCoord(series.radarIndex);
  }

  RadarCoord? findRadarCoordNull() {
    return context.findRadarCoordNull(series.radarIndex);
  }

  ///========通知布局节点刷新=======
  void notifyLayoutUpdate() {
    value = Command.layoutUpdate;
  }

  void notifyLayoutEnd() {
    value = Command.layoutEnd;
  }

  ///========坐标转换=======
  Offset toLocal(Offset global) {
    return Offset(global.dx - globalBoxBound.left, global.dy - globalBoxBound.top);
  }

  Offset toGlobal(Offset local) {
    return Offset(local.dx + globalBoxBound.left, local.dy + globalBoxBound.top);
  }

  ///获取平移偏移量
  Offset getTranslation() {
    var type = series.coordType;
    Offset? offset;
    if (type == CoordType.polar) {
      offset = findParallelCoordNull()?.translation;
    } else if (type == CoordType.calendar) {
      offset = findCalendarCoordNull()?.translation;
    } else if (type == CoordType.radar) {
      offset = findRadarCoordNull()?.translation;
    } else if (type == CoordType.parallel) {
      offset = findParallelCoordNull()?.translation;
    } else if (type == CoordType.grid) {
      offset = findGridCoordNull()?.translation;
    }
    if (offset != null) {
      return offset;
    }
    return viewNull?.translation ?? Offset.zero;
  }

  double get translationX => view.translationX;

  set translationX(num x) => view.translationX = x.toDouble();

  double get translationY => view.translationY;

  set translationY(num y) => view.translationY = y.toDouble();

  void resetTranslation() => view.translationX = view.translationY = 0;

  double get width => boxBound.width;

  double get height => boxBound.height;

  ///获取裁剪路径
  Rect getClipRect(Direction direction, [double animationPercent = 1]) {
    if (animationPercent > 1) {
      animationPercent = 1;
    }
    if (animationPercent < 0) {
      animationPercent = 0;
    }
    if (direction == Direction.horizontal) {
      return Rect.fromLTWH(translationX.abs(), translationY.abs(), width * animationPercent, height);
    } else {
      return Rect.fromLTWH(translationX.abs(), translationY.abs(), width, height * animationPercent);
    }
  }

  ///获取动画运行配置(可以为空)
  AnimatorOption? getAnimation(LayoutType type, [int count = -1]) {
    var attr = series.animation ?? context.option.animation;
    if (type == LayoutType.none || attr == null) {
      return null;
    }
    if (count > 0 && count > attr.threshold && attr.threshold > 0) {
      return null;
    }
    if (type == LayoutType.layout) {
      if (attr.duration.inMilliseconds <= 0) {
        return null;
      }
      return attr;
    }
    if (type == LayoutType.update) {
      if (attr.updateDuration.inMilliseconds <= 0) {
        return null;
      }
      return attr;
    }
    return null;
  }

  ///子类可以覆写该方法实现部分绘制
  bool needDraw<T>(T node) {
    return true;
  }

  ///注册Brush组件 Event监听器
  VoidFun1<ChartEvent>? _brushListener;

  void registerBrushListener() {
    _context?.removeEventCall(_brushListener);
    _brushListener = (event) {
      if (event is BrushEvent) {
        onBrushEvent(event);
        return;
      }
      if (event is BrushClearEvent) {
        onBrushClearEvent(event);
        return;
      }
      if (event is BrushClearEvent) {
        onBrushClearEvent(event);
        return;
      }
    };
    _context?.addEventCall(_brushListener);
  }

  void unregisterBrushListener() {
    _context?.removeEventCall(_brushListener);
    _brushListener = null;
  }

  void onBrushEvent(BrushEvent event) {}

  void onBrushEndEvent(BrushEndEvent event) {}

  void onBrushClearEvent(BrushClearEvent event) {}

  /// 注册Legend组件事件
  VoidFun1<ChartEvent>? _legendListener;

  void registerLegendListener() {
    _context?.removeEventCall(_legendListener);
    _legendListener = (event) {
      if (event is LegendSelectedEvent) {
        onLegendSelectedEvent(event);
        return;
      }
      if (event is LegendUnSelectedEvent) {
        onLegendUnSelectedEvent(event);
        return;
      }
      if (event is LegendSelectChangeEvent) {
        onLegendSelectChangeEvent(event);
        return;
      }
      if (event is LegendScrollEvent) {
        onLegendScrollEvent(event);
        return;
      }
    };
    _context?.addEventCall(_legendListener);
  }

  void onLegendSelectedEvent(LegendSelectedEvent event) {}

  void onLegendUnSelectedEvent(LegendUnSelectedEvent event) {}

  void onLegendSelectChangeEvent(LegendSelectChangeEvent event) {}

  void onLegendScrollEvent(LegendScrollEvent event) {}

  void unregisterLegendListener() {}
//========Legend 结束================



}
