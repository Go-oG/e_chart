import 'dart:async';
import 'dart:math' as math;
import 'package:e_chart/e_chart.dart';
import 'package:flutter/gestures.dart';
import '../../utils/platform_util.dart';
import 'package:vector_math/vector_math.dart' as vector;

///手势分发器
///处理手势分发(click,hover,doubleClick,longPress,scale,drag)
///手势处理部分来源:https://github.com/taodo2291/xgesture_flutter
class GestureDispatcher {
  Set<ChartGesture> _gestureNodeSet = {};
  final bool enableDoubleTap;
  final bool enableDrag;
  final bool enableScale;
  final bool enableLongPress;

  ///为true时则当双击时忽略单击
  final bool ignoreTapOnDoubleTap;

  ///是否允许在没有释放指针的情况下触发长按事件后的移动事件
  final bool bypassMoveEventAfterLongPress;

  final int doubleTapTimeConsider;
  final int longPressTimeConsider;

  /// 第一次触摸位置与长按事件发生时的位置之间的最大距离。默认值：25
  final int longPressMaxDistance;

  ///s========实际手势处理的地方==============
  late final _Inner _inner;

  GestureDispatcher(
      {this.enableDoubleTap = false,
      this.enableDrag = true,
      this.enableScale = true,
      this.enableLongPress = true,
      this.bypassMoveEventAfterLongPress = true,
      this.ignoreTapOnDoubleTap = true,
      this.doubleTapTimeConsider = 250,
      this.longPressTimeConsider = 350,
      this.longPressMaxDistance = 25}) {
    _inner = _Inner(this);
  }

  void addGesture(ChartGesture gesture) {
    _gestureNodeSet.add(gesture);
  }

  void removeGesture(ChartGesture gesture) {
    _gestureNodeSet.remove(gesture);
  }

  void dispose() {
    _hoverNodeSet.clear();
    _longPressNodeSet.clear();
    _dragNodeList.clear();
    _scaleNodeList.clear();
    var old = _gestureNodeSet;
    _gestureNodeSet = {};
    for (ChartGesture gesture in old) {
      gesture.clear();
    }
  }

  bool _allowGesture = true;

  void enable() => _allowGesture = true;

  void disable() => _allowGesture = false;

