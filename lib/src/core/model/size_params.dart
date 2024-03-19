import 'package:e_chart/src/core/model/models.dart';

import '../../model/string_number.dart';

class SizeParams {
  static const wrapType = -2;
  static const matchType = -1;
  static const _exactly = 0;
  final SNumber size;
  final int _type;

  const SizeParams.wrap()
      : _type = wrapType,
        size = SNumber.zero;

  const SizeParams.match()
      : _type = matchType,
        size = SNumber.zero;

  SizeParams.exactly(double size)
      : _type = _exactly,
        size = SNumber.number(size);

  bool get isWrap {
    return _type == wrapType;
  }

  bool get isMatch {
    return _type == matchType;
  }

  bool get isExactly {
    return _type == _exactly;
  }

  double convert(num n) {
    if (isExactly) {
      return size.convert(n);
    }
    if (isWrap) {
      return 0;
    }
    return n.toDouble();
  }

  SpecMode toSpecMode() {
    if (_type == wrapType) {
      return SpecMode.atMost;
    }
    return SpecMode.exactly;
  }
}
