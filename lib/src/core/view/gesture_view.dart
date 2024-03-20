import 'dart:math';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/foundation.dart';

///实现了一个简易的手势识别器
abstract class GestureView extends ChartView {
  late ChartGesture _gesture;

  bool _enableGesture = true;

  GestureView(super.context);

  void disableGesture() {
    _enableGesture = false;
  }

  void enableGesture() {
    _enableGesture = true;
  }

  @mustCallSuper
  @override
  void onCreate() {
    super.onCreate();
    _gesture = CallGesture(hintTouch);
    onInitGesture(_gesture);
  }

  bool hintTouch(Offset globalOffset) {
    return globalOffset.dx >= globalLeft &&
        globalOffset.dx <= globalLeft + width &&
        globalOffset.dy >= globalTop &&
        globalOffset.dy <= globalTop + height;
  }

  @override
  void onDispose() {
    _gesture.clear();
    context.removeGesture(_gesture);
    super.onDispose();
  }

  Offset _lastHover = Offset.zero;
  Offset _lastDrag = Offset.zero;
  Direction? _dragDirection;
  Offset _lastLongPress = Offset.zero;
  Direction? _lpDirection;

  void onInitGesture(ChartGesture gesture) {
    gesture.clear();
    context.removeGesture(gesture);
    context.addGesture(gesture);
    if (enableClick) {
      gesture.click = (e) {
        if (_enableGesture) {
          onClick(toLocal(e.globalPosition));
        }
      };
    }
    if (enableDoubleClick) {
      gesture.doubleClick = (e) {
        if (_enableGesture) {
          onDoubleClick(toLocal(e.globalPosition));
        }
      };
    }

    if (enableHover) {
      gesture.hoverStart = (e) {
        _lastHover = toLocal(e.globalPosition);
        if (_enableGesture) {
          onHoverStart(_lastHover);
        }
      };
      gesture.hoverMove = (e) {
        Offset of = toLocal(e.globalPosition);
        if (_enableGesture) {
          onHoverMove(of, _lastHover);
        }
        _lastHover = of;
      };
      gesture.hoverEnd = (e) {
        _lastHover = Offset.zero;
        if (_enableGesture) {
          onHoverEnd();
        }
      };
    }

    if (enableLongPress) {
      gesture.longPressStart = (e) {
        _lastLongPress = toLocal(e.globalPosition);
        if (_enableGesture) {
          onLongPressStart(_lastLongPress);
        }
      };
      gesture.longPressMove = (e) {
        var offset = toLocal(e.globalPosition);
        var dx = offset.dx - _lastLongPress.dx;
        var dy = offset.dy - _lastLongPress.dy;
        _lastLongPress = offset;
        if (!freeLongPress) {
          if (_lpDirection == null) {
            if (dx.abs() <= 1e-6) {
              _lpDirection = Direction.vertical;
            } else if (dy.abs() <= 1e-6) {
              _lpDirection = Direction.horizontal;
            } else {
              var angle = atan(dy.abs() / dx.abs());
              if (angle.isNaN) {
                _lpDirection = Direction.horizontal;
              } else {
                _lpDirection = angle.abs() < 30 * pi / 180 ? Direction.horizontal : Direction.vertical;
              }
            }
          }
          if (_lpDirection == Direction.horizontal) {
            dy = 0;
          } else {
            dx = 0;
          }
        }
        if (_enableGesture) {
          onLongPressMove(offset, Offset(dx, dy));
        }
      };
      gesture.longPressEnd = () {
        _lpDirection = null;
        _lastLongPress = Offset.zero;
        if (_enableGesture) {
          onLongPressEnd();
        }
      };
    }

    if (enableDrag) {
      gesture.dragStart = (e) {
        var offset = toLocal(e.globalPosition);
        _lastDrag = offset;
        if (_enableGesture) {
          onDragStart(offset);
        }
      };
      gesture.dragMove = (e) {
        var offset = toLocal(e.globalPosition);
        var dx = offset.dx - _lastDrag.dx;
        var dy = offset.dy - _lastDrag.dy;
        _lastDrag = offset;
        if (!freeDrag) {
          if (_dragDirection == null) {
            if (dx.abs() <= 1e-6) {
              _dragDirection = Direction.vertical;
            } else if (dy.abs() <= 1e-6) {
              _dragDirection = Direction.horizontal;
            } else {
              var angle = atan(dy.abs() / dx.abs());
              if (angle.isNaN) {
                _dragDirection = Direction.horizontal;
              } else {
                _dragDirection = angle.abs() < 30 * pi / 180 ? Direction.horizontal : Direction.vertical;
              }
            }
          }
          if (_dragDirection == Direction.horizontal) {
            dy = 0;
          } else {
            dx = 0;
          }
        }
        if (_enableGesture) {
          onDragMove(offset, Offset(dx, dy));
        }
      };

      gesture.dragEnd = () {
        _dragDirection = null;
        _lastDrag = Offset.zero;
        if (_enableGesture) {
          onDragEnd();
        }
      };
    }

    if (enableScale) {
      gesture.scaleStart = (e) {
        if (_enableGesture) {
          onScaleStart(toLocal(e.globalPosition));
        }
      };
      gesture.scaleUpdate = (e) {
        if (_enableGesture) {
          onScaleUpdate(toLocal(e.focalPoint), e.rotation, e.scale, false);
        }
      };
      gesture.scaleEnd = () {
        if (_enableGesture) {
          onScaleEnd();
        }
      };
    }
  }

  bool get enableClick => true;

  bool get enableDoubleClick => false;

  bool get enableLongPress => false;

  ///是否自由长按
  ///当为false时 拖拽将固定为只能在水平或者竖直方向
  bool get freeLongPress => true;

  bool get enableHover => isDesktop;

  bool get enableDrag => false;

  ///是否自由拖拽
  ///当为false时 拖拽将固定为只能在水平或者竖直方向
  bool get freeDrag => true;

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

  void onDragMove(Offset offset, Offset diff) {
    scrollOff(diff.dx, diff.dy);
  }

  void onDragEnd() {}

  void onScaleStart(Offset offset) {}

  void onScaleUpdate(Offset offset, double rotation, double scale, bool doubleClick) {}

  void onScaleEnd() {}
}
