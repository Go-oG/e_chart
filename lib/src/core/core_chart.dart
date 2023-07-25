import 'dart:io';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart' as x;
import 'render/base_render.dart';
import 'render/default_render.dart';

class Chart extends StatefulWidget {
  final ChartConfig config;

  const Chart(this.config, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChartState();
  }
}

class ChartState extends State<Chart> with TickerProviderStateMixin {
  BaseRender? _render;

  BaseRender get render => _render!;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    if (_render == null) {
      _render = DefaultRender(widget.config, this);
      _render?.onStart();
    } else {
      var oldConfig = _render!.context.config;
      if (oldConfig == widget.config) {
        _render!.onStop();
        _render!.context.tickerProvider = this;
        _render!.onStart();
      } else {
        ///先销毁旧的再创建
        _render!.onStop();
        _render!.dispose();
        _render = DefaultRender(widget.config, this);
        _render?.onStart();
      }
    }
  }

  @override
  void didUpdateWidget(Chart oldWidget) {
    super.didUpdateWidget(oldWidget);
    init();
  }

  @override
  void dispose() {
    render.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ChartConfig config = widget.config;
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: _buildPainter(config),
    );
  }

  Widget _buildPainter(ChartConfig config) {
    GestureDispatcher dispatcher = render.context.gestureDispatcher;

    void Function(TapEvent)? lps;
    void Function(MoveEvent)? lpm;
    VoidCallback? lpe;
    if (config.dragType == DragType.longPress) {
      lps = dispatcher.onLongPressStart;
      lpm = dispatcher.onLongPressMove;
      lpe=dispatcher.onLongPressEnd;
    }

    void Function(MoveEvent)? moveStart;
    void Function(MoveEvent)? moveEnd;
    void Function(MoveEvent)? moveUpdate;
    if (config.dragType == DragType.drag) {
      moveStart=dispatcher.onMoveStart;
      moveUpdate=dispatcher.onMoveUpdate;
      moveEnd=dispatcher.onMoveEnd;
    }

    ///doubleTap
    void Function(TapEvent)? dt;
    if (config.scaleType == ScaleType.doubleTap) {
      dt = dispatcher.onDoubleTap;
    }
    void Function(Offset)? scaleStart;
    void Function(x.ScaleEvent)? scaleUpdate;
    VoidCallback? scaleEnd;
    if(config.scaleType==ScaleType.scale){
      scaleStart=dispatcher.onScaleStart;
      scaleUpdate=dispatcher.onScaleUpdate;
      scaleEnd=dispatcher.onScaleEnd;
    }

    MediaQueryData data = MediaQuery.of(context);
    render.context.devicePixelRatio = data.devicePixelRatio;
    Widget ges = XGestureDetector(
      behavior: HitTestBehavior.translucent,
      bypassMoveEventAfterLongPress: lps!=null,
      doubleTapTimeConsider: 280,
      longPressTimeConsider: 300,
      onTap: dispatcher.onTap,
      onDoubleTap: dt,
      onLongPress: lps,
      onLongPressMove:lpm ,
      onLongPressEnd: lpe,

      onMoveStart: moveStart,
      onMoveUpdate: moveUpdate,
      onMoveEnd: moveEnd,

      onScaleStart:scaleStart ,
      onScaleUpdate:scaleUpdate ,
      onScaleEnd:scaleEnd,

      // onScrollEvent: ,

      child: CustomPaint(
        painter: render,
        child: Container(),
      ),
    );

    bool isPhone = Platform.isIOS || Platform.isAndroid;

    if (isPhone) {
      return ges;
    }
    return MouseRegion(
      onEnter: dispatcher.onHoverStart,
      onExit: dispatcher.onHoverEnd,
      onHover: dispatcher.onHoverMove,
      opaque: false,
      child: ges,
    );
  }
}
