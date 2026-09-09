import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_shape.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/models/catalogue_store.dart';
import '../../../../../shared/widgets/app_chip.dart';
import '../../../../../shared/widgets/app_text_field.dart';

class PostTripDestinationInput extends StatelessWidget {
  const PostTripDestinationInput({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.hasSelection,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  /// Whether a shop has actually been chosen from the list. A typed name is how
  /// the list is narrowed; only a chosen shop carries the coordinate the trip
  /// needs, so the field says so rather than letting the submit fail.
  final bool hasSelection;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      hint: "พิมพ์ชื่อร้าน เช่น Lotus's, Big C, 7-Eleven",
      prefixIcon: Icons.search_rounded,
      textInputAction: TextInputAction.next,
      onChanged: onChanged,
      suffix: hasSelection
          ? const Icon(
              Icons.check_circle_rounded,
              size: AppMetrics.icon,
              // Teal: the field is confirming something, not asking for it.
              color: AppColors.trust,
            )
          : null,
      helper: hasSelection ? null : 'เลือกร้านจากรายการด้านล่าง',
      validator: (_) => hasSelection ? null : 'เลือกร้านปลายทางจากรายการ',
    );
  }
}

/// The shops to go to, from the catalogue rather than from a constant.
///
/// Nearest first when the device gave a fix, and narrowed by whatever has been
/// typed. Bled to the page edge so the last chip scrolls past the gutter rather
/// than looking clipped by it.
class PostTripQuickSelectPlaces extends StatelessWidget {
  const PostTripQuickSelectPlaces({
    super.key,
    required this.stores,
    required this.selectedId,
    required this.onSelect,
    this.isLoading = false,
  });

  final List<CatalogueStore> stores;
  final String? selectedId;
  final ValueChanged<CatalogueStore> onSelect;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading && stores.isEmpty) {
      return _Hint(text: 'กำลังค้นหาร้านใกล้คุณ…');
    }
    if (stores.isEmpty) {
      return _Hint(text: 'ไม่พบร้านที่ตรงกับที่พิมพ์ ลองพิมพ์ชื่อสั้นลง');
    }
    return AppChoiceChipRow(
      padding: EdgeInsets.zero,
      children: [
        for (final store in stores)
          AppChoiceChip(
            label: store.distanceLabel == null
                ? store.label
                : '${store.label} · ${store.distanceLabel}',
            selected: selectedId == store.id,
            onTap: () => onSelect(store),
          ),
      ],
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.x2),
      child: Text(
        text,
        style: AppText.caption.copyWith(color: AppColors.faint),
      ),
    );
  }
}
