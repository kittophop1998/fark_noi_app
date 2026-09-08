import 'package:flutter/material.dart';

import '../../../../../shared/widgets/app_text_field.dart';

class PostTripPickupInput extends StatelessWidget {
  const PostTripPickupInput({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      hint: 'เช่น "ผ่านหอทรงพิเชษฐ์ → จอดหน้าตึก SC" หรือ "นัดรับใต้ตึก C"',
      maxLines: 3,
      minLines: 3,
      // A hint about *why* the detail matters, kept as helper text rather than
      // as a notice: it is guidance on filling one field in, not a rule about
      // the product.
      helper: 'ยิ่งระบุชัด ยิ่งหากันเจอง่ายตอนส่งของ',
    );
  }
}
