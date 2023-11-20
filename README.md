
# e_chart

[e_chart](https://pub.dev/packages/e_chart) 是一个用 Dart 原生编写的数据可视化库，用于高效的创建美观、高性能的图表，用于在Flutter中制作高质量的移动应用程序用户界面

## 概览

e_chart能创建各种类型的笛卡尔图、饼图、旭日图等图形，具有无缝交互、响应能力和流畅的动画。且具有丰富的功能集，完全可定制和可扩展。[e_chart](https://pub.dev/packages/e_chart) 内置包含以下图表类型

| [Bar](https://github.com/Go-oG/e_chart/tree/dev/docs/bar.md) | [Boxplot](https://github.com/Go-oG/e_chart/tree/dev/docs/boxplot.md) | [Calendar](https://github.com/Go-oG/e_chart/tree/dev/docs/calendar.md) | [Candlestick](https://github.com/Go-oG/e_chart/tree/dev/docs/candlestick.md) |
| :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: |
| [Chord](https://github.com/Go-oG/e_chart/tree/dev/docs/chord.md) | [Chord](https://github.com/Go-oG/e_chart/tree/dev/docs/chord.md) | [Circle](https://github.com/Go-oG/e_chart/tree/dev/docs/circle.md) | [delaunay](https://github.com/Go-oG/e_chart/tree/dev/docs/delaunay.md) |
| [Funnel](https://github.com/Go-oG/e_chart/tree/dev/docs/funnel.md) | [Graph](https://github.com/Go-oG/e_chart/tree/dev/docs/graph.md) | [HeatMap](https://github.com/Go-oG/e_chart/tree/dev/docs/heatmap.md) | [Hexbin](https://github.com/Go-oG/e_chart/tree/dev/docs/hexbin.md) |
| [Line](https://github.com/Go-oG/e_chart/tree/dev/docs/line.md) | [Pack](https://github.com/Go-oG/e_chart/tree/dev/docs/pack.md) | [Parallel](https://github.com/Go-oG/e_chart/tree/dev/docs/parallel.md) | [Pie](https://github.com/Go-oG/e_chart/tree/dev/docs/pie.md) |
| [Point](https://github.com/Go-oG/e_chart/tree/dev/docs/point.md) | [Radar](https://github.com/Go-oG/e_chart/tree/dev/docs/radar.md) | [Sankey](https://github.com/Go-oG/e_chart/tree/dev/docs/sankey.md) | [Sunburst](https://github.com/Go-oG/e_chart/tree/dev/docs/sunburst.md) |
| [ThemeRiver](https://github.com/Go-oG/e_chart/tree/dev/docs/themeriver.md) | [Tree](https://github.com/Go-oG/e_chart/tree/dev/docs/tree.md) | [TreeMap](https://github.com/Go-oG/e_chart/tree/dev/docs/treemap.md) |                                                              |



## 获取演示程序
通过从github上下载演示应用程序并启动，在您的设备上探索图表的全部功能，并在 GitHub 中查看示例代码

## 开始使用

### Install

从 [pub](https://pub.dev/packages/e_chart) 安装最新版本。

### 导入包

```dart
import 'package:e_chart/e_chart.dart';
```
### 添加组件到组件树中

将图表小组件添加为任何小组件的子级。

```dart
@override
  Widget build(BuildContext context) {
    Widget w = Container(
        alignment: Alignment.center,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Chart(itemData.config!),
        ));
    return Scaffold(
        appBar: AppBar(
            title: Text(
          itemData.name,
          style: const TextStyle(fontSize: 15, color: Colors.white),
        )),
        body: w);
  }
```

### 创建数据并进行绑定
根据你的数据，创建对应的Series,并初始化相应的轴型和坐标系(可选)。在本系列中，以创建柱状图为例

```dart
//首先创建一个笛卡尔坐标系，其包含一个X轴和Y轴，其中X轴为类目轴且标签逆时针旋转45度，Y轴为数值轴
Grid grid = Grid(xAxisList: [
    XAxis(
        type: AxisType.category,
        categoryList: _weekList,
        axisLabel: AxisLabel(
          rotate: -45,
        ))
  ], yAxisList: [
    YAxis()
  ]);
// 创建数据
List<BarGroupData> buildBarData([int groupCount = 7, int itemCount = 7, List<String?> stackIds = const [], bool usePercent = false]) {
  if (groupCount > 7) {
    groupCount = 7;
  }
  if (itemCount > 7) {
    itemCount = 7;
  }
  List<BarGroupData> list = [];
  Random random = Random(1);
  for (int i = 0; i < groupCount; i++) {
    String? stackId;
    if (i < stackIds.length) {
      stackId = stackIds[i];
    }
    BarGroupData groupData = BarGroupData([], stackId: stackId);
    for (int j = 0; j < itemCount; j++) {
      var t = StackItemData(_weekList[j], (random.nextInt(50) + 10));
      groupData.data.add(StackData(t));
    }
    list.add(groupData);
  }

  return list;
}
  var list = buildBarData(7, 7, ["a", "a", "a", null, null, "b", "b"], false);
//创建BarSeries(将数据和对应图表绑定)
  var series = BarSeries(
    list,
    animatorStyle: GridAnimatorStyle.originExpand,
    coordType: CoordType.grid,
    direction: Direction.vertical,
    corner: const Corner.all(24),
    stackIsPercent: true,
  );
  
  //创建整个图表的配置项(将Series和坐标系关联)
  var option= ChartOption(series: [
    series,
  ], gridList: [
    grid
  ]);
  
  //option传递给Chart组件就可以了，现在图表已经创建完成了，是不是很简单
  @override
  Widget build(BuildContext context) {
    Widget w = Container(
        alignment: Alignment.center,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Chart(option),
        ));
    return Scaffold(
        appBar: AppBar(
            title: Text(
          itemData.name,
          style: const TextStyle(fontSize: 15, color: Colors.white),
        )),
        body: w);
  }
```

## 支持
