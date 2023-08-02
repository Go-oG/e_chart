import 'package:e_chart/e_chart.dart';

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

  static void diff2<P, D, N extends NodeAccessor<P, D>>(
    Context context,
    AnimatorAttrs attrs,
    Iterable<N> oldList,
    Iterable<N> newList,
    P Function(D data, N node, bool add) builder,
    P Function(P s, P e, double t) lerpFun,
    void Function(List<N> resultList) resultCall,
  ) {
    Map<D, N> oldMap = {};
    for (var n in oldList) {
      oldMap[n.d] = n;
    }
    Map<D, N> newMap = {};
    for (var n in newList) {
      newMap[n.d] = n;
    }

    Set<D> removeSet = {};
    Set<D> addSet = {};
    Set<D> updateSet = {};
    for (var n in oldList) {
      D key = n.d;
      if (newMap.containsKey(key)) {
        updateSet.add(key);
      } else {
        removeSet.add(key);
      }
    }
    for (var n in newList) {
      D key = n.d;
      if (oldMap.containsKey(key)) {
        updateSet.add(key);
      } else {
        addSet.add(key);
      }
    }

    Map<D, P> startMap = {};
    oldMap.forEach((key, value) {
      startMap[key] = value.getP();
    });
    Map<D, P> endMap = {};
    newMap.forEach((key, value) {
      endMap[key] = value.getP();
    });
    for (var d in removeSet) {
      endMap[d] = builder.call(d, oldMap[d] as N, false);
    }
    for (var d in addSet) {
      startMap[d] = builder.call(d, newMap[d] as N, true);
    }
    final List<N> nodeList = [];
    for (var d in [...removeSet, ...addSet, ...updateSet]) {
      N n = (oldMap[d] ?? newMap[d])!;
      nodeList.add(n);
    }

    List<TweenWrap> tweenList = [];
    if (addSet.isNotEmpty) {
      ChartDoubleTween addTween = ChartDoubleTween.fromValue(0, 1, props: attrs);
      addTween.addListener(() {
        double t = addTween.value;
        for (var d in addSet) {
          N node = (oldMap[d] ?? newMap[d])!;
          P s = startMap[d] as P;
          P e = endMap[d] as P;
          node.setP(lerpFun.call(s, e, t));
        }
        resultCall.call(nodeList);
      });
      addTween.endListener = () {
        resultCall.call(nodeList);
      };
      tweenList.add(TweenWrap(addTween, TweenWrap.addStatus));
    }
    if (removeSet.isNotEmpty) {
      ChartDoubleTween removeTween = ChartDoubleTween.fromValue(0, 1, props: attrs);
      removeTween.endListener = () {
        nodeList.removeWhere((e) {
          return removeSet.contains(e.d);
        });
        resultCall.call(nodeList);
      };
      removeTween.addListener(() {
        double t = removeTween.value;
        for (var d in removeSet) {
          N node = (oldMap[d] ?? newMap[d])!;
          P s = startMap[d] as P;
          P e = endMap[d] as P;
          node.setP(lerpFun.call(s, e, t));
        }
        resultCall.call(nodeList);
      });
      tweenList.add(TweenWrap(removeTween, TweenWrap.removeStatus));
    }
    if (updateSet.isNotEmpty) {
      ///优化不需要更新的节点
      final List<N> needUpdateList = [];
      for (var d in updateSet) {
        N node = (oldMap[d] ?? newMap[d])!;
        P s = startMap[d] as P;
        P e = endMap[d] as P;
        if (s != e) {
          needUpdateList.add(node);
        }
      }

      if (needUpdateList.isNotEmpty) {
        ChartDoubleTween updateTween = ChartDoubleTween.fromValue(0, 1, props: attrs);
        updateTween.endListener = () {
          resultCall.call(nodeList);
        };
        updateTween.addListener(() {
          double t = updateTween.value;
          for (var n in needUpdateList) {
            P s = startMap[n.d] as P;
            P e = endMap[n.d] as P;
            n.setP(lerpFun.call(s, e, t));
          }
          resultCall.call(nodeList);
        });
        tweenList.add(TweenWrap(updateTween, TweenWrap.updateStatus));
      }
    }

    for (var tween in tweenList) {
      tween.tween.start(context, tween.status == TweenWrap.updateStatus);
    }
  }
}

///属性访问器
///用于访问节点的布局位置和数据
abstract class NodeAccessor<P, D> {
  P getP();

  void setP(P po);

  D get d;
}

class DiffResult<N, D> {
  final Map<D, N> startMap;
  final Map<D, N> endMap;

  final List<N> startList;
  final List<N> endList;

  final Set<D> removeSet;
  final Set<D> addSet;
  final Set<D> updateSet;

  DiffResult(
    this.startMap,
    this.endMap,
    this.startList,
    this.endList,
    this.removeSet,
    this.addSet,
    this.updateSet,
  );
}

class TweenWrap {
  static const addStatus = 1;
  static const removeStatus = 2;
  static const updateStatus = 3;
  final ChartTween tween;
  final int status;

  TweenWrap(this.tween, this.status);
}
