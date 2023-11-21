import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class AxisPainter extends Disposable {
  List<LinePainter> lines;
  List<LabelPainter> labels;
  List<TickPainter> ticks;

  AxisPainter(this.lines, this.ticks, this.labels);

  void drawLine(CCanvas canvas, Paint paint, LineStyle style) {
    each(lines, (s, i) {
      style.drawPolygon(canvas, paint, [s.start, s.end]);
    });
  }

  void drawLabel(CCanvas canvas, Paint paint, int interval) {
    each(labels, (label, i) {
      if (interval <= 0 || label.originIndex % interval == 0) {
        label.textConfig.draw(canvas, paint);
      }
      each(label.minorLabel, (minor, p1) {
        if (interval <= 0 || minor.originIndex % interval == 0) {
          minor.textConfig.draw(canvas, paint);
        }
      });

    });
  }

  void drawTick(CCanvas canvas, Paint paint, MainTick? tick, [MinorTick? minorTick]) {
    if (tick == null || !tick.show) {
      return;
    }
    each(ticks, (tt, p1) {
      int interval = tick.interval;
      if (interval > 0) {
        interval += 1;
      }
      var start = tt.start;
      var end = tt.end;
      if (interval <= 0 || (tt.index % interval == 0)) {
        tick.lineStyle.drawPolygon(canvas, paint, [start, end]);
      }

      if (minorTick != null && minorTick.show) {
        int interval = minorTick.interval;
        if (interval > 0) {
          interval += 1;
        }
        each(tt.minorList, (at, p2) {
          if (interval <= 0) {
            minorTick.lineStyle.drawPolygon(canvas, paint, [at.start, at.end]);
            return;
          }
          if (at.index % interval == 0) {
            minorTick.lineStyle.drawPolygon(canvas, paint, [at.start, at.end]);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    each(lines, (p0, p1) {
      p0.dispose();
    });
    each(labels, (p0, p1) {
      p0.dispose();
    });
    each(ticks, (p0, p1) {
      p0.dispose();
    });
    lines = [];
    labels = [];
    ticks = [];
    super.dispose();
  }
}
