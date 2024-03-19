import 'package:e_chart/e_chart.dart';

import '../../coord/index.dart';

class CoordFactory {
  static final CoordFactory _instance = CoordFactory._();

  static CoordFactory get instance => _instance;

  CoordFactory._();

  factory CoordFactory() => _instance;

  late final List<CoordConvert> _convertList = [];

  void addConvert(CoordConvert convert) {
    _convertList.insert(0, convert);
  }

  void removeConvert(CoordConvert convert) {
    _convertList.remove(convert);
  }

  void clearConvert() {
    _convertList.clear();
  }

  CoordLayout? convert(Context context, Coord c) {
    for (var sc in _convertList) {
      CoordLayout? v = sc.convert(context, c);
      if (v != null) {
        return v;
      }
    }
    return null;
  }
}

abstract class CoordConvert {
  CoordLayout? convert(Context context, Coord config);
}
