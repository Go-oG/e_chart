import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///Diff 比较工具类
///用于在布局中实现动画
class DiffUtil {
  static DiffResult2<T, P, K> diff<T, K, P>(
    Iterable<T> oldList,
    Iterable<T> newList,
    Fun2<T, K> keyFun,
    P Function(T node, DiffType type) builder,
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
    Map<T, P> startMap = {};
    oldMap.forEach((key, value) {
      startMap[value] = builder.call(value, DiffType.update);
    });
    Map<T, P> endMap = {};
    newMap.forEach((key, value) {
      endMap[value] = builder.call(value, DiffType.update);
    });
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
        startMap[t] = builder.call(t, DiffType.add);
      } else {
        endMap[t] = builder.call(t, DiffType.remove);
      }
    }
    return DiffResult2(startMap, endMap, curList, finalList, removeSet, addSet, commonSet);
  }

  static List<AnimationNode> diffLayout<P, D, N extends DataNode<P, D>>(
    AnimatorOption? attrs,
    Iterable<N> oldList,
    Iterable<N> newList,
    P Function(D data, N node, bool add) builder,
    P Function(P s, P e, double t) lerpFun,
    void Function(List<N> resultList) updateCall, [
    VoidCallback? onStart,
    VoidCallback? onEnd,
  ]) {
    return diffLayout3(
      attrs,
      oldList,
      newList,
      (node, type) {
        Map<String, P> ms = {};
        if (type == DiffType.add) {
          ms["PPP"] = builder.call(node.data, node, true);
        } else {
          ms["PPP"] = node.attr;
        }
        return ms;
      },
      (node, type) {
        Map<String, P> ms = {};
        if (type == DiffType.add) {
          ms["PPP"] = node.attr;
        } else {
          ms["PPP"] = builder.call(node.data, node, false);
        }
        return ms;
      },
      (node, s, e, t, type) {
        var sp = s["PPP"]! as P;
        var ep = e["PPP"]! as P;
        node.attr = lerpFun.call(sp, ep, t);
      },
      updateCall,
      onStart,
      onEnd,
    );
  }

  static List<AnimationNode> diffLayout2<N extends DataNode>(
    AnimatorOption? attrs,
    Iterable<N> oldList,
    Iterable<N> newList,
    double Function(N node, bool add) startFun,
    double Function(N node, bool add) endFun,
    void Function(N node, double t) lerpFun,
    void Function(List<N> resultList) resultCall, [
    VoidCallback? onStart,
    VoidCallback? onEnd,
  ]) {
    return diffLayout3(
      attrs,
      oldList,
      newList,
      (node, type) {
        Map<String, double> ms = {};
        ms["ppp"] = startFun.call(node, type == DiffType.add);
        return ms;
      },
      (node, type) {
        Map<String, double> ms = {};
        ms["ppp"] = endFun.call(node, type == DiffType.add);
        return ms;
      },
      (node, s, e, t, type) {
        var sp = s['ppp'] as double;
        var ep = e['ppp'] as double;
        var tt = lerpDouble(sp, ep, t)!;
        lerpFun.call(node, tt);
      },
      resultCall,
      onStart,
      onEnd,
    );
  }

  ///该方法适用于具有多个单一属性的Diff
  static List<AnimationNode> diffLayout3<N extends DataNode>(
    AnimatorOption? attrs,
    Iterable<N> oldList,
    Iterable<N> newList,
    Map<String, dynamic> Function(N node, DiffType type) startFun,
    Map<String, dynamic> Function(N node, DiffType type) endFun,
    void Function(N node, Map<String, dynamic> s, Map<String, dynamic> e, double t, DiffType type) lerpFun,
    void Function(List<N> resultList) updateCall, [
    VoidCallback? onStart,
    VoidCallback? onEnd,
  ]) {
    if (oldList.isEmpty && newList.isEmpty) {
      onStart?.call();
      updateCall.call([]);
      onEnd?.call();
      return [];
    }
    if (attrs == null) {
      onStart?.call();
      updateCall.call(List.from(newList));
      onEnd?.call();
      return [];
    }

    Set<dynamic> oldSet = Set.from(oldList.map((e) => e.data));
    Set<dynamic> newSet = Set.from(newList.map((e) => e.data));

    Map<dynamic, N> removeSet = {};
    Map<dynamic, N> addSet = {};

    Map<dynamic, N> oldUpdateSet = {};
    Map<dynamic, N> newUpdateSet = {};

    for (var n in oldList) {
      dynamic key = n.data;
      if (newSet.contains(key)) {
        oldUpdateSet[key] = n;
      } else {
        removeSet[key] = n;
      }
    }

    for (var n in newList) {
      dynamic key = n.data;
      if (oldSet.contains(key)) {
        newUpdateSet[key] = n;
      } else {
        addSet[key] = n;
      }
    }
    if (oldUpdateSet.length != newUpdateSet.length) {
      throw ChartError('状态异常');
    }

    Map<dynamic, Map<String, dynamic>> startMap = {};
    Map<dynamic, Map<String, dynamic>> endMap = {};
    addSet.forEach((key, value) {
      startMap[key] = startFun.call(value, DiffType.add);
      endMap[key] = endFun.call(value, DiffType.add);
    });

    oldUpdateSet.forEach((key, value) {
      startMap[key] = startFun.call(value, DiffType.update);
    });

    newUpdateSet.forEach((key, value) {
      endMap[key] = endFun.call(value, DiffType.update);
    });

    removeSet.forEach((key, value) {
      startMap[key] = startFun.call(value, DiffType.remove);
      endMap[key] = endFun.call(value, DiffType.remove);
    });

    final List<N> resultList = [...removeSet.values, ...addSet.values, ...newUpdateSet.values];
    final List<N> endList = [...addSet.values, ...newUpdateSet.values];

    List<TweenWrap> tweenList = [];

    bool needCallAdd = false;
    bool needCallRemove = false;
    bool needCallUpdate = false;
    int endCount = 0;

    void innerRun() {
      if (needCallAdd) {
        addSet.forEach((key, value) {
          var s = startMap[key]!;
          var e = endMap[key]!;
          lerpFun.call(value, s, e, 1, DiffType.add);
        });
      }
      if (needCallRemove) {
        removeSet.forEach((key, value) {
          var s = startMap[key]!;
          var e = endMap[key]!;
          lerpFun.call(value, s, e, 1, DiffType.remove);
        });
      }
      if (needCallUpdate) {
        newUpdateSet.forEach((key, value) {
          var s = startMap[key]!;
          var e = endMap[key]!;
          lerpFun.call(value, s, e, 1, DiffType.update);
        });
      }
    }

    void handleEnd() {
      if (endCount >= tweenList.length && tweenList.isNotEmpty) {
        innerRun();
        updateCall.call(endList);
        onEnd?.call();
      }
    }

    if (addSet.isNotEmpty) {
      if (attrs.check(LayoutType.layout, startMap.length)) {
        var addTween = ChartDoubleTween(option: attrs);
        addTween.addListener(() {
          double t = addTween.value;
          addSet.forEach((key, value) {
            var s = startMap[key]!;
            var e = endMap[key]!;
            lerpFun.call(value, s, e, t, DiffType.add);
          });
          updateCall.call(resultList);
        });
        addTween.addEndListener(() {
          endCount += 1;
          handleEnd();
        });
        tweenList.add(TweenWrap(addTween, TweenWrap.addStatus));
      } else {
        needCallAdd = true;
      }
    }

    if (removeSet.isNotEmpty) {
      if (attrs.check(LayoutType.layout, startMap.length)) {
        var removeTween = ChartDoubleTween.fromValue(0, 1, option: attrs);
        removeTween.addListener(() {
          double t = removeTween.value;
          removeSet.forEach((key, value) {
            var s = startMap[key]!;
            var e = endMap[key]!;
            lerpFun.call(value, s, e, t, DiffType.remove);
          });
          updateCall.call(resultList);
        });
        removeTween.addEndListener(() {
          endCount += 1;
          handleEnd();
        });
        tweenList.add(TweenWrap(removeTween, TweenWrap.removeStatus));
      } else {
        needCallRemove = true;
      }
    }

    if (newUpdateSet.isNotEmpty) {
      if (attrs.check(LayoutType.update, startMap.length)) {
        var updateTween = ChartDoubleTween.fromValue(0, 1, option: attrs);
        updateTween.addListener(() {
          double t = updateTween.value;
          newUpdateSet.forEach((key, value) {
            var s = startMap[key]!;
            var e = endMap[key]!;
            lerpFun.call(value, s, e, t, DiffType.update);
          });
          updateCall.call(resultList);
        });
        updateTween.addEndListener(() {
          endCount += 1;
          handleEnd();
        });
        tweenList.add(TweenWrap(updateTween, TweenWrap.updateStatus));
      } else {
        needCallUpdate = true;
      }
    }

    if (tweenList.isEmpty) {
      onStart?.call();
      innerRun();
      updateCall.call(endList);
      onEnd?.call();
      return [];
    }

    tweenList.first.tween.addStartListener(() {
      onStart?.call();
      innerRun();
    });

    List<AnimationNode> nl = [];
    for (var wrap in tweenList) {
      var status = wrap.status;
      if (status == TweenWrap.updateStatus || status == TweenWrap.removeStatus) {
        nl.add(AnimationNode(wrap.tween, attrs, LayoutType.update));
      } else {
        nl.add(AnimationNode(wrap.tween, attrs, LayoutType.layout));
      }
    }

    return nl;
  }

  ///用于在点击或者hover触发时执行diff动画
  static List<AnimationNode> diffUpdate<P, D, N extends DataNode<P, D>>(
    AnimatorOption? attrs,
    Iterable<N> oldList,
    Iterable<N> newList,
    P Function(D data, N node, bool isOld) builder,
    P Function(P s, P e, double t) lerpFun,
    VoidCallback callback,
  ) {
    Map<D, P> startMap = {};
    Map<D, P> endMap = {};

    each(oldList, (p0, p1) {
      startMap[p0.data] = p0.attr;
      endMap[p0.data] = builder.call(p0.data, p0, true);
    });
    each(newList, (p0, p1) {
      startMap[p0.data] = p0.attr;
      endMap[p0.data] = builder.call(p0.data, p0, false);
    });
    final List<N> nodeList = [...oldList, ...newList];

    if (attrs == null || !attrs.check(LayoutType.update, oldList.length + newList.length)) {
      for (var n in nodeList) {
        P s = startMap[n.data] as P;
        P e = endMap[n.data] as P;
        n.attr = lerpFun.call(s, e, 1);
      }
      callback.call();
      return [];
    }

    var updateTween = ChartDoubleTween.fromValue(0, 1, option: attrs);
    updateTween.addEndListener(() {
      callback.call();
    });
    updateTween.addListener(() {
      double t = updateTween.value;
      for (var n in nodeList) {
        P s = startMap[n.data] as P;
        P e = endMap[n.data] as P;
        n.attr = lerpFun.call(s, e, t);
      }
      callback.call();
    });
    return [AnimationNode(updateTween, attrs, LayoutType.update)];
  }
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

class DiffResult2<N, P, D> {
  final Map<N, P> startMap;
  final Map<N, P> endMap;

  final List<N> startList;
  final List<N> endList;

  final Set<D> removeSet;
  final Set<D> addSet;
  final Set<D> updateSet;

  DiffResult2(
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

enum DiffType {
  add,
  remove,
  update,
}
