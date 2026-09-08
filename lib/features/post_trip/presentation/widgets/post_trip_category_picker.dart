import 'package:flutter/material.dart';

import '../../../../../core/theme/app_shape.dart';
import '../../../../../shared/widgets/app_chip.dart';

/// What this runner is willing to carry.
const postTripCategories = <(String, String)>[
  ('🍔', 'ของกิน'),
  ('👕', 'เสื้อผ้า'),
  ('🏬', 'ของในห้าง'),
  ('🥦', 'ของสด'),
  ('💊', 'ยา/เวชภัณฑ์'),
  ('📦', 'อื่นๆ'),
];

/// Several choices from a few, so chips rather than a radio group — and they
/// wrap rather than scroll, because the whole set has to be visible before a
/// reader can decide which of them apply.
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
      spacing: AppSpace.x2,
      runSpacing: AppSpace.x2,
      children: [
        for (final category in postTripCategories)
          AppChoiceChip(
            label: category.$2,
            selected: selected.contains(category.$2),
            leading: Text(category.$1, style: const TextStyle(fontSize: 13)),
            onTap: () => onToggle(category.$2),
          ),
      ],
    );
  }
}