  void handleEvent(PointerEvent event, HitTestEntry entry) {
    if (!_allowGesture) {
      return;
    }
    if (event is PointerHoverEvent) {
      if (isDesktop) {
        onHoverMove(event);
      }
      return;
    }
    if (event is PointerEnterEvent) {
      if (isDesktop) {
        onHoverStart(event);
      }
      return;
    }
    if (event is PointerExitEvent) {
      if (isDesktop) {
        onHoverEnd(event);
      }
      return;
    }

    if (event is PointerDownEvent) {
      _inner.onPointerDown(event);
      return;
    }
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _inner.onPointerUp(event);
      return;
    }
    if (event is PointerMoveEvent) {
      _inner.onPointerMove(event);
      return;
    }
    if (event is PointerSignalEvent) {
      return _inner.onPointerSignal.call(event);
    }
  }

  ///=========鼠标手势==========================
  final Set<ChartGesture> _hoverNodeSet = {};

  void onHoverStart(PointerEnterEvent event) {
    _hoverNodeSet.clear();
    var e = TapEvent(event.localPosition, event.position, event.pointer);
    for (var ele in _gestureNodeSet) {
      if (!ele.contains(e.globalPosition)) {
        continue;
      }
      _hoverNodeSet.add(ele);
      ele.hoverStart?.call(e);
    }
  }

  void onHoverMove(PointerHoverEvent event) {
    if (_gestureNodeSet.isEmpty) {
      return;
    }
    var e = TapEvent(event.localPosition, event.position, event.pointer);
    Set<ChartGesture> removeSet = {};
    for (var ele in _gestureNodeSet) {
      if (!ele.contains(e.globalPosition)) {
        removeSet.add(ele);
        continue;
      }
      if (!_hoverNodeSet.contains(ele)) {
        _hoverNodeSet.add(ele);
        ele.hoverStart?.call(e);
      }
      ele.hoverMove?.call(e);
    }
    _hoverNodeSet.removeAll(removeSet);
    for (var element in removeSet) {
      element.hoverEnd?.call(e);
    }
  }

  void onHoverEnd(PointerExitEvent event) {
    var e = TapEvent(event.localPosition, event.position, event.pointer);
    for (var ele in _hoverNodeSet) {
      ele.hoverEnd?.call(e);
    }
  }

  ///=========点击事件==========================
  void onTap(TapEvent event) {
    for (var ele in _gestureNodeSet) {
      if (!ele.contains(event.globalPosition)) {
        continue;
      }
      ele.click?.call(event);
    }
  }

  ///=========双击事件==========================

  void onDoubleTap(TapEvent event) {
    for (var ele in _gestureNodeSet) {
      if (!ele.contains(event.globalPosition)) {
        continue;
      }
      ele.doubleClick?.call(event);
    }
  }

  ///=========长按事件==========================

  final Set<ChartGesture> _longPressNodeSet = {};

  void onLongPressStart(TapEvent event) {
    _longPressNodeSet.clear();
    for (var ele in _gestureNodeSet) {
      if (!ele.contains(event.localPos)) {
        continue;
      }
      _longPressNodeSet.add(ele);
      ele.longPressStart?.call(event);
    }
  }

  void onLongPressMove(MoveEvent event) {
    if (_longPressNodeSet.isEmpty) {
      return;
    }
    Set<ChartGesture> removeSet = {};
    for (var ele in _longPressNodeSet) {
      if (!ele.contains(event.localPos)) {
        removeSet.add(ele);
        continue;
      }
      if (ele.longPressMove == null) {
        continue;
      }
      ele.longPressMove?.call(event);
    }
    _longPressNodeSet.removeAll(removeSet);
    for (var element in removeSet) {
      element.longPressEnd?.call();
    }
  }

  void onLongPressEnd() {
    for (var ele in _longPressNodeSet) {
      ele.longPressEnd?.call();
    }
    _longPressNodeSet.clear();
  }

  ///=========拖拽==========================
  final Set<ChartGesture> _dragNodeList = {};

  void onMoveStart(MoveEvent event) {
    for (var ele in _gestureNodeSet) {
      if (!ele.contains(event.localPos)) {
        continue;
      }
      _dragNodeList.add(ele);
      ele.dragStart?.call(event);
    }
  }

  void onMoveUpdate(MoveEvent event) {
    Set<ChartGesture> removeList = {};
    for (var ele in _dragNodeList) {
      if (!ele.contains(event.localPos)) {
        removeList.add(ele);
        ele.dragEnd?.call();
      } else {
        ele.dragMove?.call(event);
      }
    }
    if (removeList.isNotEmpty) {
      _dragNodeList.removeAll(removeList);
    }
  }

  void onMoveEnd(MoveEvent event) {
    for (var ele in _dragNodeList) {
      ele.dragEnd?.call();
    }
    _dragNodeList.clear();
  }

  ///=========缩放============================
  final Set<ChartGesture> _scaleNodeList = {};

  void onScaleStart(Offset offset) {
    var event = TapEvent(offset, offset, -1);
    for (var ele in _gestureNodeSet) {
      if (!ele.contains(offset)) {
        continue;
      }
      _scaleNodeList.add(ele);
      ele.scaleStart?.call(event);
    }
  }

  void onScaleUpdate(ScaleEvent event) {
    Set<ChartGesture> removeSet = {};
    for (var ele in _scaleNodeList) {
      if (!ele.contains(event.focalPoint)) {
        removeSet.add(ele);
        ele.scaleEnd?.call();
      } else {
        ele.scaleUpdate?.call(event);
      }
    }
    if (removeSet.isNotEmpty) {
      _scaleNodeList.removeAll(removeSet);
    }
  }

  void onScaleEnd() {
    for (var ele in _scaleNodeList) {
      ele.scaleEnd?.call();
    }
  }
}

class _Inner {
  List<_GTouch> touches = [];
  double initScaleDistance = 1.0;
  _State state = _State.unknown;
  Timer? doubleTapTimer;
  Timer? longPressTimer;
  Offset lastTouchUpPos = Offset.zero;
  GestureDispatcher dispatcher;

  _Inner(this.dispatcher);

  void onPointerSignal(PointerSignalEvent event) {
    //不需要监听指针滚动事件
    // if (event is PointerScrollEvent&&dispatcher.enableScale) {
    //   dispatcher.onScrollEvent
    //       ?.call(ScrollEvent(event.pointer, event.localPosition, event.position, event.scrollDelta));
    // }
  }

  void onPointerDown(PointerDownEvent event) {
    touches.add(_GTouch(event.pointer, event.localPosition));
    if (touchCount == 1) {
      state = _State.pointerDown;
      startLongPressTimer(TapEvent.from(event));
    } else if (touchCount == 2) {
      state = _State.scaleStart;
    } else {
      state = _State.unknown;
    }
  }

  void initScaleAndRotate() {
    initScaleDistance = (touches[0].currentOffset - touches[1].currentOffset).distance;
  }

