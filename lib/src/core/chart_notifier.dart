import 'package:flutter/foundation.dart';

class ChartNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  final bool _equalsObject;

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
  String toString() => '${describeIdentity(this)}($value)';

}
