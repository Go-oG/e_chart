import 'dart:ui';

import 'package:xchart/src/component/tooltip/tool_tip.dart';
import 'package:xchart/src/component/tooltip/tool_tip_item.dart';

abstract class ToolTipListener {
  ToolTip? getToolTip();

  List<ToolTipItem> onCreatedToolTipItem(Offset globalOffset);

  bool toolTipInArea(Offset globalOffset);

}
