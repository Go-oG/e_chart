import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///Diff 比较工具类
///用于在布局中实现动画
class DiffUtil {
  ///给定前后的数据集
  ///按更新内别返回数据
  ///[updateUseOld] 为true 表示当数据类型为update时 保留原有数据， false则使用现有数据
  static DiffResult<N> diffData<N>(Iterable<N> oldList, Iterable<N> newList) {
    checkRef(oldList, newList, '在Diff中传入数据集引用不能相等');
    Set<N> oldSet = toSetIfNeed(oldList);
    Set<N> newSet = toSetIfNeed(newList);

    Set<N> addSet = {};
    Set<N> removeSet = {};
    Set<N> oldUpdateSet = {};
    Set<N> newUpdateSet = {};

    for (var data in newList) {
      if (!oldSet.contains(data)) {
        addSet.add(data);
      } else {
        newUpdateSet.add(data);
      }
    }

    for (var data in oldList) {
      if (!newSet.contains(data)) {
        removeSet.add(data);
      } else {
        oldUpdateSet.add(data);
      }
    }

    return DiffResult(addSet, removeSet, oldUpdateSet, newUpdateSet);
  }

  ///执行Diff动画相关
  static List<AnimationNode> diff<D extends RenderData>(
    AnimatorOption? option,
    Iterable<D> oldList,
    Iterable<D> newList,
    void Function(List<D> dataList) layoutFun,
    Map<String, dynamic> Function(D data, DiffType type) startFun,
    Map<String, dynamic> Function(D data, DiffType type) endFun,
    void Function(D data, Map<String, dynamic> s, Map<String, dynamic> e, double t, DiffType type) lerpFun,
    void Function(List<D> dataList, double t) updateCall, {
    VoidCallback? onStart,
    VoidCallback? onEnd,
    void Function(List<D> removeList)? removeDataCall,
  }) {
    if (oldList.isEmpty && newList.isEmpty) {
      onStart?.call();
      updateCall.call([], 1);
      onEnd?.call();
      removeDataCall?.call([]);
      return [];
    }
    final List<D> newList2 = toListIfNeed(newList);
    if (option == null) {
      layoutFun.call(newList2);
      onStart?.call();
      updateCall.call(newList2, 1);
      onEnd?.call();
      removeDataCall?.call(List.from(oldList));
      return [];
    }

    ///保留旧的数据
    var diffResult = diffData(oldList, newList);
    var newLen = diffResult.newUpdateSet.length;
    var oldLen = diffResult.oldUpdateSet.length;
    if (newLen != oldLen) {
      throw ChartError("Diff 状态异常 newLen:$newLen oldLen:$oldLen");
    }

    ///存储动画前后状态
    final Map<D, Map<String, dynamic>> startMap = {};
    final Map<D, Map<String, dynamic>> endMap = {};
    each(diffResult.oldUpdateSet, (data, p1) {
      startMap[data] = startFun.call(data, DiffType.update);
    });
    each(diffResult.removeSet, (data, p1) {
      startMap[data] = startFun.call(data, DiffType.remove);
      endMap[data] = endFun.call(data, DiffType.remove);
    });

    ///布局
    final List<D> layoutData = [...diffResult.addSet, ...diffResult.newUpdateSet];
    layoutFun.call(layoutData);

    ///再次存储相关动画属性
    each(diffResult.addSet, (data, p1) {
      startMap[data] = startFun.call(data, DiffType.add);
      endMap[data] = endFun.call(data, DiffType.add);
    });
    each(diffResult.newUpdateSet, (data, p1) {
      endMap[data] = endFun.call(data, DiffType.update);
    });

    ///还原需要布局数据的初始状态
    each(diffResult.addSet, (data, p1) {
      var s = startMap[data]!;
      var e = startMap[data]!;
      lerpFun.call(data, s, e, 0, DiffType.add);
    });
    each(diffResult.newUpdateSet, (data, p1) {
      var s = startMap[data]!;
      var e = startMap[data]!;
      lerpFun.call(data, s, e, 0, DiffType.update);
    });

    final List<D> animatorList = [...newList, ...diffResult.oldUpdateSet];
    List<D> updateCallList = animatorList;

    List<TweenWrap> tweenList = [];
    var addTween = ChartDoubleTween(option: option);
    addTween.addListener(() {
      double t = addTween.value;
      for (var key in diffResult.addSet) {
        var s = startMap[key]!;
        var e = endMap[key]!;
        lerpFun.call(key, s, e, t, DiffType.add);
      }
      updateCall.call(updateCallList, t);
    });
    tweenList.add(TweenWrap(addTween, DiffType.add));
    var removeTween = ChartDoubleTween(option: option);
    removeTween.addListener(() {
      double t = removeTween.value;
      for (var key in diffResult.removeSet) {
        var s = startMap[key]!;
        var e = endMap[key]!;
        lerpFun.call(key, s, e, t, DiffType.remove);
      }
      updateCall.call(updateCallList, t);
    });
    removeTween.addEndListener(() {
      updateCallList = newList2;
    });
    tweenList.add(TweenWrap(removeTween, DiffType.remove));

    var updateTween = ChartDoubleTween(option: option);
    updateTween.addListener(() {
      double t = updateTween.value;
      for (var key in diffResult.newUpdateSet) {
        var s = startMap[key]!;
        var e = endMap[key]!;
        lerpFun.call(key, s, e, t, DiffType.update);
      }
      updateCall.call(updateCallList, t);
    });
    tweenList.add(TweenWrap(updateTween, DiffType.update));

    if (onStart != null) {
      tweenList.first.tween.addStartListener(() {
        onStart.call();
      });
    }

    if (onEnd != null||removeDataCall!=null) {
      var endTween = option.duration.inMilliseconds >= option.updateDuration.inMilliseconds ? addTween : updateTween;
      endTween.addEndListener(() {
        onEnd?.call();
        removeDataCall?.call(List.from(diffResult.removeSet));
      });
    }

    List<AnimationNode> nl = [];
    for (var wrap in tweenList) {
      var type = wrap.type;
      if (type == DiffType.update || type == DiffType.remove) {
        nl.add(AnimationNode(wrap.tween, option, LayoutType.update));
      } else {
        nl.add(AnimationNode(wrap.tween, option, LayoutType.layout));
      }
    }
    return nl;
  }

