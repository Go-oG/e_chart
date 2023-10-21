import 'dart:ui';

import 'package:e_chart/e_chart.dart';

/// 不可再分的最小绘制单元
/// 其用于极坐标系和二维坐标系下的节点位置表示
class StackData<T extends StackItemData, P extends StackGroupData<T, P>> extends RenderData<StackAttr<T, P>> {
  T? value;

  StackData(this.value, {super.id, super.name}) : super.attr(StackAttr()) {
    if (value != null) {
      label.text = value!.name ?? DynamicText.empty;
    }
  }

  @override
  bool contains(Offset offset) {
    if (attr.coord == CoordType.polar) {
      return attr.arc.contains(offset);
    }
    return attr.rect.contains2(offset);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    if (attr.coord == CoordType.grid) {
      itemStyle.drawRect(canvas, paint, rect, attr.corner);
      borderStyle.drawRect(canvas, paint, rect, attr.corner);
      return;
    }
    itemStyle.drawPath(canvas, paint, arc.toPath());
    borderStyle.drawPath(canvas, paint, arc.toPath(), drawDash: true, needSplit: false);
  }

  void onDrawText(CCanvas canvas, Paint paint) {
    if (dataIsNull) {
      return;
    }
    label.draw(canvas, paint);
  }

  @override
  void updateStyle(Context context, covariant StackSeries<T, P> series) {
    attr.corner = series.getCorner(this);
    itemStyle = series.getAreaStyle(context, this, attr.parent);
    borderStyle = series.getLineStyle(context, this, attr.parent);
    var s = series.getLabelStyle(context, this);
    label.updatePainter(style: s);
  }

  @override
  void updateLabelPosition(Context context, covariant StackSeries<T, P> series) {
    var align = series.getLabelAlign(context, this);
    if (attr.coord == CoordType.polar) {
      align.fill2(label, arc, label.style, series.direction);
    } else {
      align.fill(label, rect, label.style, series.direction);
    }
    label.updatePainter(text: formatData(series, attr.dynamicLabel ?? attr.up));
  }

  DynamicText formatData(StackSeries<T, P> series, dynamic data) {
    if (data == null) {
      return DynamicText.empty;
    }
    if (data is DynamicText) {
      return data;
    }
    var fun = series.labelFormatFun;
    if (fun != null) {
      return fun.call(data, attr.parent) ?? DynamicText.empty;
    }
    if (data is String) {
      return DynamicText(data);
    }
    if (data is DateTime) {
      return data.toString().toText();
    }
    if (data is num) {
      return DynamicText.fromString(formatNumber(data, 2));
    }
    return data.toString().toText();
  }

  T get data => value!;

  T? get dataNull => value;

  bool get dataIsNull => dataNull == null;

  bool get dataIsNotNull => dataNull != null;

  P get parent => attr.parent;

  ColumnNode<T, P> get parentNode => attr.parentNode;

  Arc get arc => attr.arc;

  set arc(Arc a) => attr.arc = a;

  Rect get rect => attr.rect;

  set rect(Rect r) => attr.rect = r;

  Offset get position => attr.position;

  set position(Offset o) => attr.position = o;

  num get up => attr.up;

  num get down => attr.down;
}

class StackAttr<T extends StackItemData, P extends StackGroupData<T, P>> {
  ///只在二维坐标系下使用
  Rect rect = Rect.zero;
  Corner? corner;

  ///只在极坐标系下使用
  Arc arc = Arc.zero;

  ///通用的节点位置，一般只有折线图和散点图使用
  Offset position = Offset.zero;

  ///动态数据标签(一般使用在动态排序中)
  dynamic dynamicLabel;

  late CoordType coord;
  late ColumnNode<T, P> parentNode;
  late P parent;

  ///标识是否是一个堆叠数据
  late bool stack;

  ///记录数据的上界和下界
  num up = 0;

  num down = 0;
}

class StackGroupData<T extends StackItemData, P extends StackGroupData<T, P>> {
  late final String id;
  late final String name;
  int styleIndex = 0;
  List<StackData<T, P>> data;
  int xAxisIndex;
  int yAxisIndex;

  String? stackId;
  bool stackUsePercent;

  SNumber? barSize;
  SNumber? barMaxSize;
  SNumber? barMinSize;

  StackGroupData(
    this.data, {
    this.xAxisIndex = 0,
    this.yAxisIndex = 0,
    this.barSize,
    this.barMaxSize,
    this.barMinSize = const SNumber(1, false),
    String? id,
    String? name,
    this.stackId,
    this.stackUsePercent = false,
    this.styleIndex = 0,
  }) {
    if (id == null || id.isEmpty) {
      this.id = randomId();
    } else {
      this.id = id;
    }
    this.name = name ?? '';
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is StackGroupData && other.id == id;
  }

  bool get isStack {
    return stackId != null && stackId!.isNotEmpty;
  }

  bool get isNotStack {
    return !isStack;
  }
}

class StackItemData extends BaseItemData {
  dynamic x;
  dynamic y;

  StackItemData(this.x, this.y, {super.id, super.name}) {
    checkDataType(x);
    checkDataType(y);
    if (x is! num && y is! num) {
      throw ChartError('x 和 y 必须有一个是num类型的数据');
    }
    if (x == null || y == null) {
      throw ChartError("NullPointException");
    }
  }

  num get value {
    if (y is num && x is num) {
      return y;
      // ChartError(" x 和 y都是num 请重写该方法并返回正确的值");
    }
    if (y is num) {
      return y;
    }
    return x;
  }

  num get minValue {
    return 0;
  }

  num get maxValue {
    return value;
  }

  num get aveValue {
    return value / 2;
  }

  @override
  String toString() {
    return '$runtimeType x:${x} y:$y';
  }
}
