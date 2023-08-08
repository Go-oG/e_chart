///模拟动态数组
class Array<T> {
  final Map<int, T> _map = {};

  Array();

  void operator []=(int index, T t) {
    _map[index] = t;
  }

  T operator [](int index) {
    return _map[index]!;
  }

  T? getNull(int index) {
    return _map[index]!;
  }

  List<T> toList() {
    List<T> tl = [];
    List<int> keys = List.from(_map.values);
    keys.sort();
    for (var key in keys) {
      var v = _map[key];
      if (v != null) {
        tl.add(v);
      }
    }

    return tl;
  }

}
