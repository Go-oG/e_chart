import 'package:flutter/widgets.dart';

List<T> copyList<T>(Iterable<T> list) {
  return List.from(list);
}

T? removeLastOrNull<T>(List<T>? list) {
  if (list == null || list.isEmpty) {
    return null;
  }
  return list.removeLast();
}

List<List<T>> splitList<T>(Iterable<T> list, int count) {
  List<List<T>> rl = [];
  if (count <= 0) {
    count = 1;
  }
  List<T> tmpList = [];
  for (var data in list) {
    tmpList.add(data);
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

List<List<T?>> splitList2<T>(Iterable<T?> list, int count) {
  List<List<T?>> rl = [];
  if (count <= 0) {
    count = 1;
  }
  List<T?> tmpList = [];
  for (var data in list) {
    tmpList.add(data);
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

List<List<T>> splitListForNull<T>(Iterable<T?> list) {
  List<List<T>> rl = [];
  List<T> tmpList = [];
  for (var t in list) {
    if (t != null) {
      tmpList.add(t);
    } else {
      rl.add(tmpList);
      tmpList = [];
    }
  }
  if (tmpList.isNotEmpty) {
    rl.add(tmpList);
  }
  return rl;
}

List<T> concat<T>(Iterable<Iterable<T>> iterable) {
  List<T> rl = [];
  for (var v in iterable) {
    rl.addAll(v);
  }
  return rl;
}

List<T> difference<T>(Iterable<T>? list, [Iterable<T>? values]) {
  if (list == null || list.isEmpty) {
    return [];
  }
  Set<T> set = {};
  if (values != null) {
    set.addAll(values);
  }
  List<T> rl = [...list];
  rl.removeWhere((element) => set.contains(element));
  return rl;
}

List<T> differenceBy<T, K>(Iterable<T>? list, [Iterable<T>? values, K Function(T)? call]) {
  if (list == null) {
    return [];
  }
  if (values == null || call == null) {
    return [...list];
  }
  Set<K> set = {};
  for (var v in values) {
    set.add(call.call(v));
  }
  List<T> rl = [];
  for (var v in list) {
    if (!set.contains(call.call(v))) {
      rl.add(v);
    }
  }
  return rl;
}

List<T> differenceWith<T>(Iterable<T>? list, [Iterable<T>? values, bool Function(T, T)? comparator]) {
  if (list == null) {
    return [];
  }
  if (values == null || comparator == null) {
    return [...list];
  }
  Set<T> set = {};
  set.addAll(values);
  List<T> rl = [];
  for (var v in list) {
    bool diff = true;
    for (var t in set) {
      if (comparator.call(v, t)) {
        diff = false;
        break;
      }
    }
    if (diff) {
      rl.add(v);
    }
  }
  return rl;
}

///去除该List前n个元素
void drop<T>(List<T>? list, [int n = 1]) {
  if (n <= 0 || list == null) {
    return;
  }
  if (n > list.length) {
    list.clear();
    return;
  }
  list.removeRange(0, n);
}

void dropWhen<T>(List<T>? list, bool Function(T, int, List<T>) call) {
  if (list == null) {
    return;
  }
  int i = 0;
  for (; i < list.length; i++) {
    var v = list[i];
    if (call.call(v, i, list)) {
      break;
    }
  }
  list.removeRange(0, i - 1);
}

void dropRight<T>(List<T>? list, [int n = 1]) {
  if (n <= 0 || list == null) {
    return;
  }
  if (n > list.length) {
    list.clear();
    return;
  }
  list.removeRange(list.length - n, list.length);
}

void dropRightWhen<T>(List<T>? list, bool Function(T, int, List<T>) call) {
  if (list == null) {
    return;
  }
  int i = 0;
  for (; i < list.length; i++) {
    var v = list[i];
    if (call.call(v, i, list)) {
      break;
    }
  }
  list.removeRange(i + 1, list.length);
}

void fill<T>(List<T> list, Iterable<T> values, [int start = 0, int? end]) {
  if (start >= list.length) {
    list.addAll(values);
    return;
  }
  if (end == null || end > list.length) {
    end = list.length;
  }
  list.replaceRange(start, end, values);
}

///删除List中在 values中出现的值
void deleteList<T>(Iterable<T> list, Iterable<T> values) {
  Set<T> tset = Set.from(values);
  if (list is List) {
    (list as List).removeWhere((e) => tset.contains(e));
    return;
  }
  if (list is Set) {
    (list as Set).removeWhere((e) => tset.contains(e));
    return;
  }
  throw FlutterError('只支持传入Set Or List');
}

void reverseSelf<T>(List<T> list) {
  List<T> rl = List.from(list.reversed);
  list.clear();
  list.addAll(rl);
}

T? find<T>(Iterable<T> list, bool Function(T) call) {
  for (var v in list) {
    if (call.call(v)) {
      return v;
    }
  }
  return null;
}

T? findLast<T>(Iterable<T> list, bool Function(T) call) {
  List<T> tl = [];
  if (list is List<T>) {
    tl = list;
  } else {
    tl.addAll(list);
  }
  for (int i = tl.length - 1; i >= 0; i--) {
    if (call.call(tl[i])) {
      return tl[i];
    }
  }
  return null;
}

///将给定的嵌套数组全部合并成一层数组
List<T> flatten<T>(Iterable<dynamic> list) {
  List<T> rl = [];
  for (var v in list) {
    if (v is T) {
      rl.add(v);
    } else if (v is Iterable<T>) {
      rl.addAll(flatten(v));
    } else {
      throw FlutterError('List 中只能存放一种数据');
    }
  }
  return rl;
}

///返回所有数据中都有的数据(交集)
List<T> intersection<T>(Iterable<Iterable<T>> list) {
  List<T> rl = [];
  Set<T> tmpSet = {};
  List<Set<T>> tmpList = [];
  for (var e in list) {
    tmpList.add(Set.from(e));
  }
  for (var l in list) {
    for (var lv in l) {
      if (tmpSet.contains(lv)) {
        continue;
      }
      bool has = true;
      for (var ls in tmpList) {
        if (!ls.contains(lv)) {
          has = false;
          break;
        }
      }
      if (has) {
        rl.add(lv);
        tmpSet.add(lv);
      }
    }
  }
  return rl;
}

///同上(后续优化)
List<T> intersectionWhen<T>(Iterable<Iterable<T>> list, bool Function(T, T) compare) {
  bool setHasFun(Iterable<T> ts, T va) {
    for (var v2 in ts) {
      if (compare.call(va, v2)) {
        return true;
      }
    }
    return false;
  }

  List<T> rl = [];
  for (var l in list) {
    for (var lv in l) {
      bool has = true;
      for (var ls in list) {
        if (!setHasFun(ls, lv)) {
          has = false;
          break;
        }
      }
      if (has) {
        rl.add(lv);
      }
    }
  }
  return rl;
}

List<T> reverse2<T>(List<T> list) {
  return List.from(list.reversed);
}

///返回一个按顺序排列的唯一值的List
List<T> union<T>(Iterable<Iterable<T>> list) {
  return unionBy<T, T>(list, (p0) => p0);
}

List<T> unionBy<T, K>(Iterable<Iterable<T>> list, K? Function(T) convert) {
  List<T> rl = [];
  Set<K?> set = {};
  for (var vl in list) {
    for (var v in vl) {
      var k = convert(v);
      if (set.contains(k)) {
        continue;
      }
      rl.add(v);
      set.add(k);
    }
  }
  return rl;
}

///创建一个去重后的数组
List<T> uniq<T>(Iterable<T> list) {
  return union<T>([list]);
}

List<T> uniqBy<T, K>(Iterable<T> list, K? Function(T) convert) {
  return unionBy<T, K>([list], convert);
}

///创建一个剔除所有给定值的新数组
List<T> withOut<T>(Iterable<T> list, Iterable<T> values) {
  Set<T> tset = Set.from(values);
  List<T> rl = [];
  for (var e in list) {
    if (!tset.contains(e)) {
      rl.add(e);
    }
  }
  return rl;
}

void each<T>(Iterable<T> list, void Function(T, int) call) {
  eachNull(list, (p0, p1) {
    call.call(p0 as T, p1);
  });
}

void eachNull<T>(Iterable<T?> list, void Function(T?, int) call) {
  int i = 0;
  for (var ele in list) {
    call.call(ele, i);
    i++;
  }
}

void eachRight<T>(Iterable<T> list, void Function(T, int) call) {
  List<T> tl;
  if (list is List<T>) {
    tl = list;
  } else {
    tl = List.from(list);
  }
  for (int i = tl.length - 1; i >= 0; i--) {
    call.call(tl[i], i);
  }
}

void each2<T>(Iterable<Iterable<T>> list, void Function(T, int, int) call) {
  int p = 0;
  for (var pList in list) {
    eachNull(pList, (p0, p1) {
      call.call(p0 as T, p1, p);
    });
    p++;
  }
}

///返回一个由给定数据生成的唯一值的数组
List<T> xor<T>(Iterable<Iterable<T>> list) {
  return xorBy<T, T>(list, (p0) => p0);
}

List<T> xorBy<T, K>(Iterable<Iterable<T>> list, K Function(T) convert) {
  List<T> rl = [];
  List<T> cl = concat<T>(list);
  Map<K?, int> map = {};
  for (var e in cl) {
    var k = convert.call(e);
    if (map.containsKey(k)) {
      map[k] = map[e]! + 1;
    } else {
      map[k] = 1;
    }
  }

  for (var e in cl) {
    var k = convert.call(e);
    var c = map[k] ?? 0;
    if (c <= 0) {
      rl.add(e);
    }
  }
  return rl;
}

///判断列表里面的元素是否都满足条件
bool every<T>(Iterable<T> list, bool Function(T) call) {
  for (var e in list) {
    if (!call.call(e)) {
      return false;
    }
  }
  return true;
}

/// 判断集合中的元素是否存在
bool some<T>(Iterable<T> list, bool Function(T) call) {
  return find<T>(list, call) != null;
}

List<K> map2<T, K>(Iterable<T> list, K Function(T) convert) {
  List<K> rl = [];
  for (var v in list) {
    rl.add(convert.call(v));
  }
  return rl;
}

///分组
Map<K, List<T>> groupBy<T, K>(Iterable<T> list, K Function(T) convert) {
  Map<K, List<T>> map = {};
  for (var v in list) {
    K k = convert.call(v);
    if (map.containsKey(k)) {
      map[k]!.add(v);
    } else {
      List<T> rl = [];
      rl.add(v);
      map[k] = rl;
    }
  }
  return map;
}

K reduce2<T, K>(Iterable<T> list, K Function(K, T) call, K initValue) {
  if (list.isEmpty) {
    return initValue;
  }
  var k = initValue;
  for (var n in list) {
    k = call.call(k, n);
  }
  return k;
}

bool equalList<T>(List<T?> s, List<T?> e) {
  if (s.length != e.length) {
    return false;
  }
  if (s.isEmpty) {
    return true;
  }
  for (int i = 0; i < s.length; i++) {
    var sv = s[i];
    var ev = e[i];
    if (sv != ev) {
      return false;
    }
  }
  return true;
}
