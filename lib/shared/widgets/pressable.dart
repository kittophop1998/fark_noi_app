import 'package:flutter/material.dart';

import '../../core/theme/app_shape.dart';

/// The product's one "something moved" affordance.
///
/// The web spends a 1% scale over 120ms on every control and card, and nothing
/// else — motion confirms a press, it does not decorate. This is that gesture,
/// so a card and a button on the same screen answer a thumb identically.
///
/// It is a `GestureDetector` rather than an `InkWell` on purpose: a Material
/// ripple spreading across a 16px-radius card is a second, louder motion
/// language, and the two read as two different products.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.99,
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;

  /// How far the press travels. 1% is the product's step; a control small
  /// enough that 1% is invisible may ask for a little more.
  final double scale;

  final HitTestBehavior behavior;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool value) {
    if (widget.onTap == null || _down == value) return;
    setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTap: widget.onTap,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: AppMotion.fast,
        curve: AppMotion.ease,
        child: widget.child,
      ),
    );
  }
}
