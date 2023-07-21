import 'dart:math';
import 'package:flutter/gestures.dart';
import '../model/enums/direction.dart';
import 'chart_gesture.dart';
import 'gesture_event.dart';

///手势分发器
///用于处理相关的手势分发
class GestureDispatcher {
  final Set<ChartGesture> _gestureNodeSet = {};

  GestureDispatcher();

  void addGesture(ChartGesture gesture) {
    _gestureNodeSet.add(gesture);
  }

  void removeGesture(ChartGesture gesture) {
    _gestureNodeSet.remove(gesture);
  }

  void dispose() {
    _hoverNodeSet.clear();
    _tapNodeSet.clear();
    _doubleTapNodeSet.clear();
    _longPressNodeSet.clear();
    _dragNodeList.clear();
    _scaleNodeList.clear();
    for (ChartGesture gesture in _gestureNodeSet) {
      gesture.clear();
    }
    _gestureNodeSet.clear();
  }

  ///=========鼠标手势==========================
  final Set<ChartGesture> _hoverNodeSet = {};

  void onHoverStart(PointerEnterEvent event) {
    // debugPrint('onHoverStart');
    _hoverNodeSet.clear();
    NormalEvent motionEvent = NormalEvent(event.localPosition);
    for (var ele in _gestureNodeSet) {
      if (!ele.isInArea(motionEvent.globalPosition)) {
        continue;
      }
      _hoverNodeSet.add(ele);
      ele.hoverStart?.call(motionEvent);
    }
  }

  void onHoverMove(PointerHoverEvent event) {
    NormalEvent motionEvent = NormalEvent(event.localPosition);
    NormalEvent se = NormalEvent(event.localPosition);
    NormalEvent ee = NormalEvent(event.localPosition);
    Set<ChartGesture> removeSet = {};
    for (var ele in _gestureNodeSet) {
      if (!ele.isInArea(motionEvent.globalPosition)) {
        removeSet.add(ele);
        continue;
      }
      if (!_hoverNodeSet.contains(ele)) {
        _hoverNodeSet.add(ele);
        ele.hoverStart?.call(se);
      }
      ele.hoverMove?.call(motionEvent);
    }
    _hoverNodeSet.removeAll(removeSet);
    for (var element in removeSet) {
      element.hoverEnd?.call(ee);
    }
  }

  void onHoverEnd(PointerExitEvent event) {
    NormalEvent motionEvent = NormalEvent(event.localPosition);
    for (var ele in _hoverNodeSet) {
      ele.hoverEnd?.call(motionEvent);
    }
  }

  ///=========点击事件==========================
  final Set<ChartGesture> _tapNodeSet = {};

  void onTapDown(TapDownDetails details) {
    _tapNodeSet.clear();
    NormalEvent motionEvent = NormalEvent(details.localPosition);
    for (var ele in _gestureNodeSet) {
      if (!ele.isInArea(motionEvent.globalPosition)) {
        continue;
      }
      _tapNodeSet.add(ele);
      ele.clickDown?.call(motionEvent);
    }
  }

  void onTapUp(TapUpDetails details) {
    Set<ChartGesture> removeSet = {};
    NormalEvent motionEvent = NormalEvent(details.localPosition);
    for (var ele in _tapNodeSet) {
      if (!ele.isInArea(motionEvent.globalPosition)) {
        removeSet.add(ele);
        continue;
      }

      ele.clickUp?.call(motionEvent);
      ele.click?.call(motionEvent);
    }
    _tapNodeSet.removeAll(removeSet);
    for (var element in removeSet) {
      element.clickCancel?.call();
    }
    _tapNodeSet.clear();
  }

  void onTapCancel() {
    for (var element in _tapNodeSet) {
      element.clickCancel?.call();
    }
    _tapNodeSet.clear();
  }

  ///=========双击事件==========================
  final Set<ChartGesture> _doubleTapNodeSet = {};

  void onDoubleTapDown(TapDownDetails details) {
    _doubleTapNodeSet.clear();
    NormalEvent motionEvent = NormalEvent(details.localPosition);
    for (var ele in _gestureNodeSet) {
      if (!ele.isInArea(motionEvent.globalPosition)) {
        continue;
      }
      _doubleTapNodeSet.add(ele);
      ele.doubleClickDown?.call(motionEvent);
    }
  }

  void onDoubleTapUp(TapUpDetails details) {
    NormalEvent motionEvent = NormalEvent(details.localPosition);
    Set<ChartGesture> removeSet = {};
    for (var ele in _doubleTapNodeSet) {
      if (!ele.isInArea(motionEvent.globalPosition)) {
        removeSet.add(ele);
        continue;
      }
      ele.doubleClickUp?.call(motionEvent);
      ele.doubleClick?.call(motionEvent);
    }
    _doubleTapNodeSet.removeAll(removeSet);
    for (var element in removeSet) {
      element.doubleClickCancel?.call();
    }
  }

  void onDoubleTapCancel() {
    for (var element in _doubleTapNodeSet) {
      element.doubleClickCancel?.call();
    }
  }

  ///=========长按事件==========================
  final Set<ChartGesture> _longPressNodeSet = {};

  void onLongPressStart(LongPressStartDetails details) {
    _longPressNodeSet.clear();
    NormalEvent motionEvent = NormalEvent(details.localPosition);
    for (var ele in _gestureNodeSet) {
      if (!ele.isInArea(details.localPosition)) {
        continue;
      }
      _longPressNodeSet.add(ele);
      ele.longPressStart?.call(motionEvent);
    }
  }

