import 'chart_notifier.dart';
import 'command.dart';

abstract class ChartLayout extends ChartNotifier<Command> {
  ChartLayout({bool equalsObject = false}) : super(Command.none, equalsObject);

  void notifyLayoutUpdate() {
    value = Command.layoutUpdate;
  }

  void notifyLayoutEnd() {
    value = Command.layoutEnd;
  }

}
