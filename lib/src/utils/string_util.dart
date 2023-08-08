String formatNumber(num number, [int fractionDigits = 2]) {
  String s = number.toStringAsFixed(fractionDigits);
  int index = s.indexOf('.');
  if (index == -1) {
    return s;
  }

  while (s.isNotEmpty) {
    if (s.endsWith('0')) {
      s = s.substring(0, s.length - 1);
    } else if (s.endsWith('.')) {
      s = s.substring(0, s.length - 1);
      break;
    } else {
      break;
    }
  }
  if (s.isEmpty) {
    return '0';
  }
  return s;
}
