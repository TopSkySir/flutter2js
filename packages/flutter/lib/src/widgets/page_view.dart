// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';

import 'basic.dart';
import 'framework.dart';
import 'notification_listener.dart';
import 'page_storage.dart';
import 'scroll_context.dart';
import 'scroll_controller.dart';
import 'scroll_metrics.dart';
import 'scroll_notification.dart';
import 'scroll_physics.dart';
import 'scroll_position.dart';
import 'scroll_view.dart';
import 'sliver.dart';

/// A controller for [PageView].
///
/// A page controller lets you manipulate which page is visible in a [PageView].
/// In addition to being able to control the pixel offset of the content inside
/// the [PageView], a [PageController] also lets you control the offset in terms
/// of pages, which are increments of the viewport size.
///
/// See also:
///
///  * [PageView], which is the widget this object controls.
class PageController extends ScrollController {
  /// Creates a page controller.
  ///
  /// The [initialPage], [keepPage], and [viewportFraction] arguments must not be null.
  PageController({
    this.initialPage: 0,
    this.keepPage: true,
    this.viewportFraction: 1.0,
  }) {
    assert(initialPage != null);
    assert(keepPage != null);
    assert(viewportFraction != null);
    assert(viewportFraction > 0.0);
  }

  /// The page to show when first creating the [PageView].
  final int initialPage;

  /// Save the current [page] with [PageStorage] and restore it if
  /// this controller's scrollable is recreated.
  ///
  /// If this property is set to false, the current [page] is never saved
  /// and [initialPage] is always used to initialize the scroll offset.
  /// If true (the default), the initial page is used the first time the
  /// controller's scrollable is created, since there's isn't a page to
  /// restore yet. Subsequently the saved page is restored and
  /// [initialPage] is ignored.
  ///
  /// See also:
  ///
  ///  * [PageStorageKey], which should be used when more than one
  ///    scrollable appears in the same route, to distinguish the [PageStorage]
  ///    locations used to save scroll offsets.
  final bool keepPage;

  /// The fraction of the viewport that each page should occupy.
  ///
  /// Defaults to 1.0, which means each page fills the viewport in the scrolling
  /// direction.
  final double viewportFraction;

  /// The current page displayed in the controlled [PageView].
  double get page {
    throw new UnimplementedError();
  }

  /// Animates the controlled [PageView] from the current page to the given page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  /// The `duration` and `curve` arguments must not be null.
  Future<Null> animateToPage(
    int page, {
    @required Duration duration,
    @required Curve curve,
  }) {
    throw new UnimplementedError();
  }

  /// Changes which page is displayed in the controlled [PageView].
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  /// The `duration` and `curve` arguments must not be null.
  void jumpToPage(int page) {
    throw new UnimplementedError();
  }

  /// Animates the controlled [PageView] to the next page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  /// The `duration` and `curve` arguments must not be null.
  void nextPage({@required Duration duration, @required Curve curve}) {
    animateToPage(page.round() + 1, duration: duration, curve: curve);
  }

  /// Animates the controlled [PageView] to the previous page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  /// The `duration` and `curve` arguments must not be null.
  void previousPage({@required Duration duration, @required Curve curve}) {
    animateToPage(page.round() - 1, duration: duration, curve: curve);
  }

  @override
  ScrollPosition createScrollPosition(
      ScrollPhysics physics, ScrollContext context, ScrollPosition oldPosition);

  @override
  void attach(ScrollPosition position);
}

/// Metrics for a [PageView].
///
/// The metrics are available on [ScrollNotification]s generated from
/// [PageView]s.
class PageMetrics extends FixedScrollMetrics {
  /// Creates page metrics that add the given information to the `parent`
  /// metrics.
  PageMetrics({
    ScrollMetrics parent,
    this.page,
  })
      : super.clone(parent);

  /// The current page displayed in the [PageView].
  final double page;
}

/// Scroll physics used by a [PageView].
///
/// These physics cause the page view to snap to page boundaries.
///
/// See also:
///
///  * [ScrollPhysics], the base class which defines the API for scrolling
///    physics.
///  * [PageView.physics], which can override the physics used by a page view.
class PageScrollPhysics extends ScrollPhysics {
  /// Creates physics for a [PageView].
  const PageScrollPhysics({ScrollPhysics parent}) : super(parent: parent);

  @override
  PageScrollPhysics applyTo(ScrollPhysics ancestor) {
    return new PageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    throw new UnimplementedError();
  }
}

// Having this global (mutable) page controller is a bit of a hack. We need it
// to plumb in the factory for _PagePosition, but it will end up accumulating
// a large list of scroll positions. As long as you don't try to actually
// control the scroll positions, everything should be fine.
final PageController _defaultPageController = new PageController();
const PageScrollPhysics _kPagePhysics = const PageScrollPhysics();

