
import 'package:flutter/material.dart';

import '../../core/view.dart';
import '../../model/enums/position.dart';
import 'legend.dart';
import 'legend_item.dart';

class LegendNode extends View {
  Legend? _legend;
  final List<LegendItemNode> _nodeList = [];

  LegendNode() {
    _init();
  }

  void _init() {
    _nodeList.clear();
    if (_legend == null) {
      return;
    }
    for (var element in _legend!.itemList) {
      _nodeList.add(LegendItemNode(element));
    }
  }

  set legend(Legend legend) {
    _legend = legend;
    _init();
  }

  void reset() {
    _legend = null;
  }

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    double width = 0;
    double height = 0;
    // for (var element in _nodeList) {
    //   element.measure(align);
    //   if (direction == Direction.vertical) {
    //     width += element.rect.width + itemMargin;
    //     height = max(height, element.rect.height);
    //   } else {
    //     height += element.rect.height + itemMargin;
    //     width = max(width, element.rect.width);
    //   }
    // }
    return Size(width, height);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
  }
//
// List<LegendItemNode> layout(double width, double height, Direction direction, double itemMargin) {
//   double topOffset = 0;
//   double leftOffset = 0;
//   List<LegendItemNode> nl = [];
//   double resumeW = 0;
//   double resumeH = 0;
//   List<LegendItemNode> nodeList = [..._nodeList];
//   while (nodeList.isNotEmpty) {
//     var ele = nodeList.removeAt(0);
//     if (direction == Direction.horizontal) {
//       if (resumeW + ele.rect.width > width) {
//         nl.clear();
//         resumeW = 0;
//         topOffset += resumeH;
//         leftOffset = 0;
//       } else {
//         ele.layout(leftOffset, topOffset, leftOffset + ele.rect.width, topOffset + ele.rect.height);
//         nl.add(ele);
//         leftOffset = ele.rect.right;
//         leftOffset += itemMargin;
//         resumeW += ele.rect.width + itemMargin;
//         resumeH = max(resumeH, ele.rect.height);
//       }
//     } else {
//       if (resumeH + ele.rect.height > height) {
//         nl.clear();
//         topOffset = 0;
//         leftOffset += resumeW;
//         resumeW = 0;
//         resumeH = 0;
//       } else {
//         ele.layout(leftOffset, topOffset, leftOffset + ele.rect.width, topOffset + ele.rect.height);
//         nl.add(ele);
//         topOffset += itemMargin + ele.rect.height;
//         resumeH += ele.rect.height + itemMargin;
//         resumeW = max(resumeW, ele.rect.width);
//       }
//     }
//   }
//   return _nodeList;
// }
}

class LegendItemNode {
  final LegendItem legend;
  Rect rect = Rect.zero;

  LegendItemNode(this.legend);

  void measure(Position position) {
    // double width = legend.symbolSize.width;
    // double height = legend.symbolSize.height;

    // TextPainter painter = legend.labelStyle.textStyle.toPainter(legend.name);
    // painter.layout();
    // double textHeight = painter.height;
    // double textWidth = painter.width;
    // if (position == Position.left || position == Position.right) {
    //   width += textWidth + legend.margin;
    // } else {
    //   height += textHeight + legend.margin;
    // }
    // rect = Rect.fromLTWH(0, 0, width, height);
  }

  void layout(double left, double top, double right, double bottom) {
    rect = Rect.fromLTRB(left, top, right, bottom);
  }
}
