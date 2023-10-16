import 'package:e_chart/e_chart.dart';

///事件分发器
///用于处理
class EventDispatcher {
  ///存放普通的事件回调
  final Set<VoidFun1<ChartEvent>> _normalSet = {};

  ///组件、坐标系相关的事件通知
  final Set<VoidFun1<ChartEvent>> _renderSet = {};
  final Set<VoidFun1<ChartEvent>> _dataZoomSet = {};
  final Set<VoidFun1<ChartEvent>> _coordScrollSet = {};
  final Set<VoidFun1<ChartEvent>> _coordChangeSet = {};
  final Set<VoidFun1<ChartEvent>> _brushSet = {};
  final Set<VoidFun1<ChartEvent>> _legendSet = {};

  ///手势
  final Set<VoidFun1<ChartEvent>> _clickSet = {};
  final Set<VoidFun1<ChartEvent>> _hoverSet = {};
  final Set<VoidFun1<ChartEvent>> _longPressSet = {};
  final Set<VoidFun1<ChartEvent>> _dragSet = {};
  final Set<VoidFun1<ChartEvent>> _doubleClickSet = {};

  final Map<EventType, Set<VoidFun1<ChartEvent>>> _callMap = {};

  EventDispatcher() {
    _callMap[EventType.normal] = _normalSet;
    _callMap[EventType.brush] = _brushSet;
    _callMap[EventType.legend] = _legendSet;
    _callMap[EventType.dataZoom] = _dataZoomSet;
    _callMap[EventType.coordScroll] = _coordScrollSet;
    _callMap[EventType.coordLayoutChange] = _coordChangeSet;
    _callMap[EventType.click] = _clickSet;
    _callMap[EventType.hover] = _hoverSet;
    _callMap[EventType.longPress] = _longPressSet;
    _callMap[EventType.drag] = _dragSet;
    _callMap[EventType.doubleClick] = _doubleClickSet;
    _callMap[EventType.render] = _renderSet;
  }

  void addCall(EventType type, VoidFun1<ChartEvent> call) {
    var set = _callMap[type] ?? _callMap[EventType.normal]!;
    set.add(call);
  }

  void removeCall(VoidFun1<ChartEvent> call) {
    _callMap.forEach((key, value) {
      value.remove(call);
    });
  }

  void dispatch(ChartEvent event) {
    var type=event.eventType;
    if(type==EventType.click){
      Logger.i('$runtimeType dispatch($event)');
    }
    var set = _callMap[event.eventType] ?? _callMap[EventType.normal]!;
    each(set, (call, p1) {
      try {
        call.call(event);
      } catch (e) {
        Logger.e(e);
      }
    });
  }

  void dispose() {
    _callMap.clear();
  }
}

enum EventType {
  normal,
  render,
  brush,
  legend,
  dataZoom,
  coordScroll,
  coordLayoutChange,
  click,
  hover,
  longPress,
  drag,
  doubleClick,
}
