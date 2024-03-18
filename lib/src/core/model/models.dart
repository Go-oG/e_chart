class MeasureSpec {
  final MeasureSpecMode mode;
  final double size;
  MeasureSpec(this.mode, this.size);
}

enum MeasureSpecMode {
  atMost,
  unLimit,
  exactly;
}

enum Visibility {
  visible,
  invisible,
  gone;

  bool get isShow {
    return this == Visibility.visible;
  }

  bool get isHide {
    return !isShow;
  }

  bool get needSize {
    return this == Visibility.invisible;
  }
}
