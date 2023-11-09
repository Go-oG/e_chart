import 'package:e_chart/e_chart.dart';

class SafeList<T> extends Disposable {
  late List<T?> _list = List.filled(0, null);
  int _count = 0;
  int _removeCount = 0;
  int _notifyCount = 0;

  void add(T value) {
    if (_count == _list.length) {
      if (_count == 0) {
        _list = List.filled(4, null);
      } else {
        final List<T?> newList = List.filled(_list.length * 2, null);
        for (int i = 0; i < _count; i++) {
          newList[i] = _list[i];
        }
        _list = newList;
      }
    }
    _list[_count] = value;
    _count++;
  }

  void addAll(Iterable<T> values) {
    if (_count == _list.length) {
      if (_count == 0) {
        _list = List.from(values, growable: false);
        _count = _list.length;
      } else {
        int length = _list.length * 2;
        int all = values.length + _count;
        if (length < all) {
          length = all;
        }
        final List<T?> newList = List.filled(length, null);
        for (int i = 0; i < _count; i++) {
          newList[i] = _list[i];
        }
        for (var v in values) {
          newList[_count] = v;
          _count++;
        }
        _list = newList;
      }
    }
  }

  void remove(T value) {
    for (int i = 0; i < _count; i++) {
      var v = _list[i];
      if (v == value) {
        _list[i] = null;
        _removeCount++;
      }
    }
  }

  void clear() {
    _count = 0;
    _list = List.filled(0, null);
    _removeCount = 0;
  }

  void each(void Function(T value) call) {
    if (_count <= 0) {
      _count = 0;
      return;
    }
    _notifyCount++;
    final int c = _count;
    final list = _list;
    for (int i = 0; i < c; i++) {
      var p = list[i];
      if (p != null) {
        call.call(p);
      }
    }
    _notifyCount--;
    if (_notifyCount <= 0 && _removeCount > 0) {
      final int newLength = _count - _removeCount;
      if (newLength * 2 <= _list.length) {
        ///长度不满足则直接重新创建一个
        final List<T?> newListeners = List<T?>.filled(newLength, null);
        int newIndex = 0;
        for (int i = 0; i < _count; i++) {
          final T? v = _list[i];
          if (v != null) {
            newListeners[newIndex++] = v;
          }
        }
        _list = newListeners;
      } else {
        ///长度满足则直接进行移位操作(将右边的移动到左边)
        for (int i = 0; i < newLength; i++) {
          var c = _list[i];
          if (c == null) {
            int swapIndex = i + 1;
            while (swapIndex < _list.length && _list[swapIndex] == null) {
              swapIndex += 1;
            }
            _list[i] = _list[swapIndex];
            _list[swapIndex] = null;
          }
        }
      }
      _removeCount = 0;
      _count = newLength;
    }
  }

  bool get isEmpty => _count <= 0;

  bool get isNotEmpty => _count > 0;

  @override
  void dispose() {
    super.dispose();
    clear();
  }
}
