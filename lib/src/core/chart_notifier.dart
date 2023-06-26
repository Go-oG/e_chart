import 'package:flutter/foundation.dart';

class ChartNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  final bool _equalsObject;
  final Set<VoidCallback> _listenerSet = {};

  ChartNotifier(this._value, [this._equalsObject = false]);

  @override
  T get value => _value;

  T _value;

  set value(T newValue) {
    if (_equalsObject && _value == newValue) {
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
  String toString() => '${describeIdentity(this)}($value)';
}
