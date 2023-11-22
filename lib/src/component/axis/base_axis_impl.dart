import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

abstract class BaseAxisImpl<T extends BaseAxis, L extends AxisAttrs, R extends AxisPainter> extends ChartNotifier2 {
  static final tmpTick = MainTick();
  static final MinorTick tmpMinorTick = MinorTick();

  Context? _context;

  Context get context => _context!;

  T? _axis;

  T get axis => _axis!;

  late L attrs;

  set scale(BaseScale bs) {
    _scale?.dispose();
    _scale = bs;
  }

  BaseScale get scale => _scale!;
  BaseScale? _scale;

  set axisPainter(R p) {
    _axisPainter?.dispose();
    _axisPainter = p;
  }

  R get axisPainter => _axisPainter!;
  R? _axisPainter;

  AxisTitlePainter? _titleNode;

  AxisTitlePainter get titleNode => _titleNode!;

  set titleNode(AxisTitlePainter titleNode) {
    _titleNode?.dispose();
    _titleNode = titleNode;
  }

  int get axisIndex => attrs.axisIndex;

  BaseAxisImpl(this._context, this._axis, this.attrs) {
    titleNode = AxisTitlePainter(axis.axisName);
  }

  @override
  void dispose() {
    _context = null;
    _axis = null;
    attrs.dispose();
    axisPainter.dispose();
    titleNode.dispose();
    scale.dispose();
    titleNode = AxisTitlePainter(null);
    super.dispose();
  }

  void onMeasure(double parentWidth, double parentHeight) {}

  void doLayout(L attrs, List<dynamic> dataSet) {
    this.attrs = attrs;
    scale = onBuildScale(attrs, dataSet);
    titleNode.label.dispose();
    titleNode.label = onLayoutAxisName();
    axisPainter = onLayout(attrs, scale);
  }

  void onAttrsChange(L oldAttrs) {
    List<dynamic> dl = scale.domain;
    scale = onBuildScale(attrs, dl);
    titleNode.label.dispose();
    titleNode.label = onLayoutAxisName();
    axisPainter = onLayout(attrs, scale);
  }

  R onLayout(L attrs, BaseScale scale);

  BaseScale onBuildScale(L attrs, List<dynamic> dataSet);

  TextDraw onLayoutAxisName();

  void draw(CCanvas canvas, Paint paint) {
    onDrawAxisSplitArea(canvas, paint);
    onDrawAxisSplitLine(canvas, paint);
    onDrawAxisTick(canvas, paint);
    onDrawAxisLine(canvas, paint);
    onDrawAxisLabel(canvas, paint);
    onDrawAxisName(canvas, paint);
  }

  void onDrawAxisSplitLine(CCanvas canvas, Paint paint) {}

  void onDrawAxisSplitArea(CCanvas canvas, Paint paint) {}

  void onDrawAxisName(CCanvas canvas, Paint paint) {
    var name = titleNode.name?.name;
    if (name == null || name.isEmpty) {
      return;
    }
    titleNode.label.draw(canvas, paint);
  }

  void onDrawAxisLine(CCanvas canvas, Paint paint) {}

  void onDrawAxisTick(CCanvas canvas, Paint paint) {}

  void onDrawAxisLabel(CCanvas canvas, Paint paint) {}

  ///绘制坐标轴指示器，该方法在[draw]之后调用
  void onDrawAxisPointer(CCanvas canvas, Paint paint, Offset touchOffset) {}

  ///返回全部的的Label
  List<DynamicText> obtainLabel() {
    if (scale is CategoryScale) {
      return List.from(scale.labels.map((e) => DynamicText(e)));
    }
    var formatter = axis.axisLabel.formatter;
    List<DynamicText> labels = [];
    if (scale is TimeScale) {
      for (var ele in scale.labels) {
        labels.add(axis.formatData(ele));
      }
      return labels;
    }
    if (scale is LinearScale || scale is LogScale) {
      labels = List.from(scale.labels.map((e) {
        if (formatter != null) {
          return formatter.call(e);
        } else {
          return DynamicText.fromString(formatNumber(e));
        }
      }));
    }
    return labels;
  }

  ///获取Label 通过给定的Tick索引范围
  List<DynamicText> obtainLabel2(int startIndex, int endIndex) {
    List<DynamicText> rl = [];
    List<dynamic> dl = scale.getRangeLabel(startIndex, endIndex);
    for (var data in dl) {
      rl.add(axis.formatData(data));
    }
    return rl;
  }

  AxisTheme getAxisTheme() {
    if (axis.isCategoryAxis) {
      return context.option.theme.categoryAxisTheme;
    }
    if (axis.isTimeAxis) {
      return context.option.theme.timeAxisTheme;
    }
    if (axis.isLogAxis) {
      return context.option.theme.logAxisTheme;
    }
    return context.option.theme.valueAxisTheme;
  }

  ///判断当前坐标轴是否和数据相匹配
  bool matchType(dynamic data) {
    if (data is String && scale.isCategory) {
      return true;
    }
    if (data is DateTime && scale.isTime) {
      return true;
    }
    return data is num;
  }

  AxisType get axisType {
    if (axis.categoryList.isNotEmpty || axis.type == AxisType.category) {
      return AxisType.category;
    }
    if (axis.type == AxisType.time || axis.timeRange != null) {
      return AxisType.time;
    }
    return axis.type;
  }

  void notifyLayoutUpdate() {
    value = Command.layoutUpdate;
  }

  void notifyLayoutEnd() {
    value = Command.layoutEnd;
  }
}
