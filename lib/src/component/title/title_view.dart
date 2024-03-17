import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import '../../core/view/models.dart';

class ChildTitleView extends StatelessWidget {
  final ChartTitle title;

  const ChildTitleView(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    if (!title.show) {
      return const SizedBox(
        width: 0,
        height: 0,
      );
    }
    List<Widget> wl = [];
    if (title.text.isNotEmpty) {
      wl.add(Text(title.text, style: title.textStyle.textStyle));
    }

    if (title.subText.isNotEmpty) {
      wl.add(Text(title.subText, style: title.subTextStyle.textStyle));
    }

    return Container(
      decoration: title.decoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: wl,
      ),
    );
  }

}

class TitleView extends ChartView {
  DynamicText title;
  LabelStyle style;

  late TextDraw label;

  TitleView(super.context,this.title, this.style) {
    label = TextDraw(title, style, Offset.zero, align: Alignment.topLeft);
  }

  @override
  Size onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec) {
    if (title.isEmpty) {
      return Size.zero;
    }
    Size size = title.getTextSize(style.textStyle);
    return size;
  }

  @override
  void onDraw(CCanvas canvas) {
    label.draw(canvas, mPaint);
  }

  @override
  void onDispose() {
    title = DynamicText.empty;
    style = LabelStyle.empty;
    label = TextDraw.empty;
    super.onDispose();
  }
}