  void onLongPressMove(LongPressMoveUpdateDetails details) {
    // debugPrint('onLongPressMove');
    LongPressMoveEvent event = LongPressMoveEvent(
      details.localPosition,
      details.localOffsetFromOrigin,
      details.offsetFromOrigin,
    );
    Set<ChartGesture> removeSet = {};
    for (var ele in _longPressNodeSet) {
      if (!ele.isInArea(event.globalPosition)) {
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
      element.longPressCancel?.call();
    }
  }

  void onLongPressEnd(LongPressEndDetails details) {
    NormalEvent event = NormalEvent(details.localPosition);
    Set<ChartGesture> removeSet = {};
    for (var ele in _longPressNodeSet) {
      if (!ele.isInArea(event.globalPosition)) {
        removeSet.add(ele);
        continue;
      }
      if (ele.longPressEnd == null) {
        continue;
      }
      ele.longPressEnd?.call(event);
    }
    _longPressNodeSet.removeAll(removeSet);
    for (var element in removeSet) {
      element.longPressCancel?.call();
    }
  }

  void onLongPressCancel() {
    // debugPrint('onLongPressCancel');
    for (var element in _longPressNodeSet) {
      element.longPressCancel?.call();
    }
    _longPressNodeSet.clear();
  }

  ///=========缩放or 拖拽(需要自行判断)==========================
  final Set<ChartGesture> _dragNodeList = {};
  ScaleStartDetails? _dragDetails;
  Direction _dragDirection = Direction.horizontal;
  bool _dragFirst = true;

  final Set<ChartGesture> _scaleNodeList = {};
  bool _isScale = false;

  void onScaleStart(ScaleStartDetails details) {
    NormalEvent event = NormalEvent(details.localFocalPoint);
    if (details.pointerCount < 2) {
      _dragDetails = details;

      /// 滑动
      for (var ele in _gestureNodeSet) {
        if (!ele.isInArea(details.focalPoint)) {
          continue;
        }
        _dragNodeList.add(ele);
      }
      return;
    }

    ///缩放
    _isScale = true;
    for (var ele in _gestureNodeSet) {
      if (!ele.isInArea(event.globalPosition)) {
        continue;
      }
      _scaleNodeList.add(ele);
      ele.scaleStart?.call(event);
    }
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount < 2 || details.rotation == 0) {
      //滑动
      if (_dragFirst) {
        if(_dragDetails==null){
          return;
        }
        _dragFirst = false;
        ScaleStartDetails fd = _dragDetails!;
        double dx = details.focalPoint.dx - fd.focalPoint.dx;
        double dy = details.focalPoint.dy - fd.focalPoint.dy;
        double at = (atan2(dy, dx) * 180 / pi).abs();
        NormalEvent eventH = NormalEvent(details.localFocalPoint);
        NormalEvent eventV = NormalEvent(details.localFocalPoint);
        _dragDirection = at < 45 ? Direction.horizontal : Direction.vertical;
        Set<ChartGesture> removeList = {};
        for (var ele in _dragNodeList) {
          if (!ele.isInArea(details.focalPoint)) {
            removeList.add(ele);
          } else {
            if (_dragDirection == Direction.horizontal) {
              ele.horizontalDragStart?.call(eventH);
            } else {
              ele.verticalDragStart?.call(eventV);
            }
          }
        }
        if (removeList.isNotEmpty) {
          _dragNodeList.removeAll(removeList);
        }
      } else {
        NormalEvent eventH = NormalEvent(details.localFocalPoint);
        NormalEvent eventV = NormalEvent(details.localFocalPoint,);
        Set<ChartGesture> removeList = {};
        for (var ele in _dragNodeList) {
          if (!ele.isInArea(details.focalPoint)) {
            removeList.add(ele);
            if (_dragDirection == Direction.horizontal) {
              ele.horizontalDragCancel?.call();
            } else {
              ele.verticalDragCancel?.call();
            }
          } else {
            if (_dragDirection == Direction.horizontal) {
              ele.horizontalDragMove?.call(eventH);
            } else {
              ele.verticalDragMove?.call(eventV);
            }
          }
        }
        if (removeList.isNotEmpty) {
          _dragNodeList.removeAll(removeList);
        }
      }
      return;
    }

    ///缩放
    Set<ChartGesture> removeSet = {};
    ScaleEvent motionEvent =
        ScaleEvent(details.scale, details.horizontalScale, details.verticalScale, details.rotation, details.localFocalPoint);
    for (var ele in _scaleNodeList) {
      if (!ele.isInArea(motionEvent.globalPosition)) {
        removeSet.add(ele);
        ele.scaleCancel?.call();
      } else {
        ele.scaleUpdate?.call(motionEvent);
      }
    }
    if (removeSet.isNotEmpty) {
      _scaleNodeList.removeAll(removeSet);
    }
  }

  void onScaleEnd(ScaleEndDetails details) {
    if (!_isScale) {
      for (var ele in _dragNodeList) {
        if (_dragDirection == Direction.horizontal) {
          ele.horizontalDragEnd?.call(VelocityEvent(details.velocity, 1));
        } else {
          ele.verticalDragEnd?.call(VelocityEvent(details.velocity, 1));
        }
      }
      _dragNodeList.clear();
      _dragFirst = true;
      _dragDetails = null;
      _isScale = false;
      return;
    }

    VelocityEvent motionEvent = VelocityEvent(details.velocity, details.pointerCount);
    for (var ele in _scaleNodeList) {
      ele.scaleEnd?.call(motionEvent);
    }
    _scaleNodeList.clear();
    _dragFirst = true;
    _dragDetails = null;
    _isScale = false;
  }
}
