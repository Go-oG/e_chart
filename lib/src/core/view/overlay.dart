import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class ViewOverLay {
  late OverlayViewGroup mOverlayViewGroup;

  ViewOverlay(Context context, ChartView hostView) {
    mOverlayViewGroup = OverlayViewGroup(context, hostView);
  }

  ChartViewGroup getOverlayView() {
    return mOverlayViewGroup;
  }

  void add(Drawable drawable) {
    mOverlayViewGroup.addDrawable(drawable);
  }

  void remove(Drawable drawable) {
    mOverlayViewGroup.removeDrawable(drawable);
  }

  void clear() {
    mOverlayViewGroup.clear();
  }

  bool isEmpty() {
    return mOverlayViewGroup.isEmpty();
  }
}

class OverlayViewGroup extends ChartViewGroup {
  late final ChartView mHostView;

  List<Drawable> mDrawables = [];

  OverlayViewGroup(Context context, this.mHostView) : super(context) {
    attachInfo = mHostView.attachInfo;
    right = mHostView.width;
    bottom = mHostView.height;
  }

  void addDrawable(Drawable drawable) {
    if (!mDrawables.contains(drawable)) {
      mDrawables.add(drawable);
      requestDraw();
    }
  }

  void removeDrawable(Drawable drawable) {
    mDrawables.remove(drawable);
    requestDraw();
  }

  void add(ChartView child) {
    if (child.parent is ChartViewGroup) {
      var parent = child.parent as ChartViewGroup;
      if (parent != mHostView && parent.parent != null) {
        List<int> parentLocation = List.filled(2, 0);
        List<int> hostViewLocation = List.filled(2, 0);
        //parent.getLocationOnScreen(parentLocation);
        //mHostView.getLocationOnScreen(hostViewLocation);
        child.left = parentLocation[0] - hostViewLocation[0].toDouble();
        child.top = parentLocation[1] - hostViewLocation[1].toDouble();
      }
      parent.removeView(child);

      // if (parent.getLayoutTransition() != null) {
      //   parent.getLayoutTransition().cancel(LayoutTransition.DISAPPEARING);
      // }

      if (child.parent != null) {
        child.mParent = null;
      }
    }
    super.addView(child);
  }

  void remove(ChartView view) {
    super.removeView(view);
  }

  void clear() {
    removeAllViews();
    mDrawables.clear();
  }

  bool isEmpty() {
    if (childCount == 0 && mDrawables.isEmpty) {
      return true;
    }
    return false;
  }

  void invalidateDrawable(Drawable drawable) {
    //  invalidate(drawable.getBounds());
  }

  @override
  void dispatchDraw(CCanvas canvas) {
    super.dispatchDraw(canvas);
    final int numDrawables = mDrawables.length;
    var paint = Paint();
    for (int i = 0; i < numDrawables; ++i) {
      mDrawables[i].draw(canvas, paint);
    }
  }

  @override
  void onLayout(bool changed, double l, double t, double r, double b) {
// Noop: children are positioned absolutely
  }

  @override
  void requestDraw() {
    super.requestDraw();
    mHostView.requestDraw();
  }

  @override
  void requestDrawInner(bool redrawCache) {
    super.requestDrawInner(redrawCache);
    mHostView.requestDrawInner(redrawCache);
  }

  @override
  void requestDrawInner2(double l, double t, double r, double b, bool redrawCache, bool fullRedraw) {
    super.requestDrawInner2(l, t, r, b, redrawCache, fullRedraw);
    mHostView.requestDrawInner2(l, t, r, b, redrawCache, fullRedraw);
  }

  @override
  void onDescendantInvalidated(ChartView child, ChartView target) {
    if (mHostView is ChartViewGroup) {
      (mHostView as ChartViewGroup).onDescendantInvalidated(mHostView, target);
      super.onDescendantInvalidated(child, target);
    } else {
      requestDraw();
    }
  }

  ViewParent? invalidateChildInParent(List<double> location, Rect dirty) {
    // dirty = dirty.shift(Offset(location[0], location[1]));
    // if (mHostView is ChartViewGroup) {
    //   location[0] = 0;
    //   location[1] = 0;
    //   super.invalidateChildInParent(location, dirty);
    //   return (mHostView as ChartViewGroup).invalidateChildInParent(location, dirty);
    // } else {
    //   requestDraw(dirty);
    // }
    return null;
  }
}
