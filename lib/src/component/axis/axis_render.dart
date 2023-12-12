import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/component/axis/axis_element_type.dart';
import 'package:flutter/material.dart';

abstract class BaseAxisRender<T extends BaseAxis, L extends AxisAttrs> extends ChartNotifier2 {
  static final List<ElementRender> _emptyRenderList = List.empty(growable: false);

  T get axis => _axis!;
  T? _axis;

  Context? _context;

  Context get context => _context!;

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

  BaseAxisRender(
    this._context,
    this._axis, {
    this.axisIndex = 0,
  }) {
    titleNode = AxisTitleRender(axis.axisName);
  }

  ///存储坐标轴相关的节点
  final Map<AxisElementType, List<ElementRender>> _elementMap = {};

  set scale(BaseScale bs) {
    _scale?.dispose();
    _scale = bs;
  }

  BaseScale get scale => _scale!;
  BaseScale? _scale;

  AxisTitleRender get titleNode => _titleNode!;
  AxisTitleRender? _titleNode;

  set titleNode(AxisTitleRender titleNode) {
    _titleNode?.dispose();
    _titleNode = titleNode;
  }

  @override
  void dispose() {
    _context = null;
    _axis = null;
    attrs.dispose();
    titleNode.dispose();
    scale.dispose();
    titleNode = AxisTitleRender(null);
    super.dispose();
  }

  void onAttrsChange(L oldAttrs) {
    List<dynamic> dl = scale.domain;
    scale = onBuildScale(attrs, dl);
    onLayout(attrs, scale);
  }

  ///================测量===================
  void onMeasure(double parentWidth, double parentHeight) {}

  ///==================布局===========
  void doLayout(L attrs, List<dynamic> dataSet) {
    _attrs = attrs;
    scale = onBuildScale(attrs, dataSet);
    onLayout(attrs, scale);
  }

  void onLayout(L attrs, BaseScale scale) {
    updateRenders(AxisElementType.line, onLayoutAxisLine(attrs, scale));
    updateRenders(AxisElementType.tick, onLayoutAxisTick(attrs, scale));
    updateRenders(AxisElementType.label, onLayoutAxisLabel(attrs, scale));
    updateRenders(AxisElementType.splitLine, onLayoutSplitLine(attrs, scale));
    updateRenders(AxisElementType.splitArea, onLayoutSplitArea(attrs, scale));
    updateRenders(AxisElementType.title, onLayoutAxisTitle(attrs, scale));
  }

  L onBuildDefaultAttrs();

  List<ElementRender>? onLayoutAxisTitle(L attrs, BaseScale scale);

  List<ElementRender>? onLayoutAxisLine(L attrs, BaseScale scale);

  List<ElementRender>? onLayoutSplitLine(L attrs, BaseScale scale);

  List<ElementRender>? onLayoutSplitArea(L attrs, BaseScale scale);

  List<ElementRender>? onLayoutAxisTick(L attrs, BaseScale scale);

  List<ElementRender>? onLayoutAxisLabel(L attrs, BaseScale scale);

  BaseScale onBuildScale(L attrs, List<dynamic> dataSet);

  ///==========绘制=============

  void draw(CCanvas canvas, Paint paint) {
    onDrawAxisSplitArea(canvas, paint);
    onDrawAxisSplitLine(canvas, paint);
    onDrawAxisLine(canvas, paint);
    onDrawAxisTick(canvas, paint);
    onDrawAxisLabel(canvas, paint);
    onDrawAxisTitle(canvas, paint);
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

  void updateRenders(AxisElementType type, [List<ElementRender>? list]) {
    var old = _elementMap[type];
    if (old != null) {
      each(old, (p0, p1) {
        p0.dispose();
      });
    }
    _elementMap[type] = list ?? _emptyRenderList;
  }

  void notifyLayoutUpdate() {
    value = Command.layoutUpdate;
  }

  void notifyLayoutEnd() {
    value = Command.layoutEnd;
  }

  List<ElementRender> get lineList => getAxisElementRender(AxisElementType.line);

  List<ElementRender> get splitLineList => getAxisElementRender(AxisElementType.splitLine);

  List<ElementRender> get splitAreaList => getAxisElementRender(AxisElementType.splitArea);

  List<ElementRender> get tickList => getAxisElementRender(AxisElementType.tick);

  List<ElementRender> get labelList => getAxisElementRender(AxisElementType.label);

  List<ElementRender> get titleList => getAxisElementRender(AxisElementType.title);

  List<ElementRender> getAxisElementRender(AxisElementType type) {
    return _elementMap[AxisElementType.title] ?? _emptyRenderList;
  }
}
