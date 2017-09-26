// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'animated_size.dart';
import 'basic.dart';
import 'framework.dart';
import 'ticker_provider.dart';
import 'transitions.dart';

/// Specifies which of two children to show. See [AnimatedCrossFade].
///
/// The child that is shown will fade in, while the other will fade out.
enum CrossFadeState {
  /// Show the first child ([AnimatedCrossFade.firstChild]) and hide the second
  /// ([AnimatedCrossFade.secondChild]]).
  showFirst,

  /// Show the second child ([AnimatedCrossFade.secondChild]) and hide the first
  /// ([AnimatedCrossFade.firstChild]).
  showSecond,
}

/// Signature for the [AnimatedCrossFade.layoutBuilder] callback.
///
/// The `topChild` is the child fading in, which is normally drawn on top. The
/// `bottomChild` is the child fading out, normally drawn on the bottom.
///
/// For good performance, the returned widget tree should contain both the
/// `topChild` and the `bottomChild`; the depth of the tree, and the types of
/// the widgets in the tree, from the returned widget to each of the children
/// should be the same; and where there is a widget with multiple children, the
/// top child and the bottom child should be keyed using the provided
/// `topChildKey` and `bottomChildKey` keys respectively.
///
/// ## Sample code
///
/// ```dart
/// Widget defaultLayoutBuilder(Widget topChild, Key topChildKey, Widget bottomChild, Key bottomChildKey) {
///   return new Stack(
///     fit: StackFit.loose,
///     children: <Widget>[
///       new Positioned(
///         key: bottomChildKey,
///         left: 0.0,
///         top: 0.0,
///         right: 0.0,
///         child: bottomChild,
///       ),
///       new Positioned(
///         key: topChildKey,
///         child: topChild,
///       )
///     ],
///   );
/// }
/// ```
typedef Widget AnimatedCrossFadeBuilder(Widget topChild, Key topChildKey,
    Widget bottomChild, Key bottomChildKey);

/// A widget that cross-fades between two given children and animates itself
/// between their sizes.
///
/// The animation is controlled through the [crossFadeState] parameter.
/// [firstCurve] and [secondCurve] represent the opacity curves of the two
/// children. The [firstCurve] is inverted, i.e. it fades out when providing a
/// growing curve like [Curves.linear]. The [sizeCurve] is the curve used to
/// animated between the size of the fading out child and the size of the fading
/// in child.
///
/// This widget is intended to be used to fade a pair of widgets with the same
/// width. In the case where the two children have different heights, the
/// animation crops overflowing children during the animation by aligning their
/// top edge, which means that the bottom will be clipped.
///
/// The animation is automatically triggered when an existing
/// [AnimatedCrossFade] is rebuilt with a different value for the
/// [crossFadeState] property.
///
/// ## Sample code
///
/// This code fades between two representations of the Flutter logo. It depends
/// on a boolean field `_first`; when `_first` is true, the first logo is shown,
/// otherwise the second logo is shown. When the field changes state, the
/// [AnimatedCrossFade] widget cross-fades between the two forms of the logo
/// over three seconds.
///
/// ```dart
/// new AnimatedCrossFade(
///   duration: const Duration(seconds: 3),
///   firstChild: const FlutterLogo(style: FlutterLogoStyle.horizontal, size: 100.0),
///   secondChild: const FlutterLogo(style: FlutterLogoStyle.stacked, size: 100.0),
///   crossFadeState: _first ? CrossFadeState.showFirst : CrossFadeState.showSecond,
/// )
/// ```
///
/// See also:
///
///  * [AnimatedSize], the lower-level widget which [AnimatedCrossFade] uses to
///    automatically change size.
class AnimatedCrossFade extends StatefulWidget {
  /// Creates a cross-fade animation widget.
  ///
  /// The [duration] of the animation is the same for all components (fade in,
  /// fade out, and size), and you can pass [Interval]s instead of [Curve]s in
  /// order to have finer control, e.g., creating an overlap between the fades.
  ///
  /// All the arguments other than [key] must be non-null.
  const AnimatedCrossFade({
    Key key,
    @required this.firstChild,
    @required this.secondChild,
    this.firstCurve: Curves.linear,
    this.secondCurve: Curves.linear,
    this.sizeCurve: Curves.linear,
    this.alignment: FractionalOffset.topCenter,
    @required this.crossFadeState,
    @required this.duration,
    this.layoutBuilder: defaultLayoutBuilder,
  }) :
        super(key: key);

