import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../../utils/platform_util.dart';
import '../gesture/chart_gesture.dart';
import 'view.dart';
///实现了一个简易的手势识别器
abstract class GestureView extends ChartView {
  late ChartGesture _gesture;

  @mustCallSuper
  @override
  void onCreate() {
    super.onCreate();
    _gesture = buildGesture;
  }

  @mustCallSuper
  @override
  void onLayoutEnd() {
    super.onLayoutEnd();
    onInitGesture(_gesture);
  }

  ChartGesture get buildGesture {
    return RectGesture();
  }

  Offset _lastHover = Offset.zero;
  Offset _lastDrag = Offset.zero;
  Offset _lastLongPress = Offset.zero;

  void onInitGesture(ChartGesture gesture) {
    gesture.clear();
    context.removeGesture(gesture);
    context.addGesture(gesture);
    if (enableClick) {
      gesture.click = (e) {
        onClick(toLocal(e.globalPosition));
      };
    }
    if (enableDoubleClick) {
      gesture.doubleClick = (e) {
        onDoubleClick(toLocal(e.globalPosition));
      };
    }

    if (enableHover) {
      gesture.hoverStart = (e) {
        _lastHover = toLocal(e.globalPosition);
        onHoverStart(_lastHover);
      };
      gesture.hoverMove = (e) {
        Offset of = toLocal(e.globalPosition);
        onHoverMove(of, _lastHover);
        _lastHover = of;
      };
      gesture.hoverEnd = (e) {
        _lastHover = Offset.zero;
        onHoverEnd();
      };
    }

    if (enableLongPress) {
      gesture.longPressStart = (e) {
        _lastLongPress = toLocal(e.globalPosition);
        onLongPressStart(_lastLongPress);
      };
      gesture.longPressMove = (e) {
        var offset = toLocal(e.globalPosition);
        var dx = offset.dx - _lastLongPress.dx;
        var dy = offset.dy - _lastLongPress.dy;
        _lastLongPress = offset;
        onLongPressMove(offset, Offset(dx, dy));
      };
      gesture.longPressEnd = () {
        _lastLongPress = Offset.zero;
        onLongPressEnd();
      };
    }

    if (enableDrag) {
      gesture.dragStart = (e) {
        var offset = toLocal(e.globalPosition);
        _lastDrag = offset;
        onDragStart(offset);
      };
      gesture.dragMove = (e) {
        var offset = toLocal(e.globalPosition);
        var dx = offset.dx - _lastDrag.dx;
        var dy = offset.dy - _lastDrag.dy;
        _lastDrag = offset;
        onDragMove(offset, Offset(dx, dy));
      };
      gesture.dragEnd = () {
        _lastDrag = Offset.zero;
        onDragEnd();
      };
    }

    if (enableScale) {
      gesture.scaleStart = (e) {
        onScaleStart(toLocal(e.globalPosition));
      };
      gesture.scaleUpdate = (e) {
        onScaleUpdate(toLocal(e.focalPoint), e.rotation, e.scale, false);
      };
      gesture.scaleEnd = () {
        onScaleEnd();
      };
    }

    if (gesture is RectGesture) {
      (gesture).rect = globalBoxBound;
    }
  }

  bool get enableClick => true;

  bool get enableDoubleClick => false;

  bool get enableLongPress => false;

  bool get enableHover => isWeb;

  bool get enableDrag => false;

  bool get enableScale => false;

  void onClick(Offset offset) {}

  void onDoubleClick(Offset offset) {}

  void onHoverStart(Offset offset) {}

  void onHoverMove(Offset offset, Offset last) {}

  void onHoverEnd() {}

  void onLongPressStart(Offset offset) {}

  void onLongPressMove(Offset offset, Offset diff) {}

  void onLongPressEnd() {}

  void onDragStart(Offset offset) {}

  void onDragMove(Offset offset, Offset diff) {}

  void onDragEnd() {}

  void onScaleStart(Offset offset) {}

  void onScaleUpdate(Offset offset, double rotation, double scale, bool doubleClick) {}

  void onScaleEnd() {}
}
