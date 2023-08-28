import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///Diff 比较工具类
///用于在布局中实现动画
class DiffUtil {
  static DiffResult2<T, P, K> diff<T, K, P>(
      Iterable<T> oldList, Iterable<T> newList, Fun2<T, K> keyFun, P Function(T node, DiffType type) builder) {
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
      startMap[value] = builder.call(value, DiffType.accessor);
    });
    Map<T, P> endMap = {};
    newMap.forEach((key, value) {
      endMap[value] = builder.call(value, DiffType.accessor);
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

  static List<AnimationNode> diffLayout<P, D, N extends NodeAccessor<P, D>>(
    AnimationAttrs attrs,
    Iterable<N> oldList,
    Iterable<N> newList,
    P Function(D data, N node, bool add) builder,
    P Function(P s, P e, double t) lerpFun,
    void Function(List<N> resultList) resultCall, [
    VoidCallback? onStart,
    VoidCallback? onEnd,
  ]) {
    Map<D, N> oldMap = {};
    for (var n in oldList) {
      oldMap[n.getData()] = n;
    }
    Map<D, N> newMap = {};
    for (var n in newList) {
      newMap[n.getData()] = n;
    }

    Set<D> removeSet = {};
    Set<D> addSet = {};
    Set<D> updateSet = {};
    for (var n in oldList) {
      D key = n.getData();
      if (newMap.containsKey(key)) {
        updateSet.add(key);
      } else {
        removeSet.add(key);
      }
    }
    for (var n in newList) {
      D key = n.getData();
      if (oldMap.containsKey(key)) {
        updateSet.add(key);
      } else {
        addSet.add(key);
      }
    }

    Map<D, P> startMap = {};
    oldMap.forEach((key, value) {
      startMap[key] = value.getAttr();
    });
    Map<D, P> endMap = {};
    newMap.forEach((key, value) {
      endMap[key] = value.getAttr();
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

    bool hasCallStart = false;
    bool hasCallEnd = false;

    if (addSet.isNotEmpty) {
      ChartDoubleTween addTween = ChartDoubleTween.fromValue(0, 1, props: attrs);
      addTween.startListener = () {
        if (!hasCallStart) {
          hasCallStart = true;
          onStart?.call();
        }
      };
      addTween.addListener(() {
        double t = addTween.value;
        for (var d in addSet) {
          N node = (oldMap[d] ?? newMap[d])!;
          P s = startMap[d] as P;
          P e = endMap[d] as P;
          node.setAttr(lerpFun.call(s, e, t));
        }
        resultCall.call(nodeList);
      });
      addTween.endListener = () {
        if (!hasCallEnd) {
          hasCallEnd = true;
          onEnd?.call();
        }
        resultCall.call(nodeList);
      };
      tweenList.add(TweenWrap(addTween, TweenWrap.addStatus));
    }
    if (removeSet.isNotEmpty) {
      ChartDoubleTween removeTween = ChartDoubleTween.fromValue(0, 1, props: attrs);
      removeTween.startListener = () {
        if (!hasCallStart) {
          hasCallStart = true;
          onStart?.call();
        }
      };
      removeTween.endListener = () {
        nodeList.removeWhere((e) {
          return removeSet.contains(e.getData());
        });
        resultCall.call(nodeList);
        if (!hasCallEnd) {
          hasCallEnd = true;
          onEnd?.call();
        }
      };
      removeTween.addListener(() {
        double t = removeTween.value;
        for (var d in removeSet) {
          N node = (oldMap[d] ?? newMap[d])!;
          P s = startMap[d] as P;
          P e = endMap[d] as P;
          node.setAttr(lerpFun.call(s, e, t));
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
        updateTween.startListener = () {
          if (!hasCallStart) {
            hasCallStart = true;
            onStart?.call();
          }
        };
        updateTween.endListener = () {
          resultCall.call(nodeList);
          if (!hasCallEnd) {
            hasCallEnd = true;
            onEnd?.call();
          }
        };
        updateTween.addListener(() {
          double t = updateTween.value;
          for (var n in needUpdateList) {
            P s = startMap[n.getData()] as P;
            P e = endMap[n.getData()] as P;
            n.setAttr(lerpFun.call(s, e, t));
          }
          resultCall.call(nodeList);
        });
        tweenList.add(TweenWrap(updateTween, TweenWrap.updateStatus));
      }
    }

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

  static List<AnimationNode> diffLayout2<P, D, N extends NodeAccessor<P, D>>(
    AnimationAttrs attrs,
    Iterable<N> oldList,
    Iterable<N> newList,
    P Function(D data, N node, bool add) builder,
    P Function(P s, P e, double t, UpdateType type) lerpFun,
    void Function(List<N> resultList) resultCall, [
    VoidCallback? onStart,
    VoidCallback? onEnd,
  ]) {
    Map<D, N> oldMap = {};
    for (var n in oldList) {
      oldMap[n.getData()] = n;
    }
    Map<D, N> newMap = {};
    for (var n in newList) {
      newMap[n.getData()] = n;
    }

    Set<D> removeSet = {};
    Set<D> addSet = {};
    Set<D> updateSet = {};
    for (var n in oldList) {
      D key = n.getData();
      if (newMap.containsKey(key)) {
        updateSet.add(key);
      } else {
        removeSet.add(key);
      }
    }
    for (var n in newList) {
      D key = n.getData();
      if (oldMap.containsKey(key)) {
        updateSet.add(key);
      } else {
        addSet.add(key);
      }
    }

    Map<D, P> startMap = {};
    oldMap.forEach((key, value) {
      startMap[key] = value.getAttr();
    });
    Map<D, P> endMap = {};
    newMap.forEach((key, value) {
      endMap[key] = value.getAttr();
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

    bool hasCallStart = false;
    bool hasCallEnd = false;

    if (addSet.isNotEmpty) {
      ChartDoubleTween addTween = ChartDoubleTween.fromValue(0, 1, props: attrs);
      addTween.startListener = () {
        if (!hasCallStart) {
          hasCallStart = true;
          onStart?.call();
        }
      };
      addTween.addListener(() {
        double t = addTween.value;
        for (var d in addSet) {
          N node = (oldMap[d] ?? newMap[d])!;
          P s = startMap[d] as P;
          P e = endMap[d] as P;
          node.setAttr(lerpFun.call(s, e, t, UpdateType.add));
        }
        resultCall.call(nodeList);
      });
      addTween.endListener = () {
        if (!hasCallEnd) {
          hasCallEnd = true;
          onEnd?.call();
        }
        resultCall.call(nodeList);
      };
      tweenList.add(TweenWrap(addTween, TweenWrap.addStatus));
    }
    if (removeSet.isNotEmpty) {
      ChartDoubleTween removeTween = ChartDoubleTween.fromValue(0, 1, props: attrs);
      removeTween.startListener = () {
        if (!hasCallStart) {
          hasCallStart = true;
          onStart?.call();
        }
      };
      removeTween.endListener = () {
        nodeList.removeWhere((e) {
          return removeSet.contains(e.getData());
        });
        resultCall.call(nodeList);
        if (!hasCallEnd) {
          hasCallEnd = true;
          onEnd?.call();
        }
      };
      removeTween.addListener(() {
        double t = removeTween.value;
        for (var d in removeSet) {
          N node = (oldMap[d] ?? newMap[d])!;
          P s = startMap[d] as P;
          P e = endMap[d] as P;
          node.setAttr(lerpFun.call(s, e, t, UpdateType.remove));
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
        updateTween.startListener = () {
          if (!hasCallStart) {
            hasCallStart = true;
            onStart?.call();
          }
        };
        updateTween.endListener = () {
          resultCall.call(nodeList);
          if (!hasCallEnd) {
            hasCallEnd = true;
            onEnd?.call();
          }
        };
        updateTween.addListener(() {
          double t = updateTween.value;
          for (var n in needUpdateList) {
            P s = startMap[n.getData()] as P;
            P e = endMap[n.getData()] as P;
            n.setAttr(lerpFun.call(s, e, t, UpdateType.update));
          }
          resultCall.call(nodeList);
        });
        tweenList.add(TweenWrap(updateTween, TweenWrap.updateStatus));
      }
    }

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
  static void diffUpdate<P, D, N extends NodeAccessor<P, D>>(
    Context context,
    AnimationAttrs attrs,
    Iterable<N> oldList,
    Iterable<N> newList,
    P Function(D data, N node, bool isOld) builder,
    P Function(P s, P e, double t) lerpFun,
    VoidCallback callback,
  ) {
    Map<D, P> startMap = {};
    Map<D, P> endMap = {};

    each(oldList, (p0, p1) {
      startMap[p0.getData()] = p0.getAttr();
      endMap[p0.getData()] = builder.call(p0.getData(), p0, true);
    });
    each(newList, (p0, p1) {
      startMap[p0.getData()] = p0.getAttr();
      endMap[p0.getData()] = builder.call(p0.getData(), p0, false);
    });
    final List<N> nodeList = [...oldList, ...newList];

    ChartDoubleTween updateTween = ChartDoubleTween.fromValue(0, 1, props: attrs);
    updateTween.endListener = () {
      callback.call();
    };
    updateTween.addListener(() {
      double t = updateTween.value;
      for (var n in nodeList) {
        P s = startMap[n.getData()] as P;
        P e = endMap[n.getData()] as P;
        n.setAttr(lerpFun.call(s, e, t));
      }
      callback.call();
    });
    updateTween.start(context, true);
  }
}

///属性访问器
///用于访问节点的布局位置和数据
abstract class NodeAccessor<P, D> {
  P getAttr();

  void setAttr(P attr);

  D getData();
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
  accessor,
}

enum UpdateType { add, update, remove }
