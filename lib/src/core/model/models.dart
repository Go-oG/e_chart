class MeasureSpec {
  final SpecMode mode;
  final double size;

  const MeasureSpec._(this.mode, this.size);

  const MeasureSpec.atMost(double size) : this._(SpecMode.atMost, size);

  const MeasureSpec.unLimit(double size) : this._(SpecMode.unLimit, size);

  const MeasureSpec.exactly(double size) : this._(SpecMode.exactly, size);
}

enum SpecMode {
  atMost,
  unLimit,
  exactly;

  bool get isExactly {
    return this == SpecMode.exactly;
  }

  bool get isAtMost {
    return this == SpecMode.atMost;
  }

  bool get isUnLimit {
    return this == SpecMode.unLimit;
  }
}
