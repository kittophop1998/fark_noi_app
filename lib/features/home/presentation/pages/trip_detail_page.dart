import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../orders/presentation/store/create_order_store.dart';
import '../../domain/entities/home_entity.dart';

// ─── Color shortcuts (all from AppColors) ────────────────────────────────────
const _kPrimary      = AppColors.primary;
const _kPrimaryLight = AppColors.primarySoft;
const _kAction       = AppColors.warning;
const _kActionLight  = AppColors.warningSoft;
const _kErrorLight   = AppColors.errorSoft;
const _kTextPrimary  = AppColors.text;
const _kTextSecondary = AppColors.muted;
const _kBorder       = AppColors.border;
const _kBg           = AppColors.background;

// ────────────────────────────────────────────────────────
// Trip Detail Page
// ────────────────────────────────────────────────────────

class TripDetailPage extends StatefulWidget {
  final HomeEntity runner;

  const TripDetailPage({super.key, required this.runner});

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

enum _OutOfStockOption { substitute, skip }

class _TripDetailPageState extends State<TripDetailPage> {
  final _orderController = TextEditingController();
  final _priceController = TextEditingController();
  final _focusOrder = FocusNode();
  late final CreateOrderStore _store = sl<CreateOrderStore>();
  _OutOfStockOption _outOfStockOption = _OutOfStockOption.substitute;

  HomeEntity get runner => widget.runner;

  void _confirmOrder() {
    final order = _orderController.text.trim();
    if (order.isEmpty) {
      _warn('กรุณาใส่รายการของที่ต้องการฝากซื้อก่อนนะครับ 😊');
      _focusOrder.requestFocus();
      return;
    }
    // The estimate is the ceiling the runner may spend, and the figure the
    // requester's credit is held against — so unlike in the mock it is not
    // optional. Anything unspent comes back when the errand settles.
    final price = int.tryParse(_priceController.text.trim()) ?? 0;
    if (price <= 0) {
      _warn('ใส่ราคาประมาณของรายการนี้ด้วยนะ เพื่อกันวงเงินให้ผู้เดินทาง');
      return;
    }
    if (!runner.isOpen) {
      _warn('ทริปนี้ปิดรับฝากแล้ว');
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ConfirmSheet(
        runner: runner,
        order: order,
        price: price,
        outOfStockOption: _outOfStockOption,
        store: _store,
        onDone: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _warn(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _kPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _orderController.dispose();
    _priceController.dispose();
    _focusOrder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      // ── AppBar ─────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _kTextPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'รายละเอียดการรับฝาก',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _kTextPrimary,
          ),
        ),
        centerTitle: true,
      ),

      // ── Body ───────────────────────────────────────────
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
          children: [
            // 1. Header Profile
            _ProfileHeader(runner: runner),
            const SizedBox(height: 16),

            // 2. Trip Info Card
            _TripInfoCard(runner: runner),
            const SizedBox(height: 16),

            // 3. Available Items Section
            _AvailableSection(runner: runner),
            const SizedBox(height: 16),

            // 4. Order Input Area
            _OrderInputArea(
              orderController: _orderController,
              priceController: _priceController,
              focusOrder: _focusOrder,
              outOfStockOption: _outOfStockOption,
              onOutOfStockChanged: (val) =>
                  setState(() => _outOfStockOption = val),
            ),
          ],
        ),
      ),

      // ── Sticky Bottom Bar ──────────────────────────────
      bottomNavigationBar: _BottomBar(onConfirm: _confirmOrder),
    );
  }
}

