List<List<T>> splitList<T>(List<T> list, int count) {
  List<List<T>> rl = [];
  if (count <= 0) {
    count = 1;
  }
  List<T> tmpList = [];
  for (int i = 0; i < list.length; i++) {
    tmpList.add(list[i]);
    if (tmpList.length >= count) {
      rl.add(tmpList);
      tmpList = [];
    }
  }
  if (tmpList.isNotEmpty) {
    rl.add(tmpList);
  }
  return rl;
}

List<List<T?>> splitListOrNull<T>(List<T?> list, int count) {
  List<List<T?>> rl = [];
  if (count <= 0) {
    count = 1;
  }
  List<T?> tmpList = [];
  for (int i = 0; i < list.length; i++) {
    tmpList.add(list[i]);
    if (tmpList.length >= count) {
      rl.add(tmpList);
      tmpList = [];
    }
  }
  if (tmpList.isNotEmpty) {
    rl.add(tmpList);
  }
  return rl;
}
