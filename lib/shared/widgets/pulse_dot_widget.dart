import 'package:flutter/material.dart';

/// จุดกระพริบสีขาว — ใช้แสดงสถานะ Active บน bubble หรือ badge
///
/// มักใช้คู่กับ Container ที่มีพื้นหลังสี เช่น Active Trip Bubble
///
/// ตัวอย่างการใช้งาน:
/// ```dart
/// Row(
///   children: [
///     PulseDotWidget(color: Colors.white),
///     SizedBox(width: 5),
///     Text('กำลัง Active'),
///   ],
/// )
/// ```
class PulseDotWidget extends StatefulWidget {
  final Color color;
  final double size;

  const PulseDotWidget({
    super.key,
    this.color = Colors.white,
    this.size = 7,
  });

  @override
  State<PulseDotWidget> createState() => _PulseDotWidgetState();
}

class _PulseDotWidgetState extends State<PulseDotWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.4, end: 1.0).animate(_ctrl),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
