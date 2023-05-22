import 'dart:ui';

import 'context_menu.dart';
import 'tool_tip.dart';

abstract class ToolTipBuilder {

  Offset onMenuPosition();

  ContextMenu? onCreatedContextMenu();

}
