import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/app_text_field.dart';

class PostTripFeeInput extends StatelessWidget {
  const PostTripFeeInput({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      hint: 'เช่น 10 หรือ 20',
      keyboardType: TextInputType.number,
      prefixIcon: Icons.payments_outlined,
      // The unit belongs to the field, not to the number the user types — so it
      // sits in the control rather than in the hint, where it would disappear
      // the moment they started typing.
      suffix: Text(
        'บาท/รายการ',
        style: AppText.bodySmall.copyWith(color: AppColors.faint),
      ),
      helper: 'ค่าหิ้วต่อ 1 รายการ ผู้ฝากจะเห็นตัวเลขนี้ก่อนตัดสินใจ',
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'กรุณาระบุค่าหิ้ว' : null,
    );
  }
}
