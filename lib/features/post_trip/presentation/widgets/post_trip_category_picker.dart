import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

// ─── Category data ────────────────────────────────────────────────────────────
const postTripCategories = [
  ('🍔', 'ของกิน'),
  ('👕', 'เสื้อผ้า'),
  ('🏬', 'ของในห้าง'),
  ('🥦', 'ของสด'),
  ('💊', 'ยา/เวชภัณฑ์'),
  ('📦', 'อื่นๆ'),
];

class PostTripCategoryPicker extends StatelessWidget {
  const PostTripCategoryPicker({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: postTripCategories.map((cat) {
        final isSelected = selected.contains(cat.$2);
        return GestureDetector(
          onTap: () => onToggle(cat.$2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.green : AppColors.card,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected ? AppColors.green : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.green.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              '${cat.$1}  ${cat.$2}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF1C1B1F),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
