extension IntExt on int {
  String padLeft(int width, [String padding = '']) {
    return toString().padLeft(width, padding);
  }
}
