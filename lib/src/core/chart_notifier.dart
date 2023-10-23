import 'package:e_chart/e_chart.dart';
import 'package:flutter/foundation.dart';

class ChartNotifier<T> extends Disposable implements ValueListenable<T> {
  final bool equalsObject;
  Set<VoidCallback> _listenerSet = {};

  ChartNotifier(this._value, [this.equalsObject = false]);

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

  void notifyListeners() {
    each(_listenerSet, (p0, p1) {
      try {
        p0.call();
      } catch (e) {
        Logger.w(e);
      }
    });
  }

  @override
  void addListener(VoidCallback listener) {
    _listenerSet.add(listener);
  }

  bool get hasListeners => _listenerSet.isNotEmpty;

  void clearListener() {
    if (hasListeners) {
      _listenerSet = {};
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    _listenerSet.remove(listener);
  }

  void notifyChange() {
    notifyListeners();
  }

  @override
  void dispose() {
    clearListener();
    if (isDispose) {
      Logger.i("已经调用过了Dispose");
      return;
    }
    super.dispose();
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';
}

class ChartNotifier2 extends ChartNotifier<Command> {
  ChartNotifier2() : super(Command.none);

  void notifyConfigChange() {
    value = Command.configChange;
  }
}
