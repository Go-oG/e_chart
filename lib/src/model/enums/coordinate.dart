///坐标系类别
enum CoordType {
  grid,
  polar,
  parallel,
  radar,
  calendar,
  single;

  bool isGrid() {
    return this == grid;
  }

  bool isPolar() {
    return this == CoordType.polar;
  }

  bool isParallel() {
    return this == CoordType.parallel;
  }

  bool isRadar() {
    return this == CoordType.radar;
  }

  bool isCalendar() {
    return this == CoordType.calendar;
  }

  bool isSingle() {
    return this == CoordType.single;
  }
}
