import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

class PostTripPickupInput extends StatelessWidget {
  const PostTripPickupInput({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(
        hintText:
            'เช่น "ผ่านหอทรงพิเชษฐ์ → จอดหน้าตึก SC" หรือ "นัดรับใต้ตึก C ได้เลย"',
        hintStyle: TextStyle(
            fontSize: 12,
            color: const Color(AppColors.textSecondary).withOpacity(0.6),
            height: 1.5),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 42),
          child: Icon(Icons.alt_route_rounded, color: Color(AppColors.primary)),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(AppColors.primary), width: 1.8),
        ),
      ),
    );
  }
}