/// A scrollable list that works page by page.
///
/// Each child of a page view is forced to be the same size as the viewport.
///
/// You can use a [PageController] to control which page is visible in the view.
/// In addition to being able to control the pixel offset of the content inside
/// the [PageView], a [PageController] also lets you control the offset in terms
/// of pages, which are increments of the viewport size.
///
/// The [PageController] can also be used to control the
/// [PageController.initialPage], which determines which page is shown when the
/// [PageView] is first constructed, and the [PageController.viewportFraction],
/// which determines the size of the pages as a fraction of the viewport size.
///
/// See also:
///
///  * [PageController], which controls which page is visible in the view.
///  * [SingleChildScrollView], when you need to make a single child scrollable.
///  * [ListView], for a scrollable list of boxes.
///  * [GridView], for a scrollable grid of boxes.
///  * [ScrollNotification] and [NotificationListener], which can be used to watch
///    the scroll position without using a [ScrollController].
class PageView extends StatelessWidget {
  /// Creates a scrollable list that works page by page from an explicit [List]
  /// of widgets.
  ///
  /// This constructor is appropriate for page views with a small number of
  /// children because constructing the [List] requires doing work for every
  /// child that could possibly be displayed in the page view, instead of just
  /// those children that are actually visible.
  PageView({
    Key key,
    this.scrollDirection: Axis.horizontal,
    this.reverse: false,
    PageController controller,
    this.physics,
    this.onPageChanged,
    List<Widget> children: const <Widget>[],
  })
      : controller = controller ?? _defaultPageController,
        childrenDelegate = new SliverChildListDelegate(children),
        super(key: key);

  /// Creates a scrollable list that works page by page using widgets that are
  /// created on demand.
  ///
  /// This constructor is appropriate for page views with a large (or infinite)
  /// number of children because the builder is called only for those children
  /// that are actually visible.
  ///
  /// Providing a non-null [itemCount] lets the [PageView] compute the maximum
  /// scroll extent.
  ///
  /// [itemBuilder] will be called only with indices greater than or equal to
  /// zero and less than [itemCount].
  PageView.builder({
    Key key,
    this.scrollDirection: Axis.horizontal,
    this.reverse: false,
    PageController controller,
    this.physics,
    this.onPageChanged,
    @required IndexedWidgetBuilder itemBuilder,
    int itemCount,
  })
      : controller = controller ?? _defaultPageController,
        childrenDelegate =
            new SliverChildBuilderDelegate(itemBuilder, childCount: itemCount),
        super(key: key);

  /// Creates a scrollable list that works page by page with a custom child
  /// model.
  PageView.custom({
    Key key,
    this.scrollDirection: Axis.horizontal,
    this.reverse: false,
    PageController controller,
    this.physics,
    this.onPageChanged,
    @required this.childrenDelegate,
  })
      : controller = controller ?? _defaultPageController,
        super(key: key) {
    assert(childrenDelegate != null);
  }

  /// The axis along which the page view scrolls.
  ///
  /// Defaults to [Axis.horizontal].
  final Axis scrollDirection;

  /// Whether the page view scrolls in the reading direction.
  ///
  /// For example, if the reading direction is left-to-right and
  /// [scrollDirection] is [Axis.horizontal], then the page view scrolls from
  /// left to right when [reverse] is false and from right to left when
  /// [reverse] is true.
  ///
  /// Similarly, if [scrollDirection] is [Axis.vertical], then the page view
  /// scrolls from top to bottom when [reverse] is false and from bottom to top
  /// when [reverse] is true.
  ///
  /// Defaults to false.
  final bool reverse;

  /// An object that can be used to control the position to which this page
  /// view is scrolled.
  final PageController controller;

  /// How the page view should respond to user input.
  ///
  /// For example, determines how the page view continues to animate after the
  /// user stops dragging the page view.
  ///
  /// The physics are modified to snap to page boundaries using
  /// [PageScrollPhysics] prior to being used.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics physics;

  /// Called whenever the page in the center of the viewport changes.
  final ValueChanged<int> onPageChanged;

  /// A delegate that provides the children for the [PageView].
  ///
  /// The [PageView.custom] constructor lets you specify this delegate
  /// explicitly. The [PageView] and [PageView.builder] constructors create a
  /// [childrenDelegate] that wraps the given [List] and [IndexedWidgetBuilder],
  /// respectively.
  final SliverChildDelegate childrenDelegate;

  @override
  Widget build(context) {
    throw new UnimplementedError();
  }
}
