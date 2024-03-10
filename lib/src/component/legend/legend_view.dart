import 'package:flutter/material.dart';

import '../../core/index.dart';
import '../../model/index.dart';
import 'legend.dart';
import 'legend_item.dart';

class LegendView extends StatefulWidget {
  final Legend legend;

  const LegendView({super.key, required this.legend});

  @override
  State<StatefulWidget> createState() => LegendViewState();
}

class LegendViewState extends State<LegendView> {
  Legend? legend;

  @override
  void initState() {
    super.initState();
    initLegend(widget.legend);
  }

  @override
  void didUpdateWidget(covariant LegendView oldWidget) {
    super.didUpdateWidget(oldWidget);
    initLegend(widget.legend);
  }

  void initLegend(Legend legend) {
    this.legend?.clearListener();
    this.legend = legend;
    legend.addListener(() {
      var v = legend.value;
      var data = legend.data;
      if (data == null || data.isEmpty) {
        return;
      }
      if (v == Command.inverseSelectLegend) {
        setState(() {
          for (var legend in data) {
            legend.selected = !legend.selected;
          }
        });
      } else if (v == Command.selectAllLegend || v == Command.unselectLegend) {
        int c = 0;
        bool se = v == Command.selectAllLegend;
        for (var item in data) {
          if (!item.selected && se) {
            item.selected = true;
            c++;
          } else if (item.selected && !se) {
            item.selected = false;
            c++;
          }
        }
        if (c > 0) {
          setState(() {});
        }
      } else if (v.code == Command.legendItemChangeCode) {
        LegendItem? legendItem = v.data['legendItem'];
        handleLegendItemChange(legendItem);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var legend = this.legend;
    var data = legend?.data;
    if (legend == null || data == null || data.isEmpty) {
      return const SizedBox(width: 0, height: 0);
    }
    List<Widget> itemList = [];
    var dir = legend.direction == Direction.vertical ? Direction.horizontal : Direction.vertical;
    for (var s in data) {
      Widget w = s.toWidget(dir, legend, (item) {
        handleLegendItemChange(item);
        return false;
      });
      itemList.add(w);
    }
    Widget rw;
    if (legend.direction == Direction.vertical) {
      if (legend.scroll) {
        rw = SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: itemList,
          ),
        );
      } else {
        rw = Wrap(
          direction: Axis.vertical,
          spacing: legend.hGap,
          runSpacing: legend.vGap,
          alignment: legend.hAlign,
          runAlignment: legend.vAlign,
          children: itemList,
        );
      }
    } else {
      if (legend.scroll) {
        rw = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: itemList,
          ),
        );
      } else {
        rw = Wrap(
          direction: Axis.horizontal,
          spacing: legend.vGap,
          runSpacing: legend.hGap,
          alignment: legend.vAlign,
          runAlignment: legend.hAlign,
          children: itemList,
        );
      }
    }
    return Container(
      padding: legend.padding,
      decoration: legend.decoration,
      child: rw,
    );
  }

  void handleLegendItemChange(LegendItem? legendItem) {
    var legend = this.legend;
    var data = legend?.data;
    if (legend == null || data == null) {
      return;
    }
    if (!legend.allowSelectMulti && legendItem != null && legendItem.selected) {
      for (var item in data) {
        if (item != legendItem) {
          item.selected = false;
        }
      }
      setState(() {});
    }
  }
}
