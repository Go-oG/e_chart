import 'package:flutter/gestures.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart' as x;
import 'chart_gesture.dart';
import 'gesture_event.dart';
import 'gesture_event.dart' as ge;

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
  void onTap(TapEvent event) {
    NormalEvent motionEvent = NormalEvent(event.localPos);
    for (var ele in _gestureNodeSet) {
      if (!ele.isInArea(motionEvent.globalPosition)) {
        continue;
      }
      ele.click?.call(motionEvent);
    }
  }

  ///=========双击事件==========================

  void onDoubleTap(TapEvent event) {
    NormalEvent motionEvent = NormalEvent(event.localPos);
    for (var ele in _gestureNodeSet) {
      if (!ele.isInArea(motionEvent.globalPosition)) {
        continue;
      }
      ele.doubleClick?.call(motionEvent);
    }
  }

  ///=========长按事件==========================

  final Set<ChartGesture> _longPressNodeSet = {};

  void onLongPressStart(TapEvent event) {
    _longPressNodeSet.clear();
    NormalEvent motionEvent = NormalEvent(event.localPos);
    for (var ele in _gestureNodeSet) {
      if (!ele.isInArea(event.localPos)) {
        continue;
      }
      _longPressNodeSet.add(ele);
      ele.longPressStart?.call(motionEvent);
    }
  }

  void onLongPressMove(MoveEvent event) {
    LongPressMoveEvent le = LongPressMoveEvent(event.localPos, event.localDelta, event.delta);
    Set<ChartGesture> removeSet = {};
    for (var ele in _longPressNodeSet) {
      if (!ele.isInArea(le.globalPosition)) {
        removeSet.add(ele);
        continue;
      }
      if (ele.longPressMove == null) {
        continue;
      }
      ele.longPressMove?.call(le);
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
    NormalEvent ne = NormalEvent(event.localPos);
    for (var ele in _gestureNodeSet) {
      if (!ele.isInArea(event.localPos)) {
        continue;
      }
      _dragNodeList.add(ele);
      ele.dragStart?.call(ne);
    }
  }

  void onMoveUpdate(MoveEvent event) {
    NormalEvent ne = NormalEvent(event.localPos);
    Set<ChartGesture> removeList = {};
    for (var ele in _dragNodeList) {
      if (!ele.isInArea(event.localPos)) {
        removeList.add(ele);
        ele.dragEnd?.call();
      } else {
        ele.dragMove?.call(ne);
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
    NormalEvent event = NormalEvent(offset);
    for (var ele in _gestureNodeSet) {
      if (!ele.isInArea(event.globalPosition)) {
        continue;
      }
      _scaleNodeList.add(ele);
      ele.scaleStart?.call(event);
    }
  }

  void onScaleUpdate(x.ScaleEvent event) {
    Set<ChartGesture> removeSet = {};
    ge.ScaleEvent se = ge.ScaleEvent(event.focalPoint, event.scale, event.rotationAngle);
    for (var ele in _scaleNodeList) {
      if (!ele.isInArea(event.focalPoint)) {
        removeSet.add(ele);
        ele.scaleEnd?.call();
      } else {
        ele.scaleUpdate?.call(se);
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
