import '../core/series.dart';
import '../core/view.dart';
import '../functions.dart';
import 'chart_gesture.dart';
import 'gesture_event.dart';

///用于给 ChartSeries 拓展事件处理
mixin SeriesGesture on ChartSeries {
  VoidFun2<ChartView, NormalEvent>? click;
  VoidFun2<ChartView, NormalEvent>? clickDown;
  VoidFun2<ChartView, NormalEvent>? clickUp;
  VoidFun1<ChartView>? clickCancel;

  VoidFun2<ChartView, NormalEvent>? doubleClick;
  VoidFun2<ChartView, NormalEvent>? doubleClickDown;
  VoidFun2<ChartView, NormalEvent>? doubleClickUp;
  VoidFun1<ChartView>? doubleClickCancel;

  VoidFun2<ChartView, NormalEvent>? longPressStart;
  VoidFun2<ChartView, LongPressMoveEvent>? longPressMove;
  VoidFun2<ChartView, NormalEvent>? longPressEnd;
  VoidFun1<ChartView>? longPressCancel;

  VoidFun2<ChartView, NormalEvent>? hoverStart;
  VoidFun2<ChartView, NormalEvent>? hoverMove;
  VoidFun2<ChartView, NormalEvent>? hoverEnd;

  VoidFun2<ChartView, NormalEvent>? verticalDragStart;
  VoidFun2<ChartView, NormalEvent>? verticalDragMove;
  VoidFun2<ChartView, VelocityEvent>? verticalDragEnd;
  VoidFun1<ChartView>? verticalDragCancel;

  VoidFun2<ChartView, NormalEvent>? horizontalDragStart;
  VoidFun2<ChartView, NormalEvent>? horizontalDragMove;
  VoidFun2<ChartView, VelocityEvent>? horizontalDragEnd;
  VoidFun1<ChartView>? horizontalDragCancel;

  VoidFun2<ChartView, NormalEvent>? scaleStart;
  VoidFun2<ChartView, ScaleEvent>? scaleUpdate;
  VoidFun2<ChartView, VelocityEvent>? scaleEnd;
  VoidFun1<ChartView>? scaleCancel;

  bool bindGesture(ChartView view, ChartGesture gesture) {
    bool needBind = false;
    if (click != null) {
      needBind = true;
      gesture.click = (e) {
        click!.call(view, e);
      };
    }
    if (clickDown != null) {
      needBind = true;
      gesture.clickDown = (e) {
        clickDown!.call(view, e);
      };
    }
    if (clickUp != null) {
      needBind = true;
      gesture.clickUp = (e) {
        clickUp!.call(view, e);
      };
    }
    if (clickCancel != null) {
      needBind = true;
      gesture.clickCancel = () {
        clickCancel!.call(view);
      };
    }
    if (doubleClick != null) {
      needBind = true;
      gesture.doubleClick = (e) {
        doubleClick!.call(view, e);
      };
    }
    if (doubleClickDown != null) {
      needBind = true;
      gesture.doubleClickDown = (e) {
        doubleClickDown!.call(view, e);
      };
    }
    if (doubleClickUp != null) {
      needBind = true;
      gesture.doubleClickUp = (e) {
        doubleClickUp!.call(view, e);
      };
    }
    if (doubleClickCancel != null) {
      needBind = true;
      gesture.doubleClickCancel = () {
        doubleClickCancel!.call(view);
      };
    }
    if (longPressStart != null) {
      needBind = true;
      gesture.longPressStart = (e) {
        longPressStart!.call(view, e);
      };
    }
    if (longPressMove != null) {
      needBind = true;
      gesture.longPressMove = (e) {
        longPressMove!.call(view, e);
      };
    }
    if (longPressEnd != null) {
      needBind = true;
      gesture.longPressEnd = (e) {
        longPressEnd!.call(view, e);
      };
    }
    if (longPressCancel != null) {
      needBind = true;
      gesture.longPressCancel = () {
        longPressCancel!.call(view);
      };
    }
    if (hoverStart != null) {
      needBind = true;
      gesture.hoverStart = (e) {
        hoverStart!.call(view, e);
      };
    }
    if (hoverMove != null) {
      needBind = true;
      gesture.hoverMove = (e) {
        hoverMove!.call(view, e);
      };
    }
    if (hoverEnd != null) {
      needBind = true;
      gesture.hoverEnd = (e) {
        hoverEnd!.call(view, e);
      };
    }
    if (verticalDragStart != null) {
      needBind = true;
      gesture.verticalDragStart = (e) {
        verticalDragStart!.call(view, e);
      };
    }
    if (verticalDragMove != null) {
      needBind = true;
      gesture.verticalDragMove = (e) {
        verticalDragMove!.call(view, e);
      };
    }
    if (verticalDragEnd != null) {
      needBind = true;
      gesture.verticalDragEnd = (e) {
        verticalDragEnd!.call(view, e);
      };
    }
    if (verticalDragCancel != null) {
      needBind = true;
      gesture.verticalDragCancel = () {
        verticalDragCancel!.call(view);
      };
    }
    if (horizontalDragStart != null) {
      needBind = true;
      gesture.horizontalDragStart = (e) {
        horizontalDragStart!.call(view, e);
      };
    }
    if (horizontalDragMove != null) {
      needBind = true;
      gesture.horizontalDragMove = (e) {
        horizontalDragMove!.call(view, e);
      };
    }
    if (horizontalDragEnd != null) {
      needBind = true;
      gesture.horizontalDragEnd = (e) {
        horizontalDragEnd!.call(view, e);
      };
    }
    if (horizontalDragCancel != null) {
      needBind = true;
      gesture.horizontalDragCancel = () {
        horizontalDragCancel!.call(view);
      };
    }
    if (scaleStart != null) {
      needBind = true;
      gesture.scaleStart = (e) {
        scaleStart!.call(view, e);
      };
    }
    if (scaleUpdate != null) {
      needBind = true;
      gesture.scaleUpdate = (e) {
        scaleUpdate!.call(view, e);
      };
    }
    if (scaleEnd != null) {
      needBind = true;
      gesture.scaleEnd = (e) {
        scaleEnd!.call(view, e);
      };
    }
    if (scaleCancel != null) {
      needBind = true;
      gesture.scaleCancel = () {
        scaleCancel!.call(view);
      };
    }
    return needBind;
  }

  void clearGesture() {
    click = null;
    clickDown = null;
    clickUp = null;
    clickCancel = null;

    doubleClick = null;
    doubleClickDown = null;
    doubleClickUp = null;
    doubleClickCancel = null;

    longPressStart = null;
    longPressMove = null;
    longPressEnd = null;
    longPressCancel = null;

    hoverStart = null;
    hoverMove = null;
    hoverEnd = null;

    verticalDragStart = null;
    verticalDragMove = null;
    verticalDragEnd = null;
    verticalDragCancel = null;

    horizontalDragStart = null;
    horizontalDragMove = null;
    horizontalDragEnd = null;
    horizontalDragCancel = null;

    scaleStart = null;
    scaleUpdate = null;
    scaleEnd = null;
    scaleCancel = null;
  }

  bool enableSeriesGesture=true;


}