  ///用于在点击或者hover触发时执行diff动画
  static List<AnimationNode> diffUpdate<P, N extends RenderData<P>>(
    AnimatorOption? attrs,
    Iterable<N> oldList,
    Iterable<N> newList,
    P Function(N data, bool isOld) builder,
    P Function(P s, P e, double t) lerpFun,
    VoidCallback callback,
  ) {
    if (identical(oldList, newList)) {
      throw ChartError("传入的前后引用不能相等");
    }
    Map<N, P> startMap = {};
    Map<N, P> endMap = {};

    each(oldList, (p0, p1) {
      startMap[p0] = p0.attr;
      endMap[p0] = builder.call(p0, true);
    });
    each(newList, (p0, p1) {
      startMap[p0] = p0.attr;
      endMap[p0] = builder.call(p0, false);
    });
    final List<N> nodeList = [...oldList, ...newList];

    if (attrs == null || !attrs.check(LayoutType.update, oldList.length + newList.length)) {
      for (var n in nodeList) {
        P s = startMap[n] as P;
        P e = endMap[n] as P;
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
        P s = startMap[n] as P;
        P e = endMap[n] as P;
        n.attr = lerpFun.call(s, e, t);
      }
      callback.call();
    });
    return [AnimationNode(updateTween, attrs, LayoutType.update)];
  }
}

