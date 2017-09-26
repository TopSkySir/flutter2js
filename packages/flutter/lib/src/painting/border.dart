// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/ui.dart' as ui show lerpDouble;

import 'basic_types.dart';
import 'border_radius.dart';
import 'decoration.dart';
import 'edge_insets.dart';

export 'edge_insets.dart' show EdgeInsets;

/// The shape to use when rendering a [Border] or [BoxDecoration].
enum BoxShape {
  /// An axis-aligned, 2D rectangle. May have rounded corners (described by a
  /// [BorderRadius]). The edges of the rectangle will match the edges of the box
  /// into which the [Border] or [BoxDecoration] is painted.
  rectangle,

  /// A circle centered in the middle of the box into which the [Border] or
  /// [BoxDecoration] is painted. The diameter of the circle is the shortest
  /// dimension of the box, either the width or the height, such that the circle
  /// touches the edges of the box.
  circle,
}

/// The style of line to draw for a [BorderSide] in a [Border].
enum BorderStyle {
  /// Skip the border.
  none,

  /// Draw the border as a solid line.
  solid,

  // if you add more, think about how they will lerp
}

/// A side of a border of a box.
///
/// A [Border] consists of four [BorderSide] objects: [Border.top],
/// [Border.left], [Border.right], and [Border.bottom].
///
/// ## Sample code
///
/// This sample shows how [BorderSide] objects can be used in a [Container], via
/// a [BoxDecoration] and a [Border], to decorate some [Text]. In this example,
/// the text has a thick bar above it that is light blue, and a thick bar below
/// it that is a darker shade of blue.
///
/// ```dart
/// new Container(
///   padding: new EdgeInsets.all(8.0),
///   decoration: new BoxDecoration(
///     border: new Border(
///       top: new BorderSide(width: 16.0, color: Colors.lightBlue.shade50),
///       bottom: new BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
///     ),
///   ),
///   child: new Text('Flutter in the sky', textAlign: TextAlign.center),
/// )
/// ```
///
/// See also:
///
///  * [Border], which uses [BorderSide] objects to represent its sides.
///  * [BoxDecoration], which optionally takes a [Border] object.
///  * [TableBorder], which extends [Border] to have two more sides
///    ([TableBorder.horizontalInside] and [TableBorder.verticalInside]), both
///    of which are also [BorderSide] objects.
@immutable
class BorderSide {
  /// Creates the side of a border.
  ///
  /// By default, the border is 1.0 logical pixels wide and solid black.
  const BorderSide({this.color: const Color(0xFF000000),
    this.width: 1.0,
    this.style: BorderStyle.solid});

  /// The color of this side of the border.
  final Color color;

  /// The width of this side of the border, in logical pixels. A
  /// zero-width border is a hairline border. To omit the border
  /// entirely, set the [style] to [BorderStyle.none].
  final double width;

  /// The style of this side of the border.
  ///
  /// To omit a side, set [style] to [BorderStyle.none]. This skips
  /// painting the border, but the border still has a [width].
  final BorderStyle style;

  /// A hairline black border that is not rendered.
  static const BorderSide none =
  const BorderSide(width: 0.0, style: BorderStyle.none);

  /// Creates a copy of this border but with the given fields replaced with the new values.
  BorderSide copyWith({Color color, double width, BorderStyle style}) {
    return new BorderSide(
        color: color ?? this.color,
        width: width ?? this.width,
        style: style ?? this.style);
  }

  /// Linearly interpolate between two border sides.
  static BorderSide lerp(BorderSide a, BorderSide b, double t) {
    assert(a != null);
    assert(b != null);
    if (t == 0.0) return a;
    if (t == 1.0) return b;
    if (a.style == b.style) {
      return new BorderSide(
          color: Color.lerp(a.color, b.color, t),
          width: ui.lerpDouble(a.width, b.width, t),
          style: a.style // == b.style
      );
    }
    Color colorA, colorB;
    switch (a.style) {
      case BorderStyle.solid:
        colorA = a.color;
        break;
      case BorderStyle.none:
        colorA = a.color.withAlpha(0x00);
        break;
    }
    switch (b.style) {
      case BorderStyle.solid:
        colorB = b.color;
        break;
      case BorderStyle.none:
        colorB = b.color.withAlpha(0x00);
        break;
    }
    return new BorderSide(
      color: Color.lerp(colorA, colorB, t),
      width: ui.lerpDouble(a.width, b.width, t),
      style: BorderStyle.solid,
    );
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final BorderSide typedOther = other;
    return color == typedOther.color &&
        width == typedOther.width &&
        style == typedOther.style;
  }

  @override
  int get hashCode => hashValues(color, width, style);

  @override
  String toString() => 'BorderSide($color, $width, $style)';
}

