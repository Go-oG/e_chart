import 'package:e_chart/e_chart.dart';

///事件分发器
///用于处理
class EventDispatcher extends Disposable {
  final Map<EventType, Set<VoidFun1<ChartEvent>>> _callMap = {};

  EventDispatcher();

  void addCall(EventType type, VoidFun1<ChartEvent> call) {
    var set = _callMap[type] ?? {};
    _callMap[type] = set;
    set.add(call);
  }

  void removeCall(VoidFun1<ChartEvent> call) {
    _callMap.forEach((key, value) {
      value.remove(call);
    });
  }

  void removeCall2(EventType type, VoidFun1<ChartEvent> call) {
    _callMap[type]?.remove(call);
  }

  void dispatch(ChartEvent event) {
    var type = event.eventType;
    if (type == EventType.click) {
      Logger.i('$runtimeType dispatch($event)');
    }
    var set = _callMap[event.eventType];
    if (set == null||set.isEmpty) {
      return;
    }
    each(set, (call, p1) {
     // try {
        call.call(event);
      // } catch (e) {
      //   Logger.e(e);
      // }
    });
  }

  @override
  void dispose() {
    _callMap.clear();
    super.dispose();
  }

  bool hasEventListener(EventType? type) {
    for (var entry in _callMap.entries) {
      if ((type == null || type == entry.key) && entry.value.isNotEmpty) {
        return true;
      }
    }
    return false;
  }
}

///事件类别
class EventType {
  ///通用事件
  static const normal = EventType("normal");

  ///图表被销毁
  static const chartDispose = EventType("destroy");

  ///单帧渲染结束事件
  static const rendered = EventType("render");

  //======组件相关事件==========
  ///框选组件相关事件
  static const brushStart = EventType("brushStart");
  static const brushUpdate = EventType("brushUpdate");
  static const brushEnd = EventType("brushEnd");

  ///坐标轴显示范围发生更改(其总范围不变)
  static const axisScroll = EventType("axisScroll");

  ///坐标轴范围发生更改
  static const axisChange = EventType("axisChange");
  static const axisLabelClick = EventType("axisLabelClick");

  ///图例滚动事件
  static const legendScroll = EventType("legendScroll");

  ///图例反选后的事件
  static const legendInverseSelect = EventType("legendInverseSelect");

  ///图例全选后的事件
  static const legendSelectAll = EventType("legendSelectAll");

  ///图例取消选中后的事件
  static const legendUnSelect = EventType("legendUnSelect");

  ///切换图例选中状态后的事件
  static const legendSelectChanged = EventType("legendSelectChanged");

  ///平行坐标系选中事件
  static const parallelSelected = EventType("parallelSelected");

  ///seriesView 发生缩放
  static const seriesViewScale = EventType("seriesViewScale");

  ///seriesView 发生平移
  static const seriesViewTranslation = EventType("seriesViewTranslation");

  ///数据状态发生了变化时显示
  static const dataStatusChanged = EventType("dataSelectChanged");

  ///坐标系发生滚动
  // static const coordScroll = EventType("coordScroll");

  ///坐标系布局发生改变
  static const coordLayoutChange = EventType("coordLayoutChange");

  //=======由手势触发的相关的事件=======
  static const click = EventType("click");

  static const hoverStart = EventType("hoverStart");
  static const hoverUpdate = EventType("hoverUpdate");
  static const hoverEnd = EventType("hoverEnd");

  static const longPressStart = EventType("longPressStart");
  static const longPressUpdate = EventType("longPressUpdate");
  static const longPressEnd = EventType("longPressEnd");

  static const dragStart = EventType("dragStart");
  static const dragEnd = EventType("dragEnd");
  static const dragUpdate = EventType("dragUpdate");
  static const doubleClick = EventType("doubleClick");

  final String key;

  const EventType(this.key);

  @override
  String toString() {
    return key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is EventType && other.key == key;
  }
}
