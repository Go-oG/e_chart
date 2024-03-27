import 'package:flutter/material.dart';

import '../../core/render/ccanvas.dart';
import '../../functions.dart';
import '../../model/index.dart';
import '../symbol/chart_symbol.dart';
import '../../option/legend.dart';
import '../../option/legend_item.dart';

class LegendItemView extends StatefulWidget {
  final LegendItem item;
  final Legend legend;
  final Fun2<LegendItem, bool>? call;

  const LegendItemView({super.key, required this.item, required this.legend, this.call});

  @override
  State<StatefulWidget> createState() => LegendItemState();
}

class LegendItemState extends State<LegendItemView> {
  @override
  Widget build(BuildContext context) {
    var name = widget.item.name;
    var textStyle = widget.item.textStyle;

    List<Widget> wl = [];
    if (name.isString) {
      wl.add(Text(name.text, style: textStyle?.textStyle));
    } else if (name.isTextSpan) {
      wl.add(Text.rich(
        name.text,
        style: textStyle?.textStyle,
      ));
    } else if (name.isParagraph) {
      throw ChartError("unsupport Paragraph");
    }
    double pad = name.isEmpty ? 0 : widget.item.gap.toDouble();

    wl.add(SymbolWidget(symbol: widget.item.symbol));
    var pos = widget.legend.labelPosition;
    if (pos == Position.left || pos == Position.top) {
      wl = List.from(wl.reversed);
      var end = wl.removeLast();
      if (pos == Position.left) {
        end = Padding(
          padding: EdgeInsets.only(left: pad),
          child: end,
        );
      } else {
        end = Padding(
          padding: EdgeInsets.only(top: pad),
          child: end,
        );
      }
      wl.add(end);
    }
    Widget rw;
    if (widget.legend.direction == Direction.vertical) {
      rw = Column(
        key: Key(widget.item.id),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: wl,
      );
    } else {
      rw = Row(
        key: Key(widget.item.id),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: wl,
      );
    }
    var triggerOn = widget.legend.triggerOn;
    if (triggerOn == TriggerOn.none) {
      return rw;
    }

    if (triggerOn == TriggerOn.click || triggerOn == TriggerOn.moveAndClick) {
      Widget w = GestureDetector(
        onTap: () {
          widget.item.selected = !widget.item.selected;
          bool r = widget.call?.call(widget.item) ?? false;
          if (r) {
            setState(() {});
          }
        },
        child: rw,
      );
      if (triggerOn == TriggerOn.moveAndClick) {
        w = MouseRegion(
          onEnter: (event) {
            widget.item.selected = !widget.item.selected;
            widget.call?.call(widget.item);
            setState(() {});
          },
          onExit: (event) {
            widget.item.selected = !widget.item.selected;
            widget.call?.call(widget.item);
            setState(() {});
          },
          opaque: false,
          child: w,
        );
      }
      return w;
    }
    return MouseRegion(
      onEnter: (event) {
        widget.item.selected = !widget.item.selected;
        widget.call?.call(widget.item);
        setState(() {});
      },
      onExit: (event) {
        widget.item.selected = !widget.item.selected;
        widget.call?.call(widget.item);
        setState(() {});
      },
      opaque: false,
      child: rw,
    );
  }
}

class SymbolWidget extends StatelessWidget {
  final ChartSymbol symbol;

  const SymbolWidget({super.key, required this.symbol});

  @override
  Widget build(BuildContext context) {
    Size size = symbol.size;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: CustomPaint(painter: SymbolPainter(symbol)),
    );
  }
}

class SymbolPainter extends CustomPainter {
  final Paint mPaint = Paint();
  ChartSymbol symbol;

  SymbolPainter(this.symbol);

  @override
  void paint(Canvas canvas, Size size) {
    CCanvas cc = CCanvas.fromCanvas(canvas);
    symbol.draw(cc, mPaint, Offset.zero);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
