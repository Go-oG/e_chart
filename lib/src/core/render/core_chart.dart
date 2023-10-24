
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: _InnerWidget(widget.option, this, null),
    );
  }
}

class _InnerWidget extends LeafRenderObjectWidget {
  final ChartOption option;
  final Size? size;

  final TickerProvider tickerProvider;

  const _InnerWidget(this.option, this.tickerProvider, this.size);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAdapter(option,size,tickerProvider);
  }

  @override
  void updateRenderObject(BuildContext context, RenderAdapter renderObject) {
    renderObject.onUpdateRender(option, size, tickerProvider);
  }

  @override
  void didUnmountRenderObject(RenderAdapter renderObject) {
    renderObject.onUnmountRender();
  }
}
