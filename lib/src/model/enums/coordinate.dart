///坐标系系统
class CoordSystem {
  static const CoordSystem grid = CoordSystem('grid');
  static const CoordSystem polar = CoordSystem('polar');
  static const CoordSystem parallel = CoordSystem('parallel');
  static const CoordSystem radar = CoordSystem('radar');
  static const CoordSystem calendar = CoordSystem('calendar');
  static const CoordSystem single = CoordSystem('single');

  final String _key;

  const CoordSystem(this._key);

  @override
  bool operator ==(Object other) {
    return other is CoordSystem && other._key == _key;
  }

  @override
  int get hashCode {
    return _key.hashCode;
  }

  @override
  String toString() {
    return _key;
  }
}