/// A border of a box, comprised of four sides.
///
/// The sides are represented by [BorderSide] objects.
///
/// ## Sample code
///
/// All four borders the same, two-pixel wide solid white:
///
/// ```dart
/// new Border.all(width: 2.0, color: const Color(0xFFFFFFFF))
/// ```
///
/// The border for a material design divider:
///
/// ```dart
/// new Border(bottom: new BorderSide(color: Theme.of(context).dividerColor))
/// ```
///
/// A 1990s-era "OK" button:
///
/// ```dart
/// new Container(
///   decoration: const BoxDecoration(
///     border: const Border(
///       top: const BorderSide(width: 1.0, color: const Color(0xFFFFFFFFFF)),
///       left: const BorderSide(width: 1.0, color: const Color(0xFFFFFFFFFF)),
///       right: const BorderSide(width: 1.0, color: const Color(0xFFFF000000)),
///       bottom: const BorderSide(width: 1.0, color: const Color(0xFFFF000000)),
///     ),
///   ),
///   child: new Container(
///     padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
///     decoration: const BoxDecoration(
///       border: const Border(
///         top: const BorderSide(width: 1.0, color: const Color(0xFFFFDFDFDF)),
///         left: const BorderSide(width: 1.0, color: const Color(0xFFFFDFDFDF)),
///         right: const BorderSide(width: 1.0, color: const Color(0xFFFF7F7F7F)),
///         bottom: const BorderSide(width: 1.0, color: const Color(0xFFFF7F7F7F)),
///       ),
///       color: const Color(0xFFBFBFBF),
///     ),
///     child: const Text(
///       'OK',
///       textAlign: TextAlign.center,
///       style: const TextStyle(color: const Color(0xFF000000))
///     ),
///   ),
/// )
/// ```
///
/// See also:
///
///  * [BoxDecoration], which uses this class to describe its edge decoration.
///  * [BorderSide], which is used to describe each side of the box.
///  * [Theme], from the material layer, which can be queried to obtain appropriate colors
///    to use for borders in a material app, as shown in the "divider" sample above.
@immutable
class Border {
  /// Creates a border.
  ///
  /// All the sides of the border default to [BorderSide.none].
  const Border({
    this.top: BorderSide.none,
    this.right: BorderSide.none,
    this.bottom: BorderSide.none,
    this.left: BorderSide.none,
  });

  /// A uniform border with all sides the same color and width.
  ///
  /// The sides default to black solid borders, one logical pixel wide.
  factory Border.all({
    Color color: const Color(0xFF000000),
    double width: 1.0,
    BorderStyle style: BorderStyle.solid,
  }) {
    final BorderSide side =
    new BorderSide(color: color, width: width, style: style);
    return new Border(top: side, right: side, bottom: side, left: side);
  }

  /// The top side of this border.
  final BorderSide top;

  /// The right side of this border.
  final BorderSide right;

  /// The bottom side of this border.
  final BorderSide bottom;

  /// The left side of this border.
  final BorderSide left;

  /// The widths of the sides of this border represented as an [EdgeInsets].
  ///
  /// This can be used, for example, with a [Padding] widget to inset a box by
  /// the size of these borders.
  EdgeInsets get dimensions {
    return new EdgeInsets.fromLTRB(
        left.width, top.width, right.width, bottom.width);
  }

  /// Whether all four sides of the border are identical. Uniform borders are
  /// typically more efficient to paint.
  bool get isUniform {
    assert(top != null);
    assert(right != null);
    assert(bottom != null);
    assert(left != null);

    final Color topColor = top.color;
    if (right.color != topColor ||
        bottom.color != topColor ||
        left.color != topColor) return false;

    final double topWidth = top.width;
    if (right.width != topWidth ||
        bottom.width != topWidth ||
        left.width != topWidth) return false;

    final BorderStyle topStyle = top.style;
    if (right.style != topStyle ||
        bottom.style != topStyle ||
        left.style != topStyle) return false;

    return true;
  }

  /// Creates a new border with the widths of this border multiplied by `t`.
  Border scale(double t) {
    return new Border(
        top: top.copyWith(width: t * top.width),
        right: right.copyWith(width: t * right.width),
        bottom: bottom.copyWith(width: t * bottom.width),
        left: left.copyWith(width: t * left.width));
  }

  /// Linearly interpolate between two borders.
  ///
  /// If a border is null, it is treated as having four [BorderSide.none]
  /// borders.
  static Border lerp(Border a, Border b, double t) {
    if (a == null && b == null) return null;
    if (a == null) return b.scale(t);
    if (b == null) return a.scale(1.0 - t);
    return new Border(
        top: BorderSide.lerp(a.top, b.top, t),
        right: BorderSide.lerp(a.right, b.right, t),
        bottom: BorderSide.lerp(a.bottom, b.bottom, t),
        left: BorderSide.lerp(a.left, b.left, t));
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final Border typedOther = other;
    return top == typedOther.top &&
        right == typedOther.right &&
        bottom == typedOther.bottom &&
        left == typedOther.left;
  }

  @override
  int get hashCode => hashValues(top, right, bottom, left);

  @override
  String toString() {
    if (isUniform) return 'Border.all($top)';
    return 'Border($top, $right, $bottom, $left)';
  }
}
