import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection_container.dart';
import '../store/post_trip_store.dart';
import '../widgets/post_trip_category_picker.dart';
import '../widgets/post_trip_destination_input.dart';
import '../widgets/post_trip_fee_input.dart';
import '../widgets/post_trip_header_banner.dart';
import '../widgets/post_trip_order_counter.dart';
import '../widgets/post_trip_pickup_input.dart';
import '../widgets/post_trip_section_label.dart';
import '../widgets/post_trip_submit_bar.dart';
import '../widgets/post_trip_time_row.dart';

class PostTripPage extends StatefulWidget {
  const PostTripPage({super.key});

  @override
  State<PostTripPage> createState() => _PostTripPageState();
}

class _PostTripPageState extends State<PostTripPage> {
  late final PostTripStore _store;

  final _destinationCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();
  final _pickupCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _store = sl<PostTripStore>();
  }

  @override
  void dispose() {
    _destinationCtrl.dispose();
    _feeCtrl.dispose();
    _pickupCtrl.dispose();
    super.dispose();
  }

  // ─── Pick Time ────────────────────────────────────────

  Future<void> _pickTime(bool isDeparture) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isDeparture
          ? (_store.departureTime ?? TimeOfDay.now())
          : (_store.returnTime ?? TimeOfDay.now()),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: Color(AppColors.primary),
                secondary: Color(AppColors.primary),
              ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    if (isDeparture) {
      _store.setDepartureTime(picked);
    } else {
      _store.setReturnTime(picked);
    }
  }

  // ─── Select Place ─────────────────────────────────────

  void _selectPlace(String place) {
    // strip leading emoji (2 chars + space)
    final clean = place.length > 2 ? place.substring(2) : place;
    _destinationCtrl.text = clean;
    _store.setDestination(clean);
  }

  // ─── Submit ───────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_store.isTimeValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกเวลาขาไปและขากลับด้วยนะ 🕐'),
          backgroundColor: AppColors.action,
        ),
      );
      return;
    }

    _store
      ..setDestination(_destinationCtrl.text)
      ..setFee(_feeCtrl.text)
      ..setPickupPoint(_pickupCtrl.text);

    await _store.submit();

    if (!mounted) return;

    if (_store.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: ${_store.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('🎉 ประกาศรับหิ้วเรียบร้อยแล้ว!'),
          backgroundColor: Color(AppColors.primary),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  // ─── Build ────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            // ── Header Banner ──────────────────────────────────────────
            const PostTripHeaderBanner(),
            const SizedBox(height: 20),

            // ── Step 1: Where ──────────────────────────────────────────
            const PostTripSectionLabel(
                step: '1', label: 'วันนี้คุณจะไปไหน?', icon: '📍'),
            const SizedBox(height: 12),
            PostTripDestinationInput(controller: _destinationCtrl),
            const SizedBox(height: 12),
            PostTripQuickSelectPlaces(onSelect: _selectPlace),
            const SizedBox(height: 16),

            // ── Step 2: When ───────────────────────────────────────────
            Observer(
              builder: (_) => PostTripTimeRow(
                departureTime: _store.departureTime,
                returnTime: _store.returnTime,
                onTapDeparture: () => _pickTime(true),
                onTapReturn: () => _pickTime(false),
              ),
            ),
            const SizedBox(height: 24),

            // ── Step 3: How many ───────────────────────────────────────
            const PostTripSectionLabel(
                step: '2', label: 'รับได้กี่เจ้า?', icon: '📦'),
            const SizedBox(height: 12),
            Observer(
              builder: (_) => PostTripOrderCounter(
                value: _store.maxOrders,
                onChanged: _store.setMaxOrders,
              ),
            ),
            const SizedBox(height: 20),

            // ── Step 4: Fee ────────────────────────────────────────────
            const PostTripSectionLabel(
                step: '3', label: 'ค่าหิ้วกี่บาท?', icon: '💰'),
            const SizedBox(height: 12),
            PostTripFeeInput(controller: _feeCtrl),
            const SizedBox(height: 24),

            // ── Step 5: Categories ─────────────────────────────────────
            const PostTripSectionLabel(
                step: '4',
                label: 'รับหิ้วของประเภทไหนบ้าง?',
                icon: '🏷️'),
            const SizedBox(height: 12),
            Observer(
              builder: (_) => PostTripCategoryPicker(
                selected: _store.selectedCategories,
                onToggle: _store.toggleCategory,
              ),
            ),
            const SizedBox(height: 24),

            // ── Step 6: Pickup point ───────────────────────────────────
            const PostTripSectionLabel(
                step: '5',
                label: 'จุดนัดรับ / เส้นทางขากลับ',
                icon: '🗺️'),
            const SizedBox(height: 12),
            PostTripPickupInput(controller: _pickupCtrl),
          ],
        ),
      ),
      bottomNavigationBar: Observer(
        builder: (_) => PostTripSubmitBar(
          onTap: _submit,
          isLoading: _store.isSubmitting,
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.bgPage,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: const Color(AppColors.textPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'ประกาศรับหิ้ว 🛵',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(AppColors.textPrimary),
        ),
      ),
      centerTitle: false,
    );
  }
}
