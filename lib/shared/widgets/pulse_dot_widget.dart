import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A dot that says "right now".
///
/// The one live signal in the product — a trip still accepting requests, a
/// runner on their way. It is [AppColors.success] by default, the same green
/// the route's origin uses, because both mean "this is real and it is
/// happening".
///
/// Motion is the exception the design system allows for state, not decoration:
/// a pulse that never resolves is only legitimate because it *is* the state.
class PulseDotWidget extends StatefulWidget {
  const PulseDotWidget({
    super.key,
    this.color = AppColors.success,
    this.size = 8,
    this.active = true,
  });

  final Color color;
  final double size;

  /// A settled dot rather than a pulsing one — the same mark, not animating.
  final bool active;

  @override
  State<PulseDotWidget> createState() => _PulseDotWidgetState();
}

class _PulseDotWidgetState extends State<PulseDotWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(PulseDotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.active && _ctrl.isAnimating) {
      // Stops on the resting state, never mid-fade.
      _ctrl.stop();
      _ctrl.value = 1;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
    );

    if (!widget.active) return dot;

    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
      ),
      child: dot,
    );
  }
}
