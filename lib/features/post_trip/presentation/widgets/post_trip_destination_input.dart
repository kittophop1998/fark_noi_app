import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

// ─── Popular Destinations data ────────────────────────────────────────────────
const postTripPopularPlaces = [
  '🏬 ฟิวเจอร์พาร์ค',
  '🛒 Lotus\'s รังสิต',
  '🛍️ Big C รังสิต',
  '🏪 Makro รังสิต',
  '🌿 ตลาดนัดอินเตอร์โซน',
  '🍜 ตลาดรังสิต',
  '☕ ท่าน้ำนนท์',
];

class PostTripDestinationInput extends StatelessWidget {
  const PostTripDestinationInput({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'เช่น ฟิวเจอร์พาร์ค, Lotus\'s, ตลาดนัดอินเตอร์โซน',
        hintStyle: TextStyle(
            fontSize: 13, color: const Color(AppColors.textSecondary).withOpacity(0.6)),
        prefixIcon:
            const Icon(Icons.location_on_outlined, color: Color(AppColors.primary)),
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
          borderSide: const BorderSide(color: Color(AppColors.primary), width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'กรุณาระบุสถานที่ที่จะไป' : null,
    );
  }
}

class PostTripQuickSelectPlaces extends StatelessWidget {
  const PostTripQuickSelectPlaces({super.key, required this.onSelect});

  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: postTripPopularPlaces.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final place = postTripPopularPlaces[i];
          return InkWell(
            onTap: () => onSelect(place),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Color(AppColors.primary).withOpacity(0.3)),
              ),
              child: Text(
                place,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(AppColors.primary),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
