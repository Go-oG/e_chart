import 'package:e_chart/e_chart.dart';
import 'package:flutter/foundation.dart';

class ChartNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  final bool equalsObject;
  final Set<VoidCallback> _listenerSet = {};

  ChartNotifier(this._value, [this.equalsObject = false]);

  bool _disposeFlag = false;

  @override
  T get value => _value;

  T _value;

  set value(T newValue) {
    if (equalsObject && _value == newValue) {
      _value = newValue;
      return;
    }
    _value = newValue;
    notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) {
    _listenerSet.add(listener);
    super.addListener(listener);
  }

  void clearListener() {
    if (hasListeners) {
      for (var l in _listenerSet) {
        removeListener(l);
      }
      _listenerSet.clear();
    }
  }

  @override
  void dispose() {
    clearListener();
    if (!_disposeFlag) {
      _disposeFlag = true;
      super.dispose();
    }else{
      Logger.w("已经调用过了Dispose");
    }
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';
}
