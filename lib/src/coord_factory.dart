import 'coord/index.dart';
import 'model/enums/coordinate.dart';

class CoordFactory {
  static final CoordFactory _instance = CoordFactory._();

  static CoordFactory get instance => _instance;

  CoordFactory._() {
    _convertList.add(_defaultConvert);
  }

  factory CoordFactory() => _instance;

  final DefaultCoordConvert _defaultConvert = DefaultCoordConvert();
  final List<CoordConvert> _convertList = [];

  void addConvert(CoordConvert convert) {
    _convertList.insert(0, convert);
  }

  void removeConvert(CoordConvert convert) {
    if (convert == _defaultConvert) {
      return;
    }
    _convertList.remove(convert);
  }

  void clearConvert(CoordConvert convert) {
    _convertList.clear();
    _convertList.add(_defaultConvert);
  }

  Coord? convert(CoordConfig c) {
    for (var sc in _convertList) {
      Coord? v = sc.convert(c);
      if (v != null) {
        return v;
      }
    }
    return null;
  }
}

class DefaultCoordConvert extends CoordConvert {
  @override
  Coord? convert(CoordConfig config) {
    CoordSystem coord = config.coordSystem;
    if (coord == CoordSystem.grid) {
      return GridCoordImpl(config as GridConfig);
    }
    if (coord == CoordSystem.calendar) {
      return CalendarCoordImpl(config as CalendarConfig);
    }
    if (coord == CoordSystem.parallel) {
      return ParallelCoordImpl(config as ParallelConfig);
    }
    if (coord == CoordSystem.polar) {
      return PolarCoordImpl(config as PolarConfig);
    }
    if (coord == CoordSystem.radar) {
      return RadarCoordImpl(config as RadarConfig);
    }
    return null;
  }
}

abstract class CoordConvert {
  Coord? convert(CoordConfig config);
}
