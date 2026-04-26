import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class PostTripSectionLabel extends StatelessWidget {
  const PostTripSectionLabel({
    super.key,
    required this.step,
    required this.label,
    required this.icon,
  });

  final String step;
  final String label;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(AppColors.primary),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            step,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$icon  $label',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
