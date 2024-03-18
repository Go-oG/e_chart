import 'package:e_chart/src/core/model/models.dart';

import '../../model/string_number.dart';

class SizeParams {
  static const wrapType = -2;
  static const matchType = -1;
  static const _normal = 0;
  final SNumber size;
  final int _type;

  static SizeParams from(SNumber sn) {
    if (sn.number == wrapType) {
      return const SizeParams.wrap();
    }
    if (sn.number == SizeParams.matchType || sn.number <= 0) {
      return const SizeParams.match();
    }
    return SizeParams(sn);
  }

  const SizeParams(this.size) : _type = _normal;

  const SizeParams.wrap()
      : _type = wrapType,
        size = SNumber.zero;

  const SizeParams.match()
      : _type = matchType,
        size = SNumber.zero;

  bool get isWrap {
    return _type == wrapType;
  }

  bool get isMatch {
    return _type == matchType;
  }

  bool get isNormal {
    return _type == _normal;
  }

  double convert(num n) {
    if (isNormal) {
      return size.convert(n);
    }
    if (isWrap) {
      return 0;
    }
    return n.toDouble();
  }

  MeasureSpecMode toSpecMode() {
    if (_type == wrapType) {
      return MeasureSpecMode.atMost;
    }
    return MeasureSpecMode.exactly;
  }
}
