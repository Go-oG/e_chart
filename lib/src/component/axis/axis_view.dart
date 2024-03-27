import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/component/axis/axis_drawable_type.dart';
import 'package:flutter/material.dart';

abstract class AxisView<T extends BaseAxis, L extends AxisAttrs> extends GestureView {
  static final List<Drawable> _emptyDrawableList = List.empty(growable: false);

  T get axis => _axis!;
  T? _axis;

  L? _attrs;

  L get attrs {
    var att = _attrs;
    if (att != null) {
      return att;
    }
    att = onBuildDefaultAttrs();
    _attrs = att;
    return att;
  }

  int axisIndex;

  AxisView(
    super.context,
    this._axis, {
    this.axisIndex = 0,
  }) {
    layoutParams = LayoutParams.matchAll();
    titleNode = AxisTitleRender(axis.axisName);
  }

  ///存储坐标轴相关的节点
  final Map<AxisDrawableType, List<Drawable>> _elementMap = {};

  set axisScale(BaseScale bs) {
    _axisScale?.dispose();
    _axisScale = bs;
  }

  BaseScale get axisScale => _axisScale!;

  BaseScale? _axisScale;

  AxisTitleRender get titleNode => _titleNode!;
  AxisTitleRender? _titleNode;

  set titleNode(AxisTitleRender titleNode) {
    _titleNode?.dispose();
    _titleNode = titleNode;
  }

  @override
  void dispose() {
    _axisScale?.dispose();
    _axis = null;
    attrs.dispose();
    titleNode.dispose();
    titleNode = AxisTitleRender(null);
    super.dispose();
  }

  void onAttrsChange(L oldAttrs) {
    List<dynamic> dl = axisScale.domain;
    axisScale = onBuildScale(attrs, dl);
    onLayout(false, left, top, right, bottom);
  }

  void updateAttr(L attrs, List<dynamic> dataSet) {
    _attrs = attrs;
    axisScale = onBuildScale(attrs, dataSet);
  }

  @override
  void onLayout(bool changed, double left, double top, double right, double bottom) {
    updateRenders(AxisDrawableType.line, onLayoutAxisLine(attrs, axisScale));
    updateRenders(AxisDrawableType.tick, onLayoutAxisTick(attrs, axisScale));
    updateRenders(AxisDrawableType.label, onLayoutAxisLabel(attrs, axisScale));
    updateRenders(AxisDrawableType.splitLine, onLayoutSplitLine(attrs, axisScale));
    updateRenders(AxisDrawableType.splitArea, onLayoutSplitArea(attrs, axisScale));
    updateRenders(AxisDrawableType.title, onLayoutAxisTitle(attrs, axisScale));
  }

  L onBuildDefaultAttrs();

  List<Drawable>? onLayoutAxisTitle(L attrs, BaseScale scale);

  List<Drawable>? onLayoutAxisLine(L attrs, BaseScale scale);

  List<Drawable>? onLayoutSplitLine(L attrs, BaseScale scale);

  List<Drawable>? onLayoutSplitArea(L attrs, BaseScale scale);

  List<Drawable>? onLayoutAxisTick(L attrs, BaseScale scale);

  List<Drawable>? onLayoutAxisLabel(L attrs, BaseScale scale);

  BaseScale onBuildScale(L attrs, List<dynamic> dataSet);

  ///==========绘制=============

  @override
  void onDraw(CCanvas canvas) {
    onDrawAxisSplitArea(canvas, mPaint);
    onDrawAxisSplitLine(canvas, mPaint);
    onDrawAxisLine(canvas, mPaint);
    onDrawAxisTick(canvas, mPaint);
    onDrawAxisLabel(canvas, mPaint);
    onDrawAxisTitle(canvas, mPaint);
  }

  void onDrawAxisSplitArea(CCanvas canvas, Paint paint) {
    var splitArea = axis.splitArea;
    if (!splitArea.show) {
      return;
    }
    each(splitAreaList, (p0, p1) {
      p0.draw(canvas, paint);
    });
  }

