
extension IntExt on int {
  IntWrap wrap() {
    return IntWrap(this);
  }
}

class IntWrap {
  final int value;

  const IntWrap(this.value);
}