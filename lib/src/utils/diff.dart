import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///Diff 比较工具类
///用于在布局中实现动画
class DiffUtil {
  static DiffResult<T, P, K> diff<T, K, P>(
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
    return DiffResult(startMap, endMap, curList, finalList, removeSet, addSet, commonSet);
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

///优化的适用于超大数据的diff
///[nodeList] 现有节点列表
///[dataList] 新的数据集合
///[builder] 根据数据创建新的节点
///[layoutCall] 外部应该在改方法内部进行节点布局
///[startFun] 返回给定节点的动画初始信息
///[endFun] 返回给定节点的动画结束信息
///[lerpFun] 动画差值函数
///[updateCall] 动画更新函数
///[onStart] 动画开始时回调
///[onEnd] 动画结束时回调
///[testFun] 该函数用于判断一个节点是否需要执行动画 返回true则表示需要执行动画
///[reallocateDataIndex] true则表示需要对每个数据的dataIndex进行重新排序(通常为true)
List<AnimationNode> diffLayoutOpt<T, N extends DataNode<dynamic, T>>(
  AnimatorOption? attrs,
  Iterable<N> nodeList,
  Iterable<T> dataList,
  N Function(T data, int index) builder,
  void Function(List<N> nodes) layoutCall,
  Map<String, dynamic> Function(N node, DiffType type) startFun,
  Map<String, dynamic> Function(N node, DiffType type) endFun,
  void Function(N node, Map<String, dynamic> s, Map<String, dynamic> e, double t, DiffType type) lerpFun,
  void Function(List<N> resultList, double t) updateCall, {
  VoidCallback? onStart,
  void Function(List<N> nodes)? onEnd,
  bool Function(N node, Map<String, dynamic> map)? testFun,
  bool reallocateDataIndex = true,
}) {
  if (nodeList.isEmpty && dataList.isEmpty) {
    onStart?.call();
    updateCall.call([], 1);
    onEnd?.call([]);
    return [];
  }

  final Map<T, N> nodeMap = {for (var e in nodeList) e.data: e};

  ///分离数据的类型并存储节点索引
  Set<T> addSet = {};
  Set<T> updateSet = {};
  List<N> removeSet = [];

  ///存储新增数据和其节点的映射
  final Map<T, N> addNodeMap = {};

  ///存储数据索引
  final Map<T, int> indexMap = {};
  each(dataList, (data, p1) {
    if (nodeMap.containsKey(data)) {
      updateSet.add(data);
    } else {
      addSet.add(data);
      addNodeMap[data] = builder.call(data, p1);
    }
    indexMap[data] = p1;
  });

  ///找到被移除的数据
  Set<T> dataSet = Set.from(dataList);
  for (var node in nodeList) {
    if (!dataSet.contains(node.data)) {
      removeSet.add(node);
    }
  }

  ///存储节点初始和结束信息
  final Map<T, Map<String, dynamic>> startMap = {};
  final Map<T, Map<String, dynamic>> endMap = {};
  each(updateSet, (data, p1) {
    var node = nodeMap[data]!;
    startMap[data] = startFun.call(node, DiffType.update);
  });
  each(removeSet, (node, p1) {
    startMap[node.data] = startFun.call(node, DiffType.remove);
    endMap[node.data] = endFun.call(node, DiffType.remove);
  });

  ///创建新增节点并合并为结束后的数据项
  List<N> layoutList = List.from(addNodeMap.values);
  for (var update in updateSet) {
    layoutList.add(nodeMap[update]!);
  }

  ///重新分配数据索引
  if (reallocateDataIndex) {
    each(layoutList, (p0, p1) {
      p0.dataIndex = indexMap[p0.data] ?? p0.dataIndex;
    });
    layoutList.sort((a, b) {
      return a.dataIndex.compareTo(b.dataIndex);
    });
  }

  ///让外界进行布局
  layoutCall.call(layoutList);

  if (attrs == null) {
    onStart?.call();
    updateCall.call(layoutList, 1);
    onEnd?.call(layoutList);
    return [];
  }

  ///记录布局属性
  each(updateSet, (data, p1) {
    var node = nodeMap[data]!;
    endMap[data] = endFun.call(node, DiffType.update);
  });
  each(addSet, (data, p1) {
    var node = addNodeMap[data]!;
    startMap[data] = startFun.call(node, DiffType.add);
    endMap[data] = endFun.call(node, DiffType.add);
  });

  ///存放到动画结束前的所有节点数据
  final List<N> animationList = [...layoutList, ...removeSet];

  List<N> addAnimationList = [];
  List<N> addRemainList = [];
  if (testFun == null) {
    addAnimationList = List.from(addNodeMap.values);
  } else {
    addNodeMap.forEach((key, node) {
      var bs = testFun.call(node, startMap[node.data]!);
      var be = testFun.call(node, endMap[node.data]!);
      if (bs || be) {
        addAnimationList.add(node);
      } else {
        addRemainList.add(node);
      }
    });
  }
  List<N> removeAnimationList = [];
  List<N> removeRemainList = [];
  if (testFun == null) {
    removeAnimationList = removeSet;
  } else {
    each(removeSet, (node, p1) {
      var s = startMap[node.data]!;
      if (testFun.call(node, s)) {
        removeAnimationList.add(node);
      } else {
        removeRemainList.add(node);
      }
    });
  }
  List<N> updateAnimationList = [];
  List<N> updateRemainList = [];
  if (testFun == null) {
    updateAnimationList = List.from(updateSet.map((e) => nodeMap[e]!));
  } else {
    each(updateSet, (data, p1) {
      var node = nodeMap[data]!;
      var s = startMap[data]!;
      var e = endMap[data]!;
      var bs = testFun.call(node, s);
      var be = testFun.call(node, e);
      if (bs || be) {
        updateAnimationList.add(node);
      } else {
        updateRemainList.add(node);
      }
    });
  }

  ///动画执行完成后的数据
  final List<N> resultList = layoutList;

  void animationRun(Iterable<N> list, double t, DiffType type) {
    each(list, (node, p1) {
      var s = startMap[node.data]!;
      var e = endMap[node.data]!;
      lerpFun.call(node, s, e, t, type);
    });
  }

  void animationRun2(Iterable<T> list, double t, DiffType type) {
    each(list, (data, p1) {
      var node = (addNodeMap[data] ?? nodeMap[data])!;
      var s = startMap[data]!;
      var e = endMap[data]!;
      lerpFun.call(node, s, e, t, type);
    });
  }

  ///复原初始值(避免闪烁)
  animationRun2(addSet, 0, DiffType.add);
  animationRun2(updateSet, 0, DiffType.update);
  animationRun(removeSet, 0, DiffType.remove);

  ///创建动画对象
  List<TweenWrap> tweenList = [];
  int endCount = 0;

  void handleEnd() {
    if (endCount >= tweenList.length && tweenList.isNotEmpty) {
      animationRun2(addSet, 1, DiffType.add);
      animationRun2(updateSet, 1, DiffType.update);
      animationRun(removeSet, 1, DiffType.remove);
      updateCall.call(resultList, 1);
      onEnd?.call(resultList);
    }
  }

  ///判断是否要执行对应动画
  var doAdd = addAnimationList.isNotEmpty && attrs.check(LayoutType.layout, addAnimationList.length);
  var doRemove = removeAnimationList.isNotEmpty && attrs.check(LayoutType.update, removeAnimationList.length);
  var doUpdate = updateAnimationList.isNotEmpty && attrs.check(LayoutType.update, updateAnimationList.length);
  if (doAdd) {
    animationRun(addRemainList, 1, DiffType.add);
    var addTween = ChartDoubleTween(option: attrs);
    addTween.addListener(() {
      var t = addTween.value;
      animationRun(addAnimationList, t, DiffType.add);
      updateCall.call(animationList, t);
    });
    addTween.addEndListener(() {
      endCount += 1;
      handleEnd();
    });
    tweenList.add(TweenWrap(addTween, TweenWrap.addStatus));
  } else {
    animationRun2(addSet, 1, DiffType.add);
  }
  if (doRemove) {
    animationRun(removeRemainList, 1, DiffType.remove);
    var removeTween = ChartDoubleTween.fromValue(0, 1, option: attrs);
    removeTween.addListener(() {
      var t = removeTween.value;
      animationRun(removeAnimationList, t, DiffType.remove);
      updateCall.call(animationList, t);
    });
    removeTween.addEndListener(() {
      endCount += 1;
      handleEnd();
    });
    tweenList.add(TweenWrap(removeTween, TweenWrap.removeStatus));
  } else {
    animationRun(removeSet, 1, DiffType.remove);
  }
  if (doUpdate) {
    animationRun(updateRemainList, 1, DiffType.update);
    var updateTween = ChartDoubleTween.fromValue(0, 1, option: attrs);
    updateTween.addListener(() {
      var t = updateTween.value;
      animationRun(updateAnimationList, t, DiffType.update);
      updateCall.call(animationList, t);
    });
    updateTween.addEndListener(() {
      endCount += 1;
      handleEnd();
    });
    tweenList.add(TweenWrap(updateTween, TweenWrap.updateStatus));
  } else {
    animationRun2(updateSet, 1, DiffType.update);
  }

  ///无任何动画直接将所有节点还原到最后位置
  if (tweenList.isEmpty) {
    onStart?.call();
    updateCall.call(resultList, 1);
    onEnd?.call(resultList);
    return [];
  }
  if (onStart != null) {
    tweenList.first.tween.addStartListener(() {
      onStart.call();
    });
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

class DiffResult<N, P, D> {
  final Map<N, P> startMap;
  final Map<N, P> endMap;

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

enum DiffType {
  add,
  remove,
  update,
}
