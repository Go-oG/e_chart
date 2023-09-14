import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///用于辅助布局相关的抽象类
///其包含了事件分发和触摸事件处理
///一般情况下和SeriesView 配合使用
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

  ///布局边界
  Rect boxBound = Rect.zero;
  Rect globalBoxBound = Rect.zero;

  ///手势相关的中间量

  ///记录平移量(区分正负)
  ChartOffset translation = ChartOffset(0, 0);

  ///构造函数
  LayoutHelper(Context context, S series, {bool equalsObject = false}) : super(Command.none, equalsObject) {
    _context = context;
    _series = series;
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

  void stopLayout() {}

  double get width => boxBound.width;

  double get height => boxBound.height;

  ///=========手势处理================
  void onClick(Offset localOffset) {}

  void onHoverStart(Offset localOffset) {}

  void onHoverMove(Offset localOffset) {}

  void onHoverEnd() {}

  void onDragStart(Offset offset) {}

  void onDragMove(Offset offset, Offset diff) {}

  void onDragEnd() {}

  ///=========事件通知========
  ///Brush
  void onBrushEvent(BrushEvent event) {}

  void onBrushEndEvent(BrushEndEvent event) {}

  void onBrushClearEvent(BrushClearEvent event) {}

  ///Legend
  void onLegendSelectedEvent(LegendSelectedEvent event) {}

  void onLegendUnSelectedEvent(LegendUnSelectedEvent event) {}

  void onLegendSelectChangeEvent(LegendSelectChangeEvent event) {}

  void onLegendScrollEvent(LegendScrollEvent event) {}

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
    return translation.toOffset();
  }

  double get translationX => translation.x.toDouble();

  set translationX(num x) => translation.x = x;

  double get translationY => translation.y.toDouble();

  set translationY(num y) => translation.y = y;

  void resetTranslation() => translation.x = translation.y = 0;

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
  AnimationAttrs? getAnimation(LayoutType type, [int count = -1]) {
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
}

abstract class LayoutHelper2<N extends DataNode, S extends ChartSeries> extends LayoutHelper<S> {
  List<N> nodeList = [];

  LayoutHelper2(super.context, super.series);

  LayoutHelper2.lazy() : super.lazy();

  @override
  void onDragMove(Offset offset, Offset diff) {
    translation.add(diff);
    notifyLayoutUpdate();
  }

  @override
  void onClick(Offset localOffset) {
    onHandleHoverAndClick(localOffset, true);
  }

  @override
  void onHoverStart(Offset localOffset) {
    onHandleHoverAndClick(localOffset, false);
  }

  @override
  void onHoverMove(Offset localOffset) {
    onHandleHoverAndClick(localOffset, false);
  }

  @override
  void onHoverEnd() {
    var old = oldHoverNode;
    oldHoverNode = null;
    if (old == null) {
      return;
    }
    sendHoverEndEvent(old);
    var oldAttr = old.toAttr();
    old.removeState(ViewState.hover);
    onUpdateNodeStyle(old);
    var animation = getAnimation(LayoutType.update, 2);

    if (animation == null) {
      notifyLayoutUpdate();
      return;
    }
    onRunUpdateAnimation([NodeDiff(old, oldAttr, old.toAttr(), true)], animation);
  }

  N? oldHoverNode;

  void onHandleHoverAndClick(Offset offset, bool click) {
    var oldOffset = offset;
    Offset scroll = getTranslation();
    offset = offset.translate2(scroll.invert);
    var clickNode = findNode(offset);
    if (oldHoverNode == clickNode) {
      if (clickNode != null) {
        click ? sendClickEvent(oldOffset, clickNode) : sendHoverEvent(oldOffset, clickNode);
      }
      return;
    }
    var oldNode = oldHoverNode;
    oldHoverNode = clickNode;
    if (oldNode != null) {
      sendHoverEndEvent(oldNode);
    }
    if (clickNode != null) {
      click ? sendClickEvent(oldOffset, clickNode) : sendHoverEvent(oldOffset, clickNode);
    }

    List<NodeDiff<N>> nl = [];

    if (oldNode != null) {
      var oldAttr = oldNode.toAttr();
      oldNode.removeState(ViewState.hover);
      onUpdateNodeStyle(oldNode);
      nl.add(NodeDiff(oldNode, oldAttr, oldNode.toAttr(), true));
    }

    if (clickNode != null) {
      var newAttr = clickNode.toAttr();
      clickNode.addState(ViewState.hover);
      onUpdateNodeStyle(clickNode);
      nl.add(NodeDiff(clickNode, newAttr, clickNode.toAttr(), false));
    }

    var animator = getAnimation(LayoutType.update, 2);
    if (animator == null) {
      onHandleHoverAndClickEnd(oldNode, clickNode);
      notifyLayoutUpdate();
      return;
    }
    if (nl.isNotEmpty) {
      onRunUpdateAnimation(nl, animator);
    }
    onHandleHoverAndClickEnd(oldNode, clickNode);
  }

  void onHandleHoverAndClickEnd(N? oldNode, N? newNode) {}

  void onUpdateNodeStyle(N node) {
    node.updateStyle(context, series);
  }

  void onRunUpdateAnimation(List<NodeDiff<N>> list, AnimationAttrs animation) {
    List<ChartTween> tl = [];
    for (var diff in list) {
      var node = diff.node;
      var s = diff.startAttr;
      var e = diff.endAttr;
      var tween = ChartDoubleTween(props: animation);
      tween.addListener(() {
        var t = tween.value;
        node.itemStyle = AreaStyle.lerp(s.itemStyle, e.itemStyle, t);
        node.borderStyle = LineStyle.lerp(s.borderStyle, e.borderStyle, t);
        notifyLayoutUpdate();
      });
      tl.add(tween);
    }
    for (var tw in tl) {
      tw.start(context, true);
    }
  }

  void sortList(List<N> nodeList) {
    nodeList.sort((a, b) {
      if (a.drawIndex == 0 && b.drawIndex == 0) {
        return a.dataIndex.compareTo(b.dataIndex);
      }
      if (a.drawIndex != 0) {
        return 1;
      }
      return 0;
    });
  }

  N? findNode(Offset offset) {
    var hoveNode = oldHoverNode;
    if (hoveNode != null && hoveNode.contains(offset)) {
      return hoveNode;
    }
    for (var node in nodeList) {
      if (node.contains(offset)) {
        return node;
      }
    }
    return null;
  }
}

class NodeDiff<N extends DataNode> {
  final N node;
  final NodeAttr startAttr;
  final NodeAttr endAttr;
  final bool old;

  const NodeDiff(this.node, this.startAttr, this.endAttr, this.old);
}

enum LayoutType {
  ///该布局方式将拒绝所有的动画，
  none,

  ///该布局方式表示触发类型为全量布局
  ///使用的动画参数类型为普通参数
  layout,

  ///该布局方式表示是更新布局
  ///使用的动画参数为带update的前缀
  update,
}