  /// The child that is visible when [crossFadeState] is
  /// [CrossFadeState.showFirst]. It fades out when transitioning
  /// [crossFadeState] from [CrossFadeState.showFirst] to
  /// [CrossFadeState.showSecond] and vice versa.
  final Widget firstChild;

  /// The child that is visible when [crossFadeState] is
  /// [CrossFadeState.showSecond]. It fades in when transitioning
  /// [crossFadeState] from [CrossFadeState.showFirst] to
  /// [CrossFadeState.showSecond] and vice versa.
  final Widget secondChild;

  /// The child that will be shown when the animation has completed.
  final CrossFadeState crossFadeState;

  /// The duration of the whole orchestrated animation.
  final Duration duration;

  /// The fade curve of the first child.
  ///
  /// Defaults to [Curves.linear].
  final Curve firstCurve;

  /// The fade curve of the second child.
  ///
  /// Defaults to [Curves.linear].
  final Curve secondCurve;

  /// The curve of the animation between the two children's sizes.
  ///
  /// Defaults to [Curves.linear].
  final Curve sizeCurve;

  /// How the children should be aligned while the size is animating.
  ///
  /// Defaults to [FractionalOffset.topCenter].
  final FractionalOffsetGeometry alignment;

  /// A builder that positions the [firstChild] and [secondChild] widgets.
  ///
  /// The widget returned by this method is wrapped in an [AnimatedSize].
  ///
  /// By default, this uses [AnimatedCrossFade.defaultLayoutBuilder], which uses
  /// a [Stack] and aligns the `bottomChild` to the top of the stack while
  /// providing the `topChild` as the non-positioned child to fill the provided
  /// constraints. This works well when the [AnimatedCrossFade] is in a position
  /// to change size and when the children are not flexible. However, if the
  /// children are less fussy about their sizes (for example a
  /// [CircularProgressIndicator] inside a [Center]), or if the
  /// [AnimatedCrossFade] is being forced to a particular size, then it can
  /// result in the widgets jumping about when the cross-fade state is changed.
  final AnimatedCrossFadeBuilder layoutBuilder;

  /// The default layout algorithm used by [AnimatedCrossFade].
  ///
  /// The top child is placed in a stack that sizes itself to match the top
  /// child. The bottom child is positioned at the top of the same stack, sized
  /// to fit its width but without forcing the height. The stack is then
  /// clipped.
  ///
  /// This is the default value for [layoutBuilder]. It implements
  /// [AnimatedCrossFadeBuilder].
  static Widget defaultLayoutBuilder(Widget topChild, Key topChildKey,
      Widget bottomChild, Key bottomChildKey) {
    return new Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        new Positioned(
          key: bottomChildKey,
          left: 0.0,
          top: 0.0,
          right: 0.0,
          child: bottomChild,
        ),
        new Positioned(
          key: topChildKey,
          child: topChild,
        )
      ],
    );
  }

  @override
  _AnimatedCrossFadeState createState() => new _AnimatedCrossFadeState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(
        new EnumProperty<CrossFadeState>('crossFadeState', crossFadeState));
    description.add(new DiagnosticsProperty<FractionalOffsetGeometry>(
        'alignment', alignment, defaultValue: FractionalOffset.topCenter));
  }
}

