mixin ExtProps {
  ///拓展字段属性
  final Map<String, dynamic> _extendProps = {};

  void extSet(String key, dynamic data) {
    _extendProps[key] = data;
  }

  void extSetAll(Map<String, dynamic> map) {
    map.forEach((key, value) {
      _extendProps[key] = value;
    });
  }

  void extRemove(String key) {
    _extendProps.remove(key);
  }

  void extClear() {
    _extendProps.clear();
  }

  T extGet<T>(String key) {
    return _extendProps[key];
  }

  Map<String, dynamic> extGetAll() {
    return Map.from(_extendProps);
  }
}
