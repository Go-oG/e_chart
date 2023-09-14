import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/core/render/chart_render.dart';
import 'package:flutter/material.dart';
import 'default_render.dart';
import 'render_adapter.dart';

class Chart extends StatefulWidget {
  final ChartOption option;

  const Chart(this.option, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChartState();
  }
}

class ChartState extends State<Chart> with TickerProviderStateMixin {
  ChartRender? render;

  @override
  void initState() {
    super.initState();
    render = DefaultRender(widget.option, this, 1);
  }

  @override
  void didUpdateWidget(covariant Chart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.option != widget.option) {
      render?.onStop();
      render?.dispose();
      render = DefaultRender(widget.option, this, 1);
    }
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
    var devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    render?.context.devicePixelRatio = devicePixelRatio;
    return _InnerWidget(render!, null);
  }
}

class _InnerWidget extends LeafRenderObjectWidget {
  final ChartRender render;
  final Size? size;

  const _InnerWidget(this.render, this.size, {super.key});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAdapter(render, size);
  }

  @override
  void updateRenderObject(BuildContext context, RenderAdapter renderObject) {
    renderObject.render = render;
  }

  @override
  void didUnmountRenderObject(RenderAdapter renderObject) {
    renderObject.render = null;
  }
}
