import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import '../../component/mark/mark_line.dart';
import '../../component/mark/mark_point.dart';
import '../../functions.dart';
import '../../model/enums/align2.dart';
import '../../model/enums/chart_type.dart';
import '../../model/enums/coordinate.dart';
import '../../model/enums/direction.dart';
import '../../model/enums/position.dart';
import '../../model/enums/stack_strategy.dart';
import '../../model/string_number.dart';
import '../../style/area_style.dart';
import '../../style/label.dart';
import '../../style/symbol/symbol.dart';
import '../../core/series.dart';

class BarSeries extends RectSeries {
  List<BarGroupData> data;
  Direction direction; // 布局方向
  SNumber corner; // 圆角只有在 bar时才有效
  SNumber groupGap; // Group组的间隔
  SNumber columnGap; //Group组中柱状图之间的间隔
  num innerGap; // Column组里面的间隔

  bool legendHoverLink; // 是否启用图例hover的联动高亮
  bool connectNulls; // 是否连接空数据
  bool realtimeSort; // 是否启用实时排序
  AnimatorStyle animatorStyle;
  LinkageStyle linkageStyle;

  /// 主样式 对于绘制Line 使用其border 属性
  Fun3<BarSingleData, BarGroupData, AreaStyle> styleFun;

  /// 只会在绘制直线组时调用该方法，返回true 表示是阶梯折线图
  Fun2<BarGroupData, bool>? stepLineFun;

  ///绘制对齐
  Fun2<BarGroupData, Align2>? alignFun;

  /// 符号样式
  Fun2<BarSingleData, ChartSymbol>? symbolFun;

  /// 背景样式(只在某些形状下有效)
  Fun2<BarSingleData, AreaStyle>? backgroundStyleFun;

  /// 标签转换
  Fun2<BarSingleData, String>? labelFun;

  /// 标签样式
  Fun2<BarSingleData, LabelStyle>? labelStyleFun;

  /// 标签对齐
  Fun2<BarSingleData, Position2>? labelAlignFun;

  /// 标记点、线相关的
  Fun2<BarGroupData, MarkPoint>? markPointFun;

  Fun2<BarGroupData, MarkLine>? markLineFun;

  BarSeries(
    this.data, {
    this.legendHoverLink = true,
    this.connectNulls = true,
    this.direction = Direction.vertical,
    this.corner = SNumber.zero,
    this.columnGap = SNumber.zero,
    this.groupGap = const SNumber.number(4),
    this.innerGap = 0,
    this.realtimeSort = false,
    this.animatorStyle = AnimatorStyle.expand,
    this.linkageStyle = LinkageStyle.group,
    required this.styleFun,
    this.stepLineFun,
    this.alignFun,
    this.symbolFun,
    this.labelFun,
    this.labelStyleFun,
    this.labelAlignFun,
    this.backgroundStyleFun,
    this.markPointFun,
    this.markLineFun,
    super.xAxisIndex = 0,
    super.yAxisIndex = 0,
    super.polarAxisIndex = 0,
    super.coordSystem = CoordSystem.grid,
    super.animation,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.enableClick,
    super.enableHover,
    super.enableDrag,
    super.enableScale,
    super.clip,
    super.z,
    super.tooltip,
  }) : super(radarIndex: -1, calendarIndex: -1, parallelIndex: -1);
}

///组数据
class BarGroupData {
  final ChartType type;
  final List<BarSingleData> data;
  late final String id;

  ///控制柱状图的大小（具体的含义取决于布局的方向）
  SNumber? barSize;
  SNumber? barMaxSize;
  SNumber? barMinSize;
  String? name;
  String? _yAxisId;
  String? _xAxisId;
  String? _stackId;
  StackStrategy strategy;

  BarGroupData(
    this.type,
    this.data, {
    String? id,
    this.barSize,
    this.barMaxSize,
    this.barMinSize = const SNumber(1, false),
    this.name,
    String? yAxisId,
    String? xAxisId,
    String? stackId,
    this.strategy = StackStrategy.none,
  }) {
    if (id == null || id.isEmpty) {
      this.id = const Uuid().v4().toString().replaceAll('-', '');
    } else {
      this.id = id;
    }
    _stackId = stackId;
    _xAxisId = xAxisId;
    _yAxisId = yAxisId;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is BarGroupData && other.id == id;
  }

  bool get isStack {
    return _stackId != null && _stackId!.isNotEmpty && strategy != StackStrategy.none;
  }

  bool get isNotStack {
    return !isStack;
  }

  String get yAxisId => _yAxisId ?? '';

  String get xAxisId => _xAxisId ?? '';

  String get stackId => _stackId ?? '';
}

///不可再分的数据点
class BarSingleData {
  late final num up;
  late final num down;
  final dynamic x;

  ///只能是数字或者字符串
  late final String id;

  BarSingleData(this.down, this.up, {String? id, this.x}) {
    if (id != null && id.isNotEmpty) {
      this.id = id;
    } else {
      this.id = const Uuid().v4().toString().replaceAll('-', '');
    }

    if (up < down) {
      throw FlutterError('maxData must more than minData');
    }

    if (x != null) {
      if (!(x is num || x is String)) {
        throw FlutterError('x only support num or string');
      }
    }
  }

  BarSingleData.only(num data, {String? id, this.x}) {
    if (data > 0) {
      up = data;
      down = 0;
    } else {
      up = 0;
      down = data;
    }
    if (id != null && id.isNotEmpty) {
      this.id = id;
    } else {
      this.id = const Uuid().v4().toString().replaceAll('-', '');
    }

    if (up < down) {
      throw FlutterError('maxData must more than minData');
    }

    if (x != null) {
      if (!(x is num || x is String)) {
        throw FlutterError('x only support num or string');
      }
    }
  }

  num get ave {
    return (down + up) / 2;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is BarSingleData && other.id == id;
  }

  num get diff => up - down;
}

///动画样式
enum AnimatorStyle { expand, selfExpand }

/// 标识一个Group的手势联动策略
enum LinkageStyle {
  none,
  single, // 只有自身变化
  group, // 联动Group
}
