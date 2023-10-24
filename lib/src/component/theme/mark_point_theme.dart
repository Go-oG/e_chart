import 'package:e_chart/e_chart.dart';

class MarkPointTheme extends Disposable {
  LabelStyle labelStyle = const LabelStyle();
  LabelStyle labelHoverStyle = const LabelStyle();

  @override
  void dispose() {
    labelStyle = LabelStyle.empty;
    labelHoverStyle = LabelStyle.empty;
    super.dispose();
  }
}
