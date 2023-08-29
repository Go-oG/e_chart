import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart' as x;
import '../utils/platform_util.dart';
import 'render/base_render.dart';
import 'render/default_render.dart';

class Chart extends StatefulWidget {
  final ChartOption option;

  const Chart(this.option, {Key? key}) : super(key: key);

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
      _render = DefaultRender(widget.option, this);
      _render?.onStart();
    } else {
      var oldConfig = _render!.context.option;
      if (oldConfig == widget.option) {
        _render!.onStop();
        _render!.context.tickerProvider = this;
        _render!.onStart();
      } else {
        ///先销毁旧的再创建
        _render!.onStop();
        _render!.dispose();
        _render = DefaultRender(widget.option, this);
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
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: _buildPainter(widget.option),
    );
  }

  Widget _buildPainter(ChartOption config) {
    GestureDispatcher dispatcher = render.context.gestureDispatcher;

    ///LongPress
    void Function(TapEvent)? lps = dispatcher.onLongPressStart;
    void Function(MoveEvent)? lpm = dispatcher.onLongPressMove;
    VoidCallback? lpe = dispatcher.onLongPressEnd;

    ///Move
    void Function(MoveEvent)? moveStart = dispatcher.onMoveStart;
    void Function(MoveEvent)? moveEnd = dispatcher.onMoveEnd;
    void Function(MoveEvent)? moveUpdate = dispatcher.onMoveUpdate;

    ///doubleTap
    void Function(TapEvent)? dt = dispatcher.onDoubleTap;

    ///Scale
    void Function(Offset)? scaleStart = dispatcher.onScaleStart;
    void Function(x.ScaleEvent)? scaleUpdate = dispatcher.onScaleUpdate;
    VoidCallback? scaleEnd = dispatcher.onScaleEnd;

    MediaQueryData data = MediaQuery.of(context);
    render.context.devicePixelRatio = data.devicePixelRatio;
    Widget ges = XGestureDetector(
      behavior: HitTestBehavior.translucent,
      bypassMoveEventAfterLongPress: true,
      doubleTapTimeConsider: widget.option.doubleClickInterval,
      longPressTimeConsider: widget.option.longPressTime,
      onTap: dispatcher.onTap,
      onDoubleTap: dt,
      onLongPress: lps,
      onLongPressMove: lpm,
      onLongPressEnd: lpe,

      onMoveStart: moveStart,
      onMoveUpdate: moveUpdate,
      onMoveEnd: moveEnd,

      onScaleStart: scaleStart,
      onScaleUpdate: scaleUpdate,
      onScaleEnd: scaleEnd,

      // onScrollEvent: ,

      child: CustomPaint(
        painter: render,
        child: Container(),
      ),
    );

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
