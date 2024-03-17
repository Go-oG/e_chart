import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:e_chart/src/event/chart_action_dispatcher.dart' as ac;

///存放整个图表的配置.包含所有的图形实例和动画、手势
///一个Context 对应一个图表实例
///每个Context各包含一个 TickerProvider
/// GestureDispatcher、AnimationManager、EventDispatcher、ActionDispatcher
class Context extends Disposable {
  ChartOption get option => _option!;

  ChartOption? _option;

  ///这里不将其暴露出去是为了能更好的管理动画的生命周期
  TickerProvider? _provider;

  GestureDispatcher get gestureDispatcher => _gestureDispatcher;
  final GestureDispatcher _gestureDispatcher = GestureDispatcher();

  AnimationManager get animationManager => _animationManager;
  final AnimationManager _animationManager = AnimationManager();

  EventDispatcher get eventDispatcher => _eventDispatcher;
  final EventDispatcher _eventDispatcher = EventDispatcher();

  ac.ActionDispatcher get actionDispatcher => _actionDispatcher;
  final ac.ActionDispatcher _actionDispatcher = ac.ActionDispatcher();

  double devicePixelRatio;

  Context(this._option, TickerProvider provider, [this.devicePixelRatio = 1]) {
    _provider = provider;

    ///绑定事件
    option.eventCall?.forEach((key, value) {
      for (var c in value) {
        _eventDispatcher.addCall(key, c);
      }
    });

  }

  ///更新TickerProvider
  set tickerProvider(TickerProvider p) {
    if (p == _provider) {
      return;
    }
    _provider = p;
    _animationManager.updateTickerProvider(p);
  }

  ///分配索引
  void allocateIndex() {
    //给Series 分配索引
    //同时包含了样式索引
    int styleIndex = 0;
    each(option.series, (series, i) {
      series.seriesIndex = i;
      styleIndex += series.onAllocateStyleIndex(styleIndex);
    });
  }

  ///====生命周期函数=====
  void attach() {
    allocateIndex();
  }

  void detach(){}

  @override
  void dispose() {
    _eventDispatcher.dispose();
    _actionDispatcher.dispose();
    _gestureDispatcher.dispose();
    _animationManager.dispose();
    _option = null;
    _provider = null;
    super.dispose();
  }


  ///=======手势监听处理===============
  void addGesture(ChartGesture gesture) {
    _gestureDispatcher.addGesture(gesture);
  }

  void removeGesture(ChartGesture gesture) {
    _gestureDispatcher.removeGesture(gesture);
  }

  ///=========动画管理==================

  AnimationController boundedAnimation(AnimatorOption props, [bool useUpdate = false]) {
    return _animationManager.bounded(_provider!, props, useUpdate: useUpdate);
  }

  AnimationController unboundedAnimation() {
    return _animationManager.unbounded(_provider!);
  }

  void removeAnimation(AnimationController? c, [bool cancel = true]) {
    if (c == null) {
      return;
    }
    _animationManager.remove(c, cancel);
  }

  void addAnimationToQueue(List<AnimationNode> nodes) {
    _animationManager.addAnimators(nodes);
  }

  List<AnimationNode> getAndResetAnimationQueue() {
    return _animationManager.getAndRestAnimatorQueue();
  }

  ///========Action分发监听============

  void addActionCall(Fun2<ChartAction, bool> call) {
    _actionDispatcher.addCall(call);
  }

  void removeActionCall(Fun2<ChartAction, bool> call) {
    _actionDispatcher.removeCall(call);
  }

  void dispatchAction(ChartAction action) {
    _actionDispatcher.dispatch(action);
  }

  ///=======Event分发和监听===============
  void addEventCall(EventType type, VoidFun1<ChartEvent>? call) {
    if (call == null) {
      return;
    }
    _eventDispatcher.addCall(type, call);
  }

  void removeEventCall(VoidFun1<ChartEvent>? call) {
    if (call == null) {
      return;
    }
    _eventDispatcher.removeCall(call);
  }

  void removeEventCall2(EventType type, VoidFun1<ChartEvent>? call) {
    if (call == null) {
      return;
    }
    _eventDispatcher.removeCall2(type, call);
  }

  void dispatchEvent(ChartEvent event) {
    if (_eventDispatcher.hasEventListener(EventType.rendered)) {
      _eventDispatcher.dispatch(event);
    }
  }

  bool hasEventListener(EventType? type) {
    return _eventDispatcher.hasEventListener(type);
  }
}