  void onPointerMove(PointerMoveEvent event) {
    final touch = touches.firstWhere((touch) => touch.id == event.pointer);
    touch.currentOffset = event.localPosition;
    cleanupDoubleTimer();

    switch (state) {
      case _State.longPress:
        if (dispatcher.bypassMoveEventAfterLongPress) {
          dispatcher.onLongPressMove.call(MoveEvent(event.localPosition, event.position, event.pointer,
              delta: event.delta, localDelta: event.localDelta));
        } else {
          switch2MoveStartState(touch, event);
        }
        break;
      case _State.pointerDown:
        switch2MoveStartState(touch, event);
        break;
      case _State.moveStart:
        dispatcher.onMoveUpdate.call(MoveEvent(event.localPosition, event.position, event.pointer,
            delta: event.delta, localDelta: event.localDelta));
        break;
      case _State.scaleStart:
        touch.startOffset = touch.currentOffset;
        state = _State.scalling;
        initScaleAndRotate();
        if (dispatcher.enableScale) {
          final centerOffset = (touches[0].currentOffset + touches[1].currentOffset) / 2;
          dispatcher.onScaleStart(centerOffset);
        }
        break;
      case _State.scalling:
        if (dispatcher.enableScale) {
          var rotation = angleBetweenLines(touches[0], touches[1]);
          final newDistance = (touches[0].currentOffset - touches[1].currentOffset).distance;
          final centerOffset = (touches[0].currentOffset + touches[1].currentOffset) / 2;
          dispatcher.onScaleUpdate(ScaleEvent(centerOffset, newDistance / initScaleDistance, rotation));
        }
        break;
      default:
        touch.startOffset = touch.currentOffset;
        break;
    }
  }

  void switch2MoveStartState(_GTouch touch, PointerMoveEvent event) {
    state = _State.moveStart;
    touch.startOffset = event.localPosition;
    dispatcher.onMoveStart.call(MoveEvent(event.localPosition, event.localPosition, event.pointer));
  }

  double angleBetweenLines(_GTouch f, _GTouch s) {
    double angle1 = math.atan2(f.startOffset.dy - s.startOffset.dy, f.startOffset.dx - s.startOffset.dx);
    double angle2 = math.atan2(f.currentOffset.dy - s.currentOffset.dy, f.currentOffset.dx - s.currentOffset.dx);

    double angle = vector.degrees(angle1 - angle2) % 360;
    if (angle < -180.0) angle += 360.0;
    if (angle > 180.0) angle -= 360.0;
    return vector.radians(angle);
  }

  void onPointerUp(PointerEvent event) {
    touches.removeWhere((touch) => touch.id == event.pointer);

    if (state == _State.pointerDown) {
      if (!dispatcher.ignoreTapOnDoubleTap || !dispatcher.enableDoubleTap) {
        callOnTap(TapEvent.from(event));
      }
      if (dispatcher.enableDoubleTap) {
        final tapEvent = TapEvent.from(event);
        if (doubleTapTimer == null) {
          startDoubleTapTimer(tapEvent);
        } else {
          cleanupTimer();
          if ((event.localPosition - lastTouchUpPos).distanceSquared < 200) {
            dispatcher.onDoubleTap(tapEvent);
          } else {
            startDoubleTapTimer(tapEvent);
          }
        }
      }
    } else if (state == _State.scaleStart || state == _State.scalling) {
      state = _State.unknown;
      dispatcher.onScaleEnd.call();
    } else if (state == _State.moveStart) {
      state = _State.unknown;
      dispatcher.onMoveEnd.call(MoveEvent(event.localPosition, event.position, event.pointer));
    } else if (state == _State.longPress) {
      dispatcher.onLongPressEnd.call();
      state = _State.unknown;
    } else if (state == _State.unknown && touchCount == 2) {
      state = _State.scaleStart;
    } else {
      state = _State.unknown;
    }
    lastTouchUpPos = event.localPosition;
  }

  void startLongPressTimer(TapEvent event) {
    if (dispatcher.enableLongPress) {
      if (longPressTimer != null) {
        longPressTimer!.cancel();
        longPressTimer = null;
      }
      longPressTimer = Timer(Duration(milliseconds: dispatcher.longPressTimeConsider), () {
        if (touchCount == 1 && touches[0].id == event.pointer && inLongPressRange(touches[0])) {
          state = _State.longPress;
          dispatcher.onLongPressStart(event);
          cleanupTimer();
        }
      });
    }
  }

  bool inLongPressRange(_GTouch touch) {
    return (touch.currentOffset - touch.startOffset).distanceSquared < dispatcher.longPressMaxDistance;
  }

  void startDoubleTapTimer(TapEvent event) {
    doubleTapTimer = Timer(Duration(milliseconds: dispatcher.doubleTapTimeConsider), () {
      state = _State.unknown;
      cleanupTimer();
      if (dispatcher.ignoreTapOnDoubleTap) {
        callOnTap(event);
      }
    });
  }

  void cleanupTimer() {
    cleanupDoubleTimer();
    if (longPressTimer != null) {
      longPressTimer!.cancel();
      longPressTimer = null;
    }
  }

  void cleanupDoubleTimer() {
    if (doubleTapTimer != null) {
      doubleTapTimer!.cancel();
      doubleTapTimer = null;
    }
  }

  void callOnTap(TapEvent event) {
    dispatcher.onTap.call(event);
  }

  get touchCount => touches.length;
}

class _GTouch {
  int id;
  Offset startOffset;
  late Offset currentOffset;

  _GTouch(this.id, this.startOffset) {
    currentOffset = startOffset;
  }
}

enum _State { pointerDown, moveStart, scaleStart, scalling, longPress, unknown }
