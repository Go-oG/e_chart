import 'package:e_chart/e_chart.dart';
import 'package:flutter/foundation.dart';

///对官方ChangeNotifier的改造
class ChartNotifier<T> extends Disposable implements ValueListenable<T> {
  ///提高性能
  static final List<VoidCallback?> _emptyList = List.filled(0, null);
  final bool equalsObject;
  late List<VoidCallback?> _listenerList = _emptyList;

  int _count = 0;
  int _removeCount = 0;
  int _notifyCount = 0;

  T _value;

  set value(T t) {
    if (equalsObject && t == _value) {
      return;
    }
    _value = t;
    notifyListeners();
  }

  @override
  T get value => _value;

  ChartNotifier(this._value, [this.equalsObject = false]);

  @override
  void addListener(VoidCallback listener) {
    if (_count == _listenerList.length) {
      if (_count == 0) {
        _listenerList = List.filled(4, null);
      } else {
        final List<VoidCallback?> newList = List.filled(_listenerList.length * 2, null);
        for (int i = 0; i < _count; i++) {
          newList[i] = _listenerList[i];
        }
        _listenerList = newList;
      }
    }
    _listenerList[_count] = listener;
    _count++;
  }

  @override
  void removeListener(VoidCallback listener) {
    for (int i = 0; i < _count; i++) {
      var v = _listenerList[i];
      if (v == listener) {
        _listenerList[i] = null;
        _removeCount++;
      }
    }
  }

  void clearListener() {
    _count = 0;
    _listenerList = _emptyList;
    _removeCount = 0;
  }

  void notifyListeners() {
    if (_count <= 0) {
      _count = 0;
      return;
    }
    _notifyCount++;
    eachNull(_listenerList, (p0, p1) {
      p0?.call();
    });
    _notifyCount--;
    if (_notifyCount <= 0 && _removeCount > 0) {
      final int newLength = _count - _removeCount;
      if (newLength * 2 <= _listenerList.length) {
        ///长度不满足则直接重新创建一个
        final List<VoidCallback?> newListeners = List<VoidCallback?>.filled(newLength, null);
        int newIndex = 0;
        for (int i = 0; i < _count; i++) {
          final VoidCallback? listener = _listenerList[i];
          if (listener != null) {
            newListeners[newIndex++] = listener;
          }
        }
        _listenerList = newListeners;
      } else {
        ///长度满足则直接进行移位操作(将右边的移动到左边)
        for (int i = 0; i < newLength; i++) {
          var c = _listenerList[i];
          if (c == null) {
            int swapIndex = i + 1;
            while (swapIndex < _listenerList.length && _listenerList[swapIndex] == null) {
              swapIndex += 1;
            }
            _listenerList[i] = _listenerList[swapIndex];
            _listenerList[swapIndex] = null;
          }
        }
      }
      _removeCount = 0;
      _count = newLength;
    }
  }

  bool get hasListeners => _count > 0;

  @mustCallSuper
  @override
  void dispose() {
    super.dispose();
    clearListener();
  }
}

class ChartNotifier2 extends ChartNotifier<Command> {
  ChartNotifier2() : super(Command.none);

  void notifyConfigChange() {
    value = Command.configChange;
  }
}
