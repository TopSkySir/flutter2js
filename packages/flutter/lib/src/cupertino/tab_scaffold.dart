// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flur/flur_for_modified_flutter.dart' as flur;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'bottom_tab_bar.dart';

/// Implements a tabbed iOS application's root layout and behavior structure.
///
/// The scaffold lays out the tab bar at the bottom and the content between or
/// behind the tab bar.
///
/// A [tabBar] and a [tabBuilder] are required. The [CupertinoTabScaffold]
/// will automatically listen to the provided [CupertinoTabBar]'s tap callbacks
/// to change the active tab.
///
/// Tabs' contents are built with the provided [tabBuilder] at the active
/// tab index. The [tabBuilder] must be able to build the same number of
/// pages as there are [tabBar.items]. Inactive tabs will be moved [Offstage]
/// and their animations disabled.
///
/// Use [CupertinoTabView] as the content of each tab to support tabs with parallel
/// navigation state and history.
///
/// ## Sample code
///
/// A sample code implementing a typical iOS information architecture with tabs.
///
/// ```dart
/// new CupertinoTabScaffold(
///   tabBar: new CupertinoTabBar(
///     items: <BottomNavigationBarItem> [
///       // ...
///     ],
///   ),
///   tabBuilder: (BuildContext context, int index) {
///     return new CupertinoTabView(
///       builder: (BuildContext context) {
///         return new CupertinoPageScaffold(
///           navigationBar: new CupertinoNavigationBar(
///             middle: new Text('Page 1 of tab $index'),
///           ),
///           child: new Center(
///             child: new CupertinoButton(
///               child: const Text('Next page'),
///               onPressed: () {
///                 Navigator.of(context).push(
///                   new CupertinoPageRoute<Null>(
///                     builder: (BuildContext context) {
///                       return new CupertinoPageScaffold(
///                         navigationBar: new CupertinoNavigationBar(
///                           middle: new Text('Page 2 of tab $index'),
///                         ),
///                         child: new Center(
///                           child: new CupertinoButton(
///                             child: const Text('Back'),
///                             onPressed: () { Navigator.of(context).pop(); },
///                           ),
///                         ),
///                       );
///                     },
///                   ),
///                 );
///               },
///             ),
///           ),
///         );
///       },
///     );
///   },
/// )
/// ```
///
/// See also:
///
///  * [CupertinoTabBar], the bottom tab bar inserted in the scaffold.
///  * [CupertinoTabView], the typical root content of each tab that holds its own
///    [Navigator] stack.
///  * [CupertinoPageRoute], a route hosting modal pages with iOS style transitions.
///  * [CupertinoPageScaffold], typical contents of an iOS modal page implementing
///    layout with a navigation bar on top.
class CupertinoTabScaffold extends flur.StatelessUIPluginWidget {
  /// Creates a layout for applications with a tab bar at the bottom.
  ///
  /// The [tabBar] and [tabBuilder] arguments must not be null.
  const CupertinoTabScaffold({
    Key key,
    @required this.tabBar,
    @required this.tabBuilder,
  })
      : super(key: key);

  /// The [tabBar] is a [CupertinoTabBar] drawn at the bottom of the screen
  /// that lets the user switch between different tabs in the main content area
  /// when present.
  ///
  /// When provided, [CupertinoTabBar.currentIndex] will be ignored and will
  /// be managed by the [CupertinoTabScaffold] to show the currently selected page
  /// as the active item index. If [CupertinoTabBar.onTap] is provided, it will
  /// still be called. [CupertinoTabScaffold] automatically also listen to the
  /// [CupertinoTabBar]'s `onTap` to change the [CupertinoTabBar]'s `currentIndex`
  /// and change the actively displayed tab in [CupertinoTabScaffold]'s own
  /// main content area.
  ///
  /// If translucent, the main content may slide behind it.
  /// Otherwise, the main content's bottom margin will be offset by its height.
  final CupertinoTabBar tabBar;

  /// An [IndexedWidgetBuilder] that's called when tabs become active.
  ///
  /// The widgets built by [IndexedWidgetBuilder] is typically a [CupertinoTabView]
  /// in order to achieve the parallel hierarchies information architecture seen
  /// on iOS apps with tab bars.
  ///
  /// When the tab becomes inactive, its content is still cached in the widget
  /// tree [Offstage] and its animations disabled.
  ///
  /// Content can slide under the [tabBar] when it's translucent.
  final IndexedWidgetBuilder tabBuilder;

  @override
  Widget buildWithUIPlugin(BuildContext context, flur.UIPlugin plugin) {
    return plugin.buildCupertinoTabScaffold(context, this);
  }
}
