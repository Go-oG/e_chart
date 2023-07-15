import '../../../functions.dart';
import '../../theme/theme_data.dart';
import '../../../style/area_style.dart';

class SplitArea {
  bool show;
  int interval;
  AreaStyle? style;
  Fun3<int, int, AreaStyle>? splitAreaFun;

  SplitArea({
    this.show = false,
    this.interval = -1,
    this.style,
    this.splitAreaFun,
  });

  AreaStyle? getSplitAreaStyle(int index, int maxIndex, AxisTheme theme) {
    if(!show){
      return null;
    }
    AreaStyle? style;
    if (splitAreaFun != null) {
      style = splitAreaFun?.call(index, maxIndex);
    } else {
      if (this.style != null) {
        style = this.style;
      } else {
        style = theme.getSplitAreaStyle(index);
      }
    }
    return style;
  }

}
