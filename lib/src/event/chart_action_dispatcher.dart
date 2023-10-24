import 'package:e_chart/e_chart.dart';

///行为分发器
///用于程序模拟用户操作
class ActionDispatcher extends Disposable {
  final Set<Fun2<ChartAction, bool>> _callSet = {};

  ActionDispatcher();

  void addCall(Fun2<ChartAction, bool> call) {
    _callSet.add(call);
  }

  void removeCall(Fun2<ChartAction, bool> call) {
    _callSet.remove(call);
  }

  @override
  void dispose() {
    _callSet.clear();
    super.dispose();
  }

  void dispatch(ChartAction action) {
    for (var call in _callSet) {
      if (call.call(action)) {
        return;
      }
    }
  }
}
