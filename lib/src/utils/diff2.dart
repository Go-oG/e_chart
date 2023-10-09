import 'dart:ui';

import '../../e_chart.dart';
import 'diff.dart';

///优化的适用于超大数据的diff
List<AnimationNode> diffLayoutOpt<T, N extends DataNode<dynamic, T>>(
  AnimatorOption? attrs,
  Iterable<N> nodeList,
  Iterable<T> dataList,
  N Function(T data) builder,
  void Function(List<N> nodes) layoutCall,
  Map<String, dynamic> Function(N node, DiffType type) startFun,
  Map<String, dynamic> Function(N node, DiffType type) endFun,
  void Function(N node, Map<String, dynamic> s, Map<String, dynamic> e, double t, DiffType type) lerpFun,
  void Function(List<N> resultList) updateCall, [
  VoidCallback? onStart,
  VoidCallback? onEnd,
]) {
  if (nodeList.isEmpty && dataList.isEmpty) {
    onStart?.call();
    updateCall.call([]);
    onEnd?.call();
    return [];
  }

  final Map<T, N> nodeMap = {for (var e in nodeList) e.data: e};

  ///分离数据的类型
  Set<T> addSet = {};
  Set<T> updateSet = {};
  List<N> removeSet = [];
  for (var data in dataList) {
    if (nodeMap.containsKey(data)) {
      updateSet.add(data);
    } else {
      addSet.add(data);
    }
  }
  Set<T> dataSet = Set.from(dataList);
  for (var node in nodeList) {
    if (!dataSet.contains(node.data)) {
      removeSet.add(node);
    }
  }

  ///存储节点原始信息
  Map<T, Map<String, dynamic>> startMap = {};
  Map<T, Map<String, dynamic>> endMap = {};
  each(updateSet, (data, p1) {
    var node = nodeMap[data]!;
    startMap[data] = startFun.call(node, DiffType.update);
  });
  each(removeSet, (node, p1) {
    startMap[node.data] = startFun.call(node, DiffType.remove);
    endMap[node.data] = endFun.call(node, DiffType.remove);
  });

  final Map<T, N> addNodeMap = {for (var e in addSet) e: builder.call(e)};

  List<N> layoutList = List.from(addNodeMap.values);
  for (var update in updateSet) {
    layoutList.add(nodeMap[update]!);
  }

  ///让外界进行布局
  layoutCall.call(layoutList);

  if (attrs == null) {
    onStart?.call();
    updateCall.call(layoutList);
    onEnd?.call();
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

  ///需要执行动画的数据
  final List<N> animationList = [...layoutList, ...removeSet];

  ///动画执行完成后的数据
  final List<N> resultList = layoutList;

  List<TweenWrap> tweenList = [];

  bool needCallAdd = false;
  bool needCallRemove = false;
  bool needCallUpdate = false;
  int endCount = 0;

  void innerRun() {
    if (needCallAdd) {
      each(addSet, (data, p1) {
        var node = addNodeMap[data]!;
        var s = startMap[data]!;
        var e = endMap[data]!;
        lerpFun.call(node, s, e, 1, DiffType.add);
      });
    }
    if (needCallRemove) {
      each(removeSet, (node, p1) {
        var s = startMap[node.data]!;
        var e = endMap[node.data]!;
        lerpFun.call(node, s, e, 1, DiffType.remove);
      });
    }
    if (needCallUpdate) {
      each(updateSet, (data, p1) {
        var node = nodeMap[data]!;
        var s = startMap[data]!;
        var e = endMap[data]!;
        lerpFun.call(node, s, e, 1, DiffType.update);
      });
    }
  }

  void handleEnd() {
    if (endCount >= tweenList.length && tweenList.isNotEmpty) {
      innerRun();
      updateCall.call(resultList);
      onEnd?.call();
    }
  }

  if (addSet.isNotEmpty) {
    if (attrs.check(LayoutType.layout, startMap.length)) {
      var addTween = ChartDoubleTween(option: attrs);
      addTween.addListener(() {
        double t = addTween.value;
        each(addSet, (data, p1) {
          var node = addNodeMap[data]!;
          var s = startMap[data]!;
          var e = endMap[data]!;
          lerpFun.call(node, s, e, t, DiffType.add);
        });
        updateCall.call(animationList);
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
        each(removeSet, (node, p1) {
          var s = startMap[node.data]!;
          var e = endMap[node.data]!;
          lerpFun.call(node, s, e, t, DiffType.remove);
        });
        updateCall.call(animationList);
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

  if (updateSet.isNotEmpty) {
    if (attrs.check(LayoutType.update, startMap.length)) {
      var updateTween = ChartDoubleTween.fromValue(0, 1, option: attrs);
      updateTween.addListener(() {
        double t = updateTween.value;
        each(updateSet, (data, p1) {
          var node = nodeMap[data]!;
          var s = startMap[data]!;
          var e = endMap[data]!;
          lerpFun.call(node, s, e, t, DiffType.update);
        });
        updateCall.call(animationList);
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
    updateCall.call(resultList);
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
