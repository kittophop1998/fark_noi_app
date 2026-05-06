import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// แสดง badge จำนวนการแจ้งเตือนบน icon
///
/// - [count] = 0  → ซ่อน
/// - [count] = 1  → แสดงจุดสีแดง
/// - [count] > 1  → แสดงตัวเลข (สูงสุด 99+)
///
/// ตัวอย่างการใช้งาน:
/// ```dart
/// Stack(
///   clipBehavior: Clip.none,
///   children: [
///     IconButton(icon: Icon(Icons.notifications_outlined), onPressed: ...),
///     Positioned(
///       right: 8, top: 8,
///       child: NotiBadge(count: unreadCount),
///     ),
///   ],
/// )
/// ```
class NotiBadge extends StatelessWidget {
  final int count;

  const NotiBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final showNumber = count > 1;
    return Container(
      width: showNumber ? null : 9,
      height: showNumber ? null : 9,
      padding: showNumber
          ? const EdgeInsets.symmetric(horizontal: 5, vertical: 1)
          : null,
      decoration: BoxDecoration(
        color: AppColors.action,
        shape: showNumber ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: showNumber ? BorderRadius.circular(8) : null,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: showNumber
          ? Text(
              count > 99 ? '99+' : '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            )
          : null,
    );
  }
}
