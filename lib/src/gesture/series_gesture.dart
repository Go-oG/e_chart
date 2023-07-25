import '../core/series.dart';
import '../core/view.dart';
import '../functions.dart';
import 'chart_gesture.dart';
import 'gesture_event.dart';

///用于给 ChartSeries 拓展事件处理
mixin SeriesGesture on ChartSeries {
  VoidFun2<ChartView, NormalEvent>? click;

  VoidFun2<ChartView, NormalEvent>? doubleClick;

  VoidFun2<ChartView, NormalEvent>? longPressStart;
  VoidFun2<ChartView, LongPressMoveEvent>? longPressMove;
  VoidFun1<ChartView>? longPressEnd;

  VoidFun2<ChartView, NormalEvent>? hoverStart;
  VoidFun2<ChartView, NormalEvent>? hoverMove;
  VoidFun2<ChartView, NormalEvent>? hoverEnd;

  VoidFun2<ChartView, NormalEvent>? dragStart;
  VoidFun2<ChartView, NormalEvent>? dragMove;
  VoidFun1<ChartView>? dragEnd;

  VoidFun2<ChartView, NormalEvent>? scaleStart;
  VoidFun2<ChartView, ScaleEvent>? scaleUpdate;
  VoidFun1<ChartView>? scaleEnd;

  bool bindGesture(ChartView view, ChartGesture gesture) {
    bool needBind = false;
    if (click != null) {
      needBind = true;
      gesture.click = (e) {
        click!.call(view, e);
      };
    }
    if (doubleClick != null) {
      needBind = true;
      gesture.doubleClick = (e) {
        doubleClick!.call(view, e);
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
      gesture.longPressEnd = () {
        longPressEnd!.call(view);
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

    if (dragStart != null) {
      needBind = true;
      gesture.dragStart = (e) {
        dragStart!.call(view, e);
      };
    }
    if (dragMove != null) {
      needBind = true;
      gesture.dragMove = (e) {
        dragMove!.call(view, e);
      };
    }
    if (dragEnd != null) {
      needBind = true;
      gesture.dragEnd = () {
        dragEnd!.call(view);
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
      gesture.scaleEnd = () {
        scaleEnd!.call(view);
      };
    }
    return needBind;
  }

  void clearGesture() {
    click = null;

    doubleClick = null;

    longPressStart = null;
    longPressMove = null;
    longPressEnd = null;

    hoverStart = null;
    hoverMove = null;
    hoverEnd = null;
    dragStart = null;
    dragEnd = null;
    dragMove = null;

    scaleStart = null;
    scaleUpdate = null;
    scaleEnd = null;
  }

  bool enableSeriesGesture = true;
}
