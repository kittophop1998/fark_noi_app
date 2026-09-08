import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../../../core/di/injection_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_shape.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/app_badge.dart';
import '../../../../../shared/widgets/app_button.dart';
import '../../../../../shared/widgets/app_notice.dart';
import '../../../../../shared/widgets/app_page.dart';
import '../../../../../shared/widgets/app_page_header.dart';
import '../../../../../shared/widgets/app_section.dart';
import '../store/post_trip_store.dart';
import '../widgets/post_trip_category_picker.dart';
import '../widgets/post_trip_destination_input.dart';
import '../widgets/post_trip_fee_input.dart';
import '../widgets/post_trip_order_counter.dart';
import '../widgets/post_trip_pickup_input.dart';
import '../widgets/post_trip_time_row.dart';

/// Opening a trip: telling the neighbourhood you are already going that way.
///
/// A form, so the header is `neutral` — **lower the decoration as the stakes
/// rise**, and this screen is where somebody commits to carrying other people's
/// shopping. The one filled coral action is the submit in the sticky footer,
/// and nothing above it competes.
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

  /// Set when the user submits with no times chosen. The time fields are not
  /// `TextFormField`s, so the form's own validator cannot reach them — and a
  /// snack bar alone would say the sentence somewhere the eye is not.
  bool _timeMissing = false;

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

  Future<void> _pickTime(bool isDeparture) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isDeparture
          ? (_store.departureTime ?? TimeOfDay.now())
          : (_store.returnTime ?? TimeOfDay.now()),
    );
    if (picked == null) return;
    if (isDeparture) {
      _store.setDepartureTime(picked);
    } else {
      _store.setReturnTime(picked);
    }
    if (_store.isTimeValid && _timeMissing) {
      setState(() => _timeMissing = false);
    }
  }

  void _selectPlace(String place) {
    _destinationCtrl.text = place;
    _store.setDestination(place);
  }

  Future<void> _submit() async {
    final fieldsValid = _formKey.currentState!.validate();
    if (!_store.isTimeValid) {
      setState(() => _timeMissing = true);
      return;
    }
    if (!fieldsValid) return;

    _store
      ..setDestination(_destinationCtrl.text)
      ..setFee(_feeCtrl.text)
      ..setPickupPoint(_pickupCtrl.text);

    await _store.submit();
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    if (_store.hasError) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('เปิดทริปไม่สำเร็จ: ${_store.errorMessage}'),
          backgroundColor: AppColors.errorFill,
        ),
      );
      return;
    }

    messenger.showSnackBar(
      const SnackBar(
        content: Text('เปิดทริปเรียบร้อย รอคนมาฝากซื้อได้เลย'),
        backgroundColor: AppColors.successFill,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'เปิดทริปใหม่',
      tone: PageHeaderTone.neutral,
      showBell: false,
      showBack: true,
      onBack: () => Navigator.of(context).pop(),
      footer: Observer(
        builder: (_) => AppButton(
          label: 'เปิดทริป',
          size: AppButtonSize.large,
          fullWidth: true,
          loading: _store.isSubmitting,
          onPressed: _submit,
        ),
      ),
      child: Form(
        key: _formKey,
        child: AppPageContent(
          children: [
            AppSection(
              title: 'จะไปไหน',
              subtitle: 'ร้านหรือย่านที่คุณกำลังจะไป',
              child: Column(
                children: [
                  PostTripDestinationInput(controller: _destinationCtrl),
                  const SizedBox(height: AppSpace.x3),
                  Observer(
                    builder: (_) => PostTripQuickSelectPlaces(
                      selected: _store.destination,
                      onSelect: _selectPlace,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.sectionGap),

            AppSection(
              title: 'ไปกี่โมง กลับกี่โมง',
              subtitle: 'ผู้ฝากใช้เวลานี้ตัดสินใจว่าจะทันไหม',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Observer(
                    builder: (_) => PostTripTimeRow(
                      departureTime: _store.departureTime,
                      returnTime: _store.returnTime,
                      onTapDeparture: () => _pickTime(true),
                      onTapReturn: () => _pickTime(false),
                    ),
                  ),
                  if (_timeMissing) ...[
                    const SizedBox(height: AppSpace.x3),
                    const AppNotice(
                      tone: AppTone.error,
                      message: 'เลือกเวลาขาไปและเวลาถึงจุดนัดรับก่อนเปิดทริป',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpace.sectionGap),

            AppSection(
              title: 'รับได้กี่รายการ',
              child: Observer(
                builder: (_) => PostTripOrderCounter(
                  value: _store.maxOrders,
                  onChanged: _store.setMaxOrders,
                ),
              ),
            ),
            const SizedBox(height: AppSpace.sectionGap),

            AppSection(
              title: 'ค่าหิ้ว',
              child: PostTripFeeInput(controller: _feeCtrl),
            ),
            const SizedBox(height: AppSpace.sectionGap),

            AppSection(
              title: 'รับหิ้วของแบบไหน',
              subtitle: 'เลือกได้มากกว่าหนึ่งอย่าง',
              child: Observer(
                builder: (_) => PostTripCategoryPicker(
                  selected: _store.selectedCategories,
                  onToggle: _store.toggleCategory,
                ),
              ),
            ),
            const SizedBox(height: AppSpace.sectionGap),

            AppSection(
              title: 'จุดนัดรับ',
              subtitle: 'เส้นทางขากลับ และตรงไหนที่คุณจอดรับได้',
              child: PostTripPickupInput(controller: _pickupCtrl),
            ),
            const SizedBox(height: AppSpace.x6),

            // The last word before the committing action: what opening a trip
            // actually promises somebody else.
            Text(
              'เมื่อเปิดทริปแล้ว ผู้ฝากจะเห็นทริปของคุณและส่งรายการมาให้ '
              'คุณเลือกรับหรือปฏิเสธได้ทีละรายการ',
              style: AppText.caption.copyWith(color: AppColors.faint),
            ),
          ],
        ),
      ),
    );
  }
}
