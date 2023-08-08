import 'package:e_chart/e_chart.dart';

import 'intl.dart';
import 'intl_type.dart';

///国际化资源管理
class IntlAsset {
  final Map<IntlType, Intl> _intlMap = {};

  IntlAsset([Map<IntlType, Intl>? source]) {
    if (source != null) {
      _intlMap.addAll(source);
    }
  }

  void add(IntlType type, Intl intl) {
    _intlMap[type] = intl;
  }

  void remove(IntlType type) {
    _intlMap.remove(type);
  }

  DynamicText get(IntlType type, String key) {
    return _intlMap[type]!.get(key);
  }

  DynamicText? getOrNull(IntlType type, String key) {
    return _intlMap[type]?.get(key);
  }
}