// ────────────────────────────────────────────────────────
// 1. Profile Header
// ────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final HomeEntity runner;
  const _ProfileHeader({required this.runner});

  @override
  Widget build(BuildContext context) {
    final isFull = runner.isFull;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: isFull ? AppColors.surfaceStrong : _kPrimaryLight,
                child: Text(
                  runner.avatarInitial,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isFull ? AppColors.faint : _kPrimary,
                  ),
                ),
              ),
              Positioned(
                bottom: 1,
                right: 1,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color:
                        isFull ? AppColors.error : AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Name + Rating
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  runner.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _kTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (i) => Icon(
                        i < 4 ? Icons.star_rounded : Icons.star_half_rounded,
                        size: 15,
                        color: AppColors.rating,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '4.8 (24 รีวิว)',
                      style: TextStyle(
                        fontSize: 12,
                        color: _kTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isFull ? AppColors.errorSoft : _kPrimaryLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isFull ? AppColors.errorBorder : _kPrimary.withOpacity(0.3),
              ),
            ),
            child: Text(
              isFull ? '🔴 ใกล้เต็มแล้ว' : '🟢 ว่างอยู่',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isFull ? AppColors.errorStrong : _kPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// 2. Trip Info Card
// ────────────────────────────────────────────────────────

class _TripInfoCard extends StatelessWidget {
  final HomeEntity runner;
  const _TripInfoCard({required this.runner});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card Header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_kPrimary, _kPrimary],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.route_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'ข้อมูลการเดินทาง',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Card Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _TripRow(
                  icon: Icons.store_rounded,
                  iconColor: _kPrimary,
                  label: 'ไปที่',
                  value: runner.destination,
                  valueBold: true,
                ),
                const SizedBox(height: 12),
                const _Divider(),
                const SizedBox(height: 12),
                _TripRow(
                  icon: Icons.location_on_rounded,
                  iconColor: _kAction,
                  label: 'จุดนัดรับของ',
                  value: runner.dormitory,
                  valueBold: true,
                  highlight: true,
                ),
                const SizedBox(height: 12),
                const _Divider(),
                const SizedBox(height: 12),
                // The API publishes when a trip leaves, never when the runner
                // is back — a guessed return time is the one number here
                // somebody would actually plan around, so only the real
                // departure is shown.
                SizedBox(
                  width: double.infinity,
                  child: _TimeChip(
                    icon: Icons.flight_takeoff_rounded,
                    label: 'ออกเดินทาง',
                    time: runner.departureTime,
                    color: _kPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const _Divider(),
                const SizedBox(height: 12),
                _TripRow(
                  icon: Icons.payments_outlined,
                  iconColor: AppColors.secondary,
                  label: 'ค่าบริการ',
                  value: 'ค่าหิ้วเริ่มต้น 20 บาท/ออเดอร์',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TripRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool valueBold;
  final bool highlight;

  const _TripRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueBold = false,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: _kTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: highlight
                    ? const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3)
                    : EdgeInsets.zero,
                decoration: highlight
                    ? BoxDecoration(
                        color: _kActionLight,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: _kAction.withOpacity(0.3)),
                      )
                    : null,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: valueBold
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: highlight ? _kAction : _kTextPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  final Color color;

  const _TimeChip({
    required this.icon,
    required this.label,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color.withOpacity(0.8)),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: _kBorder);
}

// ────────────────────────────────────────────────────────
// 3. Available Items Section
// ────────────────────────────────────────────────────────

class _AvailableSection extends StatelessWidget {
  final HomeEntity runner;
  const _AvailableSection({required this.runner});

  @override
  Widget build(BuildContext context) {
    final available = runner.availableSlots;
    final isFull = runner.isFull;
    final progress = runner.filledSlots / runner.totalSlots;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _kPrimaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.inventory_2_outlined,
                    size: 18, color: _kPrimary),
              ),
              const SizedBox(width: 10),
              const Text(
                'รับฝากอะไรได้บ้าง?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _kTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _ItemTag(
                  icon: Icons.restaurant_menu_rounded,
                  label: 'รับเฉพาะอาหาร',
                  color: _kPrimary),
              _ItemTag(
                  icon: Icons.no_luggage_rounded,
                  label: 'ไม่รับของหนัก',
                  color: AppColors.error),
              _ItemTag(
                  icon: Icons.production_quantity_limits_rounded,
                  label: 'สูงสุด 3 ชิ้น',
                  color: _kAction),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'คิวที่ว่าง',
                style: TextStyle(
                  fontSize: 12,
                  color: _kTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                isFull
                    ? 'เต็มแล้ว!'
                    : 'ว่างอีก $available / ${runner.totalSlots} ที่',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isFull ? AppColors.error : _kPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: _kBorder,
              valueColor: AlwaysStoppedAnimation<Color>(
                isFull ? AppColors.error : _kPrimary,
              ),
            ),
          ),

          // Slot dots
          const SizedBox(height: 10),
          Row(
            children: List.generate(runner.totalSlots, (i) {
              final used = i < runner.filledSlots;
              return Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: used ? AppColors.disabled : _kPrimary,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ItemTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ItemTag(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// 4. Order Input Area
// ────────────────────────────────────────────────────────

class _OrderInputArea extends StatelessWidget {
  final TextEditingController orderController;
  final TextEditingController priceController;
  final FocusNode focusOrder;
  final _OutOfStockOption outOfStockOption;
  final ValueChanged<_OutOfStockOption> onOutOfStockChanged;

  const _OrderInputArea({
    required this.orderController,
    required this.priceController,
    required this.focusOrder,
    required this.outOfStockOption,
    required this.onOutOfStockChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _kActionLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_note_rounded,
                    size: 20, color: _kAction),
              ),
              const SizedBox(width: 10),
              const Text(
                'สั่งเลย! 🛒',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _kTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Order text field
          TextField(
            controller: orderController,
            focusNode: focusOrder,
            maxLines: 3,
            textInputAction: TextInputAction.newline,
            style: const TextStyle(
                fontSize: 14, color: _kTextPrimary),
            decoration: InputDecoration(
              hintText:
                  'คุณอยากฝากซื้ออะไร?\nเช่น ข้าวผัดกะเพราไข่ดาว ไม่เผ็ด ไม่ใส่ผัก',
              hintStyle: TextStyle(
                  fontSize: 13, color: AppColors.disabled, height: 1.5),
              filled: true,
              fillColor: _kBg,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: _kPrimary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Estimated price
          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            style: const TextStyle(
                fontSize: 14, color: _kTextPrimary),
            decoration: InputDecoration(
              hintText: 'ราคาประมาณการ (บาท)',
              hintStyle:
                  TextStyle(fontSize: 13, color: AppColors.disabled),
              prefixIcon:
                  const Icon(Icons.attach_money_rounded, color: _kPrimary),
              filled: true,
              fillColor: _kBg,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: _kPrimary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Out-of-stock Option ──────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _kBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.help_outline_rounded,
                        size: 15, color: _kTextSecondary),
                    SizedBox(width: 6),
                    Text(
                      'ถ้าของที่สั่งหมด / ไม่มี...',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _kTextPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _OutOfStockOptionTile(
                  icon: Icons.swap_horiz_rounded,
                  iconColor: _kPrimary,
                  title: 'เปลี่ยนเป็นอะไรก็ได้ที่มี',
                  subtitle: 'ให้ผู้รับฝากเลือกให้ตามสมควร',
                  selected:
                      outOfStockOption == _OutOfStockOption.substitute,
                  onTap: () =>
                      onOutOfStockChanged(_OutOfStockOption.substitute),
                ),
                const SizedBox(height: 8),
                _OutOfStockOptionTile(
                  icon: Icons.remove_shopping_cart_outlined,
                  iconColor: AppColors.error,
                  title: 'ไม่เอาเลย',
                  subtitle: 'ยกเลิกรายการนี้ถ้าหาไม่ได้',
                  selected: outOfStockOption == _OutOfStockOption.skip,
                  onTap: () =>
                      onOutOfStockChanged(_OutOfStockOption.skip),
                ),
              ],
            ),
          ),
          // A reference photograph belongs here — "the blue one, this size" is
          // a question one picture settles, and the API takes it as an
          // `imageMediaId` on the item. It is not offered yet because it needs
          // the media upload pipeline (`POST /media/upload-sessions`), and a
          // control that only pretended to attach one is worse than none.
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// Out-of-Stock Option Tile
// ────────────────────────────────────────────────────────

class _OutOfStockOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _OutOfStockOptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? iconColor.withOpacity(0.07) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? iconColor : _kBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 17, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selected ? iconColor : _kTextPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: _kTextSecondary),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 20,
              color: selected ? iconColor : AppColors.disabled,
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// 5. Sticky Bottom Bar
// ────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final VoidCallback onConfirm;
  const _BottomBar({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _kBorder, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onConfirm,
          icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
          label: const Text(
            'ยืนยันฝากซื้อ',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _kAction,
            foregroundColor: Colors.white,
            elevation: 3,
            shadowColor: _kAction.withOpacity(0.4),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// Confirm Bottom Sheet
// ────────────────────────────────────────────────────────

class _ConfirmSheet extends StatelessWidget {
  final HomeEntity runner;
  final String order;
  final int price;
  final _OutOfStockOption outOfStockOption;
  final CreateOrderStore store;

  /// Closes the sheet and the trip behind it. Passed in rather than popped
  /// here, because the sheet's own `context` is gone by the time the request
  /// comes back.
  final VoidCallback onDone;

  const _ConfirmSheet({
    required this.runner,
    required this.order,
    required this.price,
    required this.outOfStockOption,
    required this.store,
    required this.onDone,
  });

  /// The instruction the requester chose, as the sentence the runner will read.
  /// The API has no field for it — it is free text on the order, which is where
  /// somebody standing in a shop actually looks.
  String get _note => outOfStockOption == _OutOfStockOption.substitute
      ? 'ถ้าของหมด: เปลี่ยนเป็นอะไรก็ได้ที่ใกล้เคียง'
      : 'ถ้าของหมด: ไม่ต้องซื้อทดแทน';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: _kPrimary, size: 22),
              SizedBox(width: 8),
              Text(
                'ยืนยันการฝากซื้อ',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _kTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Summary
          _SummaryRow(label: 'ฝากกับ', value: runner.name),
          _SummaryRow(label: 'ไปที่', value: runner.destination),
          _SummaryRow(label: 'รายการ', value: order),
          _SummaryRow(label: 'วงเงินสูงสุด', value: '$price บาท'),
          if (runner.feeSatang != null)
            _SummaryRow(
              label: 'ค่าหิ้ว',
              value: '${runner.feeSatang! ~/ 100} บาท',
            ),
          _SummaryRow(
            label: 'ถ้าของหมด',
            value: outOfStockOption == _OutOfStockOption.substitute
                ? '🔄 เปลี่ยนเป็นอะไรก็ได้ที่มี'
                : '❌ ไม่เอาเลย',
          ),
          const SizedBox(height: 20),

          // Confirm button
          Observer(
            builder: (_) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (store.hasError) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _kErrorLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.errorBorder),
                    ),
                    child: Text(
                      store.errorMessage!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.errorStrong,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                ElevatedButton(
                  onPressed: store.isSubmitting
                      ? null
                      : () => _submit(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        _kPrimary.withOpacity(0.45),
                    disabledForegroundColor:
                        Colors.white.withOpacity(0.45),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: store.isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'ยืนยัน ✓',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final placed = await store.submit(
      trip: runner,
      itemName: order,
      quantity: 1,
      expectedPrice: price,
      note: _note,
    );
    // A refusal keeps the sheet open with the server's own sentence on it —
    // every one of them (a full trip, a closed trip, not enough credit) is
    // something the requester can act on, and closing the sheet would take the
    // form they would have to fill in again with it.
    if (!placed) return;
    messenger.showSnackBar(
      SnackBar(
        content: const Text('✅ ส่งคำขอฝากซื้อสำเร็จ! รอผู้รับฝากตอบรับนะครับ'),
        backgroundColor: AppColors.successFill,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
    onDone();
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 13,
                  color: _kTextSecondary,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 13,
                  color: _kTextPrimary,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
