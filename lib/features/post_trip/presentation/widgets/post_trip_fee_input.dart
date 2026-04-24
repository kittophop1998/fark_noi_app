import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/constants/app_colors.dart';

class PostTripFeeInput extends StatelessWidget {
  const PostTripFeeInput({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        hintText: 'เช่น 10, 20 หรือตามตกลง',
        hintStyle: TextStyle(
            fontSize: 13,
            color: const Color(0xFF49454F).withOpacity(0.6)),
        prefixIcon:
            const Icon(Icons.payments_outlined, color: AppColors.orange),
        suffixText: 'บาท/ออเดอร์',
        suffixStyle: const TextStyle(
            fontSize: 13,
            color: Color(0xFF49454F),
            fontWeight: FontWeight.w500),
        filled: true,
        fillColor: AppColors.card,
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
              const BorderSide(color: AppColors.orange, width: 1.8),
        ),
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'กรุณาระบุค่าหิ้ว' : null,
    );
  }
}
