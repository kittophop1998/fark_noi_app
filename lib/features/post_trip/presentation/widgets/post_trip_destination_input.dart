import 'package:flutter/material.dart';

import '../../../../../core/theme/app_shape.dart';
import '../../../../../shared/widgets/app_chip.dart';
import '../../../../../shared/widgets/app_text_field.dart';

/// The places most trips go, as presets.
///
/// Chips rather than a dropdown: these are a shortcut past typing, and a
/// reader flicks through them. Emoji are kept out of the label and drawn as the
/// chip's leading glyph, so a long place name truncates at the name.
const postTripPopularPlaces = <(String, String)>[
  ('🏬', 'ฟิวเจอร์พาร์ค'),
  ('🛒', "Lotus's รังสิต"),
  ('🛍️', 'Big C รังสิต'),
  ('🏪', 'Makro รังสิต'),
  ('🌿', 'ตลาดนัดอินเตอร์โซน'),
  ('🍜', 'ตลาดรังสิต'),
  ('☕', 'ท่าน้ำนนท์'),
];

class PostTripDestinationInput extends StatelessWidget {
  const PostTripDestinationInput({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      hint: "เช่น ฟิวเจอร์พาร์ค, Lotus's, ตลาดนัดอินเตอร์โซน",
      prefixIcon: Icons.location_on_outlined,
      textInputAction: TextInputAction.next,
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'กรุณาระบุสถานที่ที่จะไป' : null,
    );
  }
}

/// The presets, bled to the page edge so the last one scrolls past the gutter
/// rather than looking clipped by it.
class PostTripQuickSelectPlaces extends StatelessWidget {
  const PostTripQuickSelectPlaces({
    super.key,
    required this.onSelect,
    required this.selected,
  });

  final ValueChanged<String> onSelect;
  final String selected;

  @override
  Widget build(BuildContext context) {
    return AppChoiceChipRow(
      padding: EdgeInsets.zero,
      children: [
        for (final place in postTripPopularPlaces)
          AppChoiceChip(
            label: place.$2,
            selected: selected == place.$2,
            leading: Text(place.$1, style: const TextStyle(fontSize: 13)),
            onTap: () => onSelect(place.$2),
          ),
      ],
    );
  }
}
