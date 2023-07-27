import '../line_node.dart';

abstract class LineHelper {
  List<LineNode> getLineNodeList();

  double getAnimatorPercent();
}