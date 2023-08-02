class SeriesType {
  final String type;

 const SeriesType(this.type);

  @override
  int get hashCode {
    return type.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is SeriesType && other.type == type;
  }
}
