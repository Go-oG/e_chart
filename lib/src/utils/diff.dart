import '../functions.dart';
import '../model/chart_error.dart';

class DiffUtil {
  ///给定变化前的数据集和变化后的数据集
  ///补全数据集合并
  static DiffResult<T, K> diff<T, K>(
    Iterable<T> oldList,
    Iterable<T> newList,
    Fun2<T, K> keyFun,
    T Function(K, T, bool newData) builder,
  ) {
    Map<K, T> oldMap = {};
    for (var n in oldList) {
      oldMap[keyFun.call(n)] = n;
    }

    Map<K, T> newMap = {};
    for (var n in newList) {
      newMap[keyFun.call(n)] = n;
    }

    Set<K> removeSet = {};
    Set<K> addSet = {};
    Set<K> commonSet = {};
    List<T> finalList = [];

    for (var n in oldList) {
      K key = keyFun.call(n);
      if (newMap.containsKey(key)) {
        commonSet.add(key);
      } else {
        removeSet.add(key);
      }
    }

    for (var n in newList) {
      finalList.add(n);
      K key = keyFun.call(n);
      if (oldMap.containsKey(key)) {
        commonSet.add(key);
      } else {
        addSet.add(key);
      }
    }

    Set<K> tmpList = {...removeSet, ...addSet, ...commonSet};

    Map<K, T> startMap = {};
    startMap.addAll(oldMap);

    Map<K, T> endMap = {};
    endMap.addAll(newMap);

    List<T> curList = [];
    for (var k in tmpList) {
      T? t = oldMap[k] ?? newMap[k];
      if (t == null) {
        throw ChartError('无法找到对应的映射数据');
      }
      curList.add(t);
      if (commonSet.contains(k)) {
        continue;
      }
      if (addSet.contains(k)) {
        //新增数据
        startMap[k] = builder.call(k, newMap[k] as T, true);
      } else {
        //被移除数据
        endMap[k] = builder.call(k, oldMap[k] as T, false);
      }
    }
    return DiffResult(startMap, endMap, curList, finalList, removeSet, addSet, commonSet);
  }

}

class DiffResult<T, K> {
  final Map<K, T> startMap;
  final Map<K, T> endMap;
  final List<T> curList;
  final List<T> finalList;
  final Set<K> removeSet;
  final Set<K> addSet;
  final Set<K> commonSet;

  DiffResult(
    this.startMap,
    this.endMap,
    this.curList,
    this.finalList,
    this.removeSet,
    this.addSet,
    this.commonSet,
  );
}
