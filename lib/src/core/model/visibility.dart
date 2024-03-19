enum Visibility {
  visible,
  invisible,
  gone;

  bool get isGone {
    return this == Visibility.gone;
  }

  bool get isVisible {
    return this == Visibility.visible;
  }

  bool get isInVisible {
    return this == Visibility.invisible;
  }

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