class _AnimatedCrossFadeState extends State<AnimatedCrossFade>
    with TickerProviderStateMixin<AnimatedCrossFade> {
  AnimationController _controller;
  Animation<double> _firstAnimation;
  Animation<double> _secondAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
    new AnimationController(duration: widget.duration, vsync: this);
    if (widget.crossFadeState == CrossFadeState.showSecond)
      _controller.value = 1.0;
    _firstAnimation = _initAnimation(widget.firstCurve, true);
    _secondAnimation = _initAnimation(widget.secondCurve, false);
  }

  Animation<double> _initAnimation(Curve curve, bool inverted) {
    Animation<double> animation = new CurvedAnimation(
        parent: _controller,
        curve: curve
    );

    if (inverted) {
      animation = new Tween<double>(
          begin: 1.0,
          end: 0.0
      ).animate(animation);
    }

    animation.addStatusListener((AnimationStatus status) {
      setState(() {
        // Trigger a rebuild because it depends on _isTransitioning, which
        // changes its value together with animation status.
      });
    });

    return animation;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedCrossFade oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration)
      _controller.duration = widget.duration;
    if (widget.firstCurve != oldWidget.firstCurve)
      _firstAnimation = _initAnimation(widget.firstCurve, true);
    if (widget.secondCurve != oldWidget.secondCurve)
      _secondAnimation = _initAnimation(widget.secondCurve, false);
    if (widget.crossFadeState != oldWidget.crossFadeState) {
      switch (widget.crossFadeState) {
        case CrossFadeState.showFirst:
          _controller.reverse();
          break;
        case CrossFadeState.showSecond:
          _controller.forward();
          break;
      }
    }
  }

  /// Whether we're in the middle of cross-fading this frame.
  bool get _isTransitioning =>
      _controller.status == AnimationStatus.forward ||
          _controller.status == AnimationStatus.reverse;

  @override
  Widget build(BuildContext context) {
    const Key kFirstChildKey = const ValueKey<CrossFadeState>(
        CrossFadeState.showFirst);
    const Key kSecondChildKey = const ValueKey<CrossFadeState>(
        CrossFadeState.showSecond);
    final bool transitioningForwards = _controller.status ==
        AnimationStatus.completed ||
        _controller.status == AnimationStatus.forward;

    Key topKey;
    Widget topChild;
    Animation<double> topAnimation;
    Key bottomKey;
    Widget bottomChild;
    Animation<double> bottomAnimation;
    if (transitioningForwards) {
      topKey = kSecondChildKey;
      topChild = widget.secondChild;
      topAnimation = _secondAnimation;
      bottomKey = kFirstChildKey;
      bottomChild = widget.firstChild;
      bottomAnimation = _firstAnimation;
    } else {
      topKey = kFirstChildKey;
      topChild = widget.firstChild;
      topAnimation = _firstAnimation;
      bottomKey = kSecondChildKey;
      bottomChild = widget.secondChild;
      bottomAnimation = _secondAnimation;
    }

    bottomChild = new TickerMode(
      key: bottomKey,
      enabled: _isTransitioning,
      child: new ExcludeSemantics(
        excluding: true,
        // Always exclude the semantics of the widget that's fading out.
        child: new FadeTransition(
          opacity: bottomAnimation,
          child: bottomChild,
        ),
      ),
    );
    topChild = new TickerMode(
      key: topKey,
      enabled: true, // Top widget always has its animations enabled.
      child: new ExcludeSemantics(
        excluding: false,
        // Always publish semantics for the widget that's fading in.
        child: new FadeTransition(
          opacity: topAnimation,
          child: topChild,
        ),
      ),
    );
    return new ClipRect(
      child: new AnimatedSize(
        alignment: widget.alignment,
        duration: widget.duration,
        curve: widget.sizeCurve,
        vsync: this,
        child: widget.layoutBuilder(topChild, topKey, bottomChild, bottomKey),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(new EnumProperty<CrossFadeState>(
        'crossFadeState', widget.crossFadeState));
    description.add(new DiagnosticsProperty<AnimationController>(
        'controller', _controller, showName: false));
    description.add(new DiagnosticsProperty<FractionalOffsetGeometry>(
        'alignment', widget.alignment,
        defaultValue: FractionalOffset.topCenter));
  }
}