///优化的适用于超大数据的diff
///[oldList] 现有节点列表
///[newList] 新的数据集合
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
List<AnimationNode> diffLayoutOpt<N extends RenderData>(
  AnimatorOption? attrs,
  Iterable<N> oldList,
  Iterable<N> newList,
  void Function(List<N> datas) layoutCall,
  Map<String, dynamic> Function(N node, DiffType type) startFun,
  Map<String, dynamic> Function(N node, DiffType type) endFun,
  void Function(N node, Map<String, dynamic> s, Map<String, dynamic> e, double t, DiffType type) lerpFun,
  void Function(List<N> resultList, double t) updateCall, {
  VoidCallback? onStart,
  void Function(List<N> nodes)? onEnd,
  bool Function(N node, Map<String, dynamic> map)? testFun,
  bool reallocateDataIndex = true,
}) {
  if (oldList.isEmpty && newList.isEmpty) {
    onStart?.call();
    updateCall.call([], 1);
    onEnd?.call([]);
    return [];
  }

  Set<N> nodeSet = toSetIfNeed(oldList);

  ///分离数据的类型并存储节点索引
  Set<N> addSet = {};
  Set<N> updateSet = {};
  List<N> removeSet = [];

  ///存储数据索引
  final Map<N, int> indexMap = {};
  each(newList, (data, p1) {
    if (nodeSet.contains(data)) {
      updateSet.add(data);
    } else {
      addSet.add(data);
    }
    indexMap[data] = p1;
  });

  ///找到被移除的数据
  Set<N> dataSet = Set.from(newList);
  for (var node in oldList) {
    if (!dataSet.contains(node)) {
      removeSet.add(node);
    }
  }

  ///存储节点初始和结束信息
  final Map<N, Map<String, dynamic>> startMap = {};
  final Map<N, Map<String, dynamic>> endMap = {};
  each(updateSet, (data, p1) {
    startMap[data] = startFun.call(data, DiffType.update);
  });
  each(removeSet, (node, p1) {
    startMap[node] = startFun.call(node, DiffType.remove);
    endMap[node] = endFun.call(node, DiffType.remove);
  });

  ///创建新增节点并合并为结束后的数据项
  List<N> layoutList = List.from(addSet);
  layoutList.addAll(updateSet);

  ///重新分配数据索引
  if (reallocateDataIndex) {
    each(layoutList, (p0, p1) {
      p0.dataIndex = indexMap[p0] ?? p0.dataIndex;
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
    endMap[data] = endFun.call(data, DiffType.update);
  });
  each(addSet, (data, p1) {
    startMap[data] = startFun.call(data, DiffType.add);
    endMap[data] = endFun.call(data, DiffType.add);
  });

  ///存放到动画结束前的所有节点数据
  final List<N> animationList = [...layoutList, ...removeSet];

  List<N> addAnimationList = [];
  List<N> addRemainList = [];
  if (testFun == null) {
    addAnimationList = List.from(addSet);
  } else {
    for (var node in addSet) {
      var bs = testFun.call(node, startMap[node]!);
      var be = testFun.call(node, endMap[node]!);
      if (bs || be) {
        addAnimationList.add(node);
      } else {
        addRemainList.add(node);
      }
    }
  }
  List<N> removeAnimationList = [];
  List<N> removeRemainList = [];
  if (testFun == null) {
    removeAnimationList = removeSet;
  } else {
    each(removeSet, (node, p1) {
      var s = startMap[node]!;
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
    updateAnimationList = List.from(updateSet);
  } else {
    each(updateSet, (data, p1) {
      var s = startMap[data]!;
      var e = endMap[data]!;
      var bs = testFun.call(data, s);
      var be = testFun.call(data, e);
      if (bs || be) {
        updateAnimationList.add(data);
      } else {
        updateRemainList.add(data);
      }
    });
  }

  ///动画执行完成后的数据
  final List<N> resultList = layoutList;

  void animationRun(Iterable<N> list, double t, DiffType type) {
    each(list, (node, p1) {
      var s = startMap[node]!;
      var e = endMap[node]!;
      lerpFun.call(node, s, e, t, type);
    });
  }

  ///复原初始值(避免闪烁)
  animationRun(addSet, 0, DiffType.add);
  animationRun(updateSet, 0, DiffType.update);
  animationRun(removeSet, 0, DiffType.remove);

  ///创建动画对象
  List<TweenWrap> tweenList = [];
  int endCount = 0;

  void handleEnd() {
    if (endCount >= tweenList.length && tweenList.isNotEmpty) {
      animationRun(addSet, 1, DiffType.add);
      animationRun(updateSet, 1, DiffType.update);
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
    tweenList.add(TweenWrap(addTween, DiffType.add));
  } else {
    animationRun(addSet, 1, DiffType.add);
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
    tweenList.add(TweenWrap(removeTween, DiffType.remove));
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
    tweenList.add(TweenWrap(updateTween, DiffType.update));
  } else {
    animationRun(updateSet, 1, DiffType.update);
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
    var status = wrap.type;
    if (status == DiffType.update || status == DiffType.remove) {
      nl.add(AnimationNode(wrap.tween, attrs, LayoutType.update));
    } else {
      nl.add(AnimationNode(wrap.tween, attrs, LayoutType.layout));
    }
  }

  return nl;
}

enum DiffType {
  add,
  remove,
  update,
}

class DiffResult<N> {
  final Set<N> removeSet;
  final Set<N> addSet;
  final Set<N> oldUpdateSet;
  final Set<N> newUpdateSet;

  DiffResult(
    this.addSet,
    this.removeSet,
    this.oldUpdateSet,
    this.newUpdateSet,
  );
}

class TweenWrap {
  final ChartTween tween;
  final DiffType type;

  TweenWrap(this.tween, this.type);
}
