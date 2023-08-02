extension IntExt on int {
  String padLeft(int width, [String padding = '']) {
    return toString().padLeft(width, padding);
  }

  String padRight(int width, [String fill = '']) {
    return toString().padRight(width, fill);
  }
}
