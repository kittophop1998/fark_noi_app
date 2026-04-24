import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class PostTripOrderCounter extends StatelessWidget {
  const PostTripOrderCounter({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'จำนวนออเดอร์สูงสุด',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1B1F),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'เพื่อไม่ให้ของหนักเกินไปตอนแบกกลับ',
                  style: TextStyle(
                      fontSize: 11, color: Color(0xFF49454F)),
                ),
              ],
            ),
          ),
          _CounterButton(
            icon: Icons.remove_rounded,
            onTap: value > 1 ? () => onChanged(value - 1) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$value',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.green,
              ),
            ),
          ),
          _CounterButton(
            icon: Icons.add_rounded,
            onTap: value < 20 ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? AppColors.greenLight : AppColors.bgPage,
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled
                ? AppColors.green.withOpacity(0.4)
                : AppColors.border,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? AppColors.green
              : const Color(0xFF49454F).withOpacity(0.4),
        ),
      ),
    );
  }
}
