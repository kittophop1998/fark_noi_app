import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class PostTripTimeRow extends StatelessWidget {
  const PostTripTimeRow({
    super.key,
    required this.departureTime,
    required this.returnTime,
    required this.onTapDeparture,
    required this.onTapReturn,
  });

  final TimeOfDay? departureTime;
  final TimeOfDay? returnTime;
  final VoidCallback onTapDeparture;
  final VoidCallback onTapReturn;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TimeCard(
            label: '🛫 ออกจากที่นี่',
            subtitle: 'เวลาขาไป',
            time: departureTime,
            color: AppColors.green,
            bgColor: AppColors.greenLight,
            onTap: onTapDeparture,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TimeCard(
            label: '🏠 ถึงจุดนัดรับ',
            subtitle: 'ETA ขากลับ',
            time: returnTime,
            color: AppColors.orange,
            bgColor: AppColors.orangeLight,
            onTap: onTapReturn,
          ),
        ),
      ],
    );
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.label,
    required this.subtitle,
    required this.time,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final TimeOfDay? time;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasTime = time != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: hasTime ? bgColor : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasTime ? color : AppColors.border,
            width: hasTime ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: hasTime ? color : const Color(0xFF49454F),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: 18,
                    color: hasTime ? color : const Color(0xFF49454F)),
                const SizedBox(width: 6),
                Text(
                  hasTime ? time!.format(context) : '-- : --',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: hasTime ? color : const Color(0xFF49454F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: (hasTime ? color : const Color(0xFF49454F))
                    .withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
