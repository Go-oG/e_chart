import 'dart:ui';

import 'tool_tip_item.dart';
import 'tool_tip.dart';

abstract class ToolTipListener {
  ToolTip? getToolTip();

  List<ToolTipItem> onCreatedToolTipItem(Offset globalOffset);

  bool toolTipInArea(Offset globalOffset);

}
