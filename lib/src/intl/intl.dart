
import '../model/index.dart';

class Intl {
  final Map<String, DynamicText> _source = {};

  Intl([Map<String, DynamicText>? source]) {
    if (source != null) {
      _source.addAll(source);
    }
  }

  DynamicText get(String key) {
    return _source[key]!;
  }

  DynamicText? getOrNull(String key) {
    return _source[key];
  }

  void add(String key, DynamicText text) {
    _source[key] = text;
  }

  void remove(String key) {
    _source.remove(key);
  }
}