  void onDrawAxisSplitLine(CCanvas canvas, Paint paint) {
    var splitLine = axis.splitLine;
    if (!splitLine.show) {
      return;
    }
    each(splitLineList, (p0, p1) {
      p0.draw(canvas, paint);
    });
  }

  void onDrawAxisTitle(CCanvas canvas, Paint paint) {
    var name = titleNode.name?.name;
    if (name == null || name.isEmpty) {
      return;
    }
    titleNode.label.draw(canvas, paint);
  }

  void onDrawAxisLine(CCanvas canvas, Paint paint) {
    var axisLine = axis.axisLine;
    if (!axisLine.show) {
      return;
    }
    each(lineList, (line, p1) {
      line.draw(canvas, paint);
    });
  }

  void onDrawAxisTick(CCanvas canvas, Paint paint) {
    var axisTick = axis.axisTick;
    if (!axisTick.show) {
      return;
    }
    each(tickList, (tick, p1) {
      tick.draw(canvas, paint);
    });
  }

  void onDrawAxisLabel(CCanvas canvas, Paint paint) {
    var axisLabel = axis.axisLabel;
    if (axisLabel.show) {
      each(labelList, (p0, p1) {
        p0.draw(canvas, paint);
      });
    }
  }

  ///绘制坐标轴指示器，该方法在[draw]之后调用
  void onDrawAxisPointer(CCanvas canvas, Paint paint, Offset touchOffset) {}

  ///返回全部的的Label
  List<DynamicText> obtainLabel() {
    if (axisScale is CategoryScale) {
      return List.from(axisScale.labels.map((e) => DynamicText(e)));
    }
    var formatter = axis.axisLabel.formatter;
    List<DynamicText> labels = [];
    if (axisScale is TimeScale) {
      for (var ele in axisScale.labels) {
        labels.add(axis.formatData(ele));
      }
      return labels;
    }
    if (axisScale is LinearScale || axisScale is LogScale) {
      labels = List.from(axisScale.labels.map((e) {
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
    List<dynamic> dl = axisScale.getRangeLabel(startIndex, endIndex);
    for (var data in dl) {
      rl.add(axis.formatData(data));
    }
    return rl;
  }

  ///判断当前坐标轴是否和数据相匹配
  bool matchType(dynamic data) {
    if (data is String && axisScale.isCategory) {
      return true;
    }
    if (data is DateTime && axisScale.isTime) {
      return true;
    }
    return data is num;
  }

  void syncScroll(CoordType type, double scrollX, double scrollY) {}

  AxisType get axisType {
    if (axis.categoryList.isNotEmpty || axis.type == AxisType.category) {
      return AxisType.category;
    }
    if (axis.type == AxisType.time || axis.timeRange != null) {
      return AxisType.time;
    }
    return axis.type;
  }

  AxisTheme get axisTheme {
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

  void updateRenders(AxisDrawableType type, [List<Drawable>? list]) {
    var old = _elementMap[type];
    if (old != null) {
      each(old, (p0, p1) {
        p0.dispose();
      });
    }
    _elementMap[type] = list ?? _emptyDrawableList;
  }

  List<Drawable> get lineList => getAxisElementRender(AxisDrawableType.line);

  List<Drawable> get splitLineList => getAxisElementRender(AxisDrawableType.splitLine);

  List<Drawable> get splitAreaList => getAxisElementRender(AxisDrawableType.splitArea);

  List<Drawable> get tickList => getAxisElementRender(AxisDrawableType.tick);

  List<Drawable> get labelList => getAxisElementRender(AxisDrawableType.label);

  List<Drawable> get titleList => getAxisElementRender(AxisDrawableType.title);

  List<Drawable> getAxisElementRender(AxisDrawableType type) {
    return _elementMap[AxisDrawableType.title] ?? _emptyDrawableList;
  }
}
