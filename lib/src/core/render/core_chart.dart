import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import '../../component/title/title_view.dart';
import 'render_adapter.dart';

class Chart extends StatefulWidget {
  final ChartOption option;

  const Chart(this.option, {super.key});

  @override
  State<StatefulWidget> createState() => ChartState();
}

class ChartState extends State<Chart> {
  late ChartOption option;

  @override
  void initState() {
    super.initState();
    option = widget.option;
  }

  @override
  void didUpdateWidget(covariant Chart oldWidget) {
    super.didUpdateWidget(oldWidget);
    option = widget.option;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> wl = [];
    var legendWidget = buildLegend(option);
    if (legendWidget != null) {
      wl.add(legendWidget);
    }
    wl.add(Expanded(child: _InnerChart(option)));
    if (wl.length > 1) {
      var legend = option.legend!;
      if (legend.mainAlign == Align2.end) {
        wl = List.from(wl.reversed);
      }
    }

    Widget? title = buildTitle(option);
    if (title != null) {
      var tt = option.title!;
      if (tt.mainAlign == Align2.end) {
        wl.add(title);
      } else {
        wl.insert(0, title);
      }
    }

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: wl,
      ),
    );
  }

  Widget? buildLegend(ChartOption option) {
    Legend? legend = option.legend;
    var data = legend?.data;
    if (legend == null || data == null || data.isEmpty) {
      return null;
    }
    return LegendView(legend: legend);
  }

  Widget? buildTitle(ChartOption option) {
    var title = option.title;
    if (title == null || !title.show) {
      return null;
    }
    return ChildTitleView(title);
  }

  Widget buildContent(ChartOption option) {
    return _InnerChart(option);
  }
}

///==================Content
class _InnerChart extends StatefulWidget {
  final ChartOption option;

  const _InnerChart(this.option, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _InnerChartState();
  }
}

class _InnerChartState extends State<_InnerChart> with TickerProviderStateMixin {
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
    return RenderAdapter(option, tickerProvider, size);
  }

  @override
  void updateRenderObject(BuildContext context, RenderAdapter renderObject) {
    renderObject.onUpdateRender(option, size, tickerProvider);
  }

  @override
  void didUnmountRenderObject(RenderAdapter renderObject) {
   // renderObject.onUnmountRender();
  }

}
