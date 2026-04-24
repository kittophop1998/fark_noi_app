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
            fontSize: 13, color: const Color(0xFF49454F).withOpacity(0.6)),
        prefixIcon:
            const Icon(Icons.location_on_outlined, color: AppColors.green),
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
          borderSide: const BorderSide(color: AppColors.green, width: 1.8),
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
                color: AppColors.greenLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.green.withOpacity(0.3)),
              ),
              child: Text(
                place,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.green,
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
