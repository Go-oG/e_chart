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
    void Function(DiffResult<D> diffInfo)? diffInfoCall,
  }) {
    if (oldList.isEmpty && newList.isEmpty) {
      onStart?.call();
      updateCall.call([], 1);
      onEnd?.call();
      removeDataCall?.call([]);
      return [];
    }
    final List<D> newList2 = toListIfNeed(newList);
    newList2.sort((a, b) {
      return a.dataIndex.compareTo(b.dataIndex);
    });

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
    diffInfoCall?.call(diffResult);

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
    layoutData.sort((a, b) {
      return a.dataIndex.compareTo(b.dataIndex);
    });
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
      var e = endMap[data]!;
      lerpFun.call(data, s, e, 0, DiffType.add);
    });
    each(diffResult.newUpdateSet, (data, p1) {
      var s = startMap[data]!;
      var e = endMap[data]!;
      lerpFun.call(data, s, e, 0, DiffType.update);
    });

    final List<D> animatorList = [...diffResult.addSet, ...diffResult.newUpdateSet,...diffResult.removeSet];
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

    if (onEnd != null || removeDataCall != null) {
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

  String countInfo() {
    return "[add:${addSet.length},update:${newUpdateSet.length},remove:${removeSet.length},all:${addSet.length + newUpdateSet.length}] ";
  }
}

class TweenWrap {
  final ChartTween tween;
  final DiffType type;

  TweenWrap(this.tween, this.type);
}
