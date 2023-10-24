import 'package:e_chart/e_chart.dart';


///其它通用配置
class TooltipTheme extends Disposable{
  AreaStyle style = const AreaStyle();

  @override
  void dispose() {
    style=AreaStyle.empty;
    super.dispose();
  }
}