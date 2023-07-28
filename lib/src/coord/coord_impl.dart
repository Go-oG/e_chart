import 'dart:ui';

import 'package:e_chart/e_chart.dart';

abstract class CoordLayout<T extends Coord> extends ChartViewGroup {
  final T props;

  double scaleXFactor = 1;
  double scaleYFactor = 1;
  double scrollXOffset = 0;
  double scrollYOffset = 0;

  ///存储内容的边界
  Rect contentBox = Rect.zero;

  CoordLayout(this.props);

  final RectGesture _gesture = RectGesture();

  @override
  void onCreate() {
    super.onCreate();
    _initGesture();
  }

  @override
  void onStart() {
    super.onStart();
    registerCommandHandler();
    props.addListener(_handleCommand);
  }

  void _handleCommand() {
    onReceiveCommand(props.value);
  }

  @override
  void onStop() {
    props.removeListener(_handleCommand);
    unregisterCommandHandler();
    super.onStop();
  }

  @override
  void onUpdateDataCommand(covariant Command c) {
    forceLayout = true;
    layout(left, top, right, bottom);
  }

  @override
  void onLayoutEnd() {
    super.onLayoutEnd();
    _gesture.rect = globalBoxBound;
  }

  @override
  void onDrawBackground(Canvas canvas) {
    Color? color = props.backgroundColor;
    if (color == null) {
      return;
    }
    mPaint.reset();
    mPaint.color = color;
    mPaint.style = PaintingStyle.fill;
    canvas.drawRect(selfBoxBound, mPaint);
  }

  Offset _lastHover = Offset.zero;

  Offset _lastDrag = Offset.zero;

  void _initGesture() {
    _gesture.clear();
    context.removeGesture(_gesture);
    context.addGesture(_gesture);

    if (enableClick) {
      _gesture.click = (e) {
        onClick(toLocalOffset(e.globalPosition));
      };
    }
    if (enableHover) {
      _gesture.hoverStart = (e) {
        _lastHover = toLocalOffset(e.globalPosition);
        onHoverStart(_lastHover);
      };
      _gesture.hoverMove = (e) {
        Offset of = toLocalOffset(e.globalPosition);
        onHoverMove(of, _lastHover);
        _lastHover = of;
      };
      _gesture.hoverEnd = (e) {
        _lastHover = Offset.zero;
        onHoverEnd();
      };
    }
    if (enableDrag) {
      dragStart(Offset offset) {
        _lastDrag = offset;
        onDragStart(offset);
      }

      dragMove(Offset offset) {
        var dx = offset.dx - _lastDrag.dx;
        var dy = offset.dy - _lastDrag.dy;
        _lastDrag = offset;
        onDragMove(offset, Offset(dx, dy));
      }

      dragCancel() {
        _lastDrag = Offset.zero;
        onDragEnd();
      }

      if (context.config.dragType == DragType.longPress) {
        _gesture.longPressStart = (e) {
          dragStart(toLocalOffset(e.globalPosition));
        };
        _gesture.longPressMove = (e) {
          dragMove(toLocalOffset(e.globalPosition));
        };
        _gesture.longPressEnd = () {
          dragCancel();
        };
      } else {
        _gesture.dragStart = (e) {
          dragStart(toLocalOffset(e.globalPosition));
        };
        _gesture.dragMove = (e) {
          dragMove(toLocalOffset(e.globalPosition));
        };
        _gesture.dragEnd = () {
          dragCancel();
        };
      }
    }
    if (enableScale) {
      if (context.config.scaleType == ScaleType.doubleTap) {
        _gesture.doubleClick = (e) {
          onScaleStart(toLocalOffset(e.globalPosition));
          onScaleUpdate(toLocalOffset(e.globalPosition), 0, 0.25, true);
        };
      } else {
        _gesture.scaleStart = (e) {
          onScaleStart(toLocalOffset(e.globalPosition));
        };
        _gesture.scaleUpdate = (e) {
          onScaleUpdate(toLocalOffset(e.focalPoint), e.rotation, e.scale, false);
        };
        _gesture.scaleEnd = () {
          onScaleEnd();
        };
      }
    }
  }

  bool get enableHover => props.enableHover;

  bool get enableDrag => props.enableDrag;

  bool get enableClick => props.enableClick;

  bool get enableScale => props.enableScale;

  void onClick(Offset offset) {}

  void onHoverStart(Offset offset) {}

  void onHoverMove(Offset offset, Offset last) {}

  void onHoverEnd() {}

  void onDragStart(Offset offset) {}

  void onDragMove(Offset offset, Offset diff) {}

  void onDragEnd() {}

  void onScaleStart(Offset offset) {}

  void onScaleUpdate(Offset offset, double rotation, double scale, bool doubleClick) {}

  void onScaleEnd() {}

  Offset getScaleFactor() {
    return Offset(scaleXFactor, scaleYFactor);
  }

  Offset getTranslation() {
    return Offset(scrollXOffset, scrollYOffset);
  }

  ///获取最大能够平移的值
  Offset getMaxTranslation() {
    return Offset.zero;
  }
}
