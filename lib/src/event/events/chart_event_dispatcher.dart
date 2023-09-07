import 'package:e_chart/e_chart.dart';

///事件分发器
///用于处理
class EventDispatcher {
  final Set<VoidFun1<ChartEvent>> _callSet = {};

  EventDispatcher();

  void addCall(VoidFun1<ChartEvent> call) {
    _callSet.add(call);
  }

  void removeCall(VoidFun1<ChartEvent> call) {
    _callSet.remove(call);
  }

  void dispatch(ChartEvent event) {
    // Logger.i('$runtimeType dispatch($event)');
    for (var call in _callSet) {
      try {
        call.call(event);
      } catch (e) {
        Logger.e(e);
      }
    }
  }

  void dispose() {
    _callSet.clear();
  }
}
