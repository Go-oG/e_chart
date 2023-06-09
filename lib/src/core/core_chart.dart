import 'dart:io';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
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
    void Function(LongPressStartDetails)? lps;
    void Function(LongPressMoveUpdateDetails)? lpm;
    void Function(LongPressEndDetails)? lpe;
    VoidCallback? lpc;
    if (config.dragType == DragType.longPress) {
      lps = dispatcher.onLongPressStart;
      lpm = dispatcher.onLongPressMove;
      lpe = dispatcher.onLongPressEnd;
      lpc = dispatcher.onLongPressCancel;
    }
    void Function(TapDownDetails)? dtd;
    VoidCallback? dtc;
    if (config.scaleType == ScaleType.doubleTap) {
      dtd = dispatcher.onDoubleTapDown;
      dtc = dispatcher.onDoubleTapCancel;
    }
    void Function(ScaleStartDetails)? ss;
    void Function(ScaleUpdateDetails)? su;
    void Function(ScaleEndDetails)? se;
    if (config.dragType == DragType.drag || config.scaleType == ScaleType.scale) {
      ss = dispatcher.onScaleStart;
      su = dispatcher.onScaleUpdate;
      se = dispatcher.onScaleEnd;
    }
    MediaQueryData data = MediaQuery.of(context);
    render.context.devicePixelRatio = data.devicePixelRatio;
    Widget ges = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: dispatcher.onTapDown,
      onTapUp: dispatcher.onTapUp,
      onTapCancel: dispatcher.onTapCancel,
      onDoubleTapDown: dtd,
      onDoubleTapCancel: dtc,
      onLongPressStart: lps,
      onLongPressMoveUpdate: lpm,
      onLongPressEnd: lpe,
      onLongPressCancel: lpc,
      onScaleStart: ss,
      onScaleUpdate: su,
      onScaleEnd: se,
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
