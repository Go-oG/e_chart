mixin ExtProps {
  ///拓展字段属性
  final Map<String, dynamic> _extendProps = {};

  void extSet(String key, dynamic data) {
    _extendProps[key] = data;
  }

  T extGet<T>(String key) {
    return _extendProps[key];
  }
}
