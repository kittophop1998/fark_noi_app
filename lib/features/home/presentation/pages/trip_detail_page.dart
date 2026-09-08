import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/prompt_pay_config.dart';
import '../../domain/entities/home_entity.dart';

// ─── Color shortcuts (all from AppColors) ────────────────────────────────────
const _kPrimary      = Color(AppColors.primary);
const _kPrimaryLight = AppColors.primaryLight;
const _kAction       = AppColors.action;
const _kActionLight  = AppColors.actionLight;
const _kError        = AppColors.error;
const _kErrorLight   = AppColors.errorLight;
const _kTextPrimary  = Color(AppColors.textPrimary);
const _kTextSecondary = Color(AppColors.textSecondary);
const _kBorder       = AppColors.border;
const _kBg           = AppColors.bgPage;

// ─── Payment Status ──────────────────────────────────────
enum _PaymentStatus { pending, waitingPayment, paid }

// ─── Mock Order Model ────────────────────────────────────
class _MockOrder {
  final String id;
  final String ordererName;
  final String ordererInitial;
  final String orderItems;
  final double estimatedPrice;
  double? actualPrice;
  _PaymentStatus status;

  _MockOrder({
    required this.id,
    required this.ordererName,
    required this.ordererInitial,
    required this.orderItems,
    required this.estimatedPrice,
    this.actualPrice,
    this.status = _PaymentStatus.pending,
  });
}

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
  bool _hasImage = false;
  _OutOfStockOption _outOfStockOption = _OutOfStockOption.substitute;

  HomeEntity get runner => widget.runner;

  // Mock ETA (departure + ~1.5 hrs)
  String get _eta {
    final parts = runner.departureTime.replaceAll(' น.', '').split(':');
    if (parts.length == 2) {
      int h = int.tryParse(parts[0]) ?? 0;
      int m = int.tryParse(parts[1]) ?? 0;
      final total = h * 60 + m + 90;
      return '${(total ~/ 60).toString().padLeft(2, '0')}:${(total % 60).toString().padLeft(2, '0')} น.';
    }
    return '—';
  }

  Future<void> _pickImage() async {
    setState(() => _hasImage = true);
  }

  void _confirmOrder() {
    final order = _orderController.text.trim();
    if (order.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาใส่รายการของที่ต้องการฝากซื้อก่อนนะครับ 😊'),
          backgroundColor: _kPrimary,
        ),
      );
      _focusOrder.requestFocus();
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
        price: _priceController.text.trim(),
        hasImage: _hasImage,
        outOfStockOption: _outOfStockOption,
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
            _TripInfoCard(runner: runner, eta: _eta),
            const SizedBox(height: 16),

            // 3. Available Items Section
            _AvailableSection(runner: runner),
            const SizedBox(height: 16),

            // 4. Order Input Area
            _OrderInputArea(
              orderController: _orderController,
              priceController: _priceController,
              focusOrder: _focusOrder,
              pickedImage: _hasImage,
              onPickImage: _pickImage,
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
                backgroundColor: isFull ? Colors.grey.shade200 : _kPrimaryLight,
                child: Text(
                  runner.avatarInitial,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isFull ? Colors.grey.shade500 : _kPrimary,
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
                        isFull ? Colors.red.shade400 : const Color(0xFF4CAF50),
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
                        color: const Color(0xFFFFC107),
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
              color: isFull ? Colors.red.shade50 : _kPrimaryLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isFull ? Colors.red.shade200 : _kPrimary.withOpacity(0.3),
              ),
            ),
            child: Text(
              isFull ? '🔴 ใกล้เต็มแล้ว' : '🟢 ว่างอยู่',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isFull ? Colors.red.shade700 : _kPrimary,
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
  final String eta;
  const _TripInfoCard({required this.runner, required this.eta});

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
                Row(
                  children: [
                    Expanded(
                      child: _TimeChip(
                        icon: Icons.flight_takeoff_rounded,
                        label: 'ออกเดินทาง',
                        time: runner.departureTime,
                        color: _kPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_forward_rounded,
                        color: _kTextSecondary, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TimeChip(
                        icon: Icons.home_rounded,
                        label: 'กลับถึงที่พัก',
                        time: eta,
                        color: _kAction,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _Divider(),
                const SizedBox(height: 12),
                _TripRow(
                  icon: Icons.payments_outlined,
                  iconColor: const Color(0xFF7B1FA2),
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
                  color: Colors.red),
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
                  color: isFull ? Colors.red.shade500 : _kPrimary,
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
                isFull ? Colors.red.shade400 : _kPrimary,
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
                  color: used ? Colors.grey.shade400 : _kPrimary,
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
  final bool pickedImage;
  final VoidCallback onPickImage;
  final _OutOfStockOption outOfStockOption;
  final ValueChanged<_OutOfStockOption> onOutOfStockChanged;

  const _OrderInputArea({
    required this.orderController,
    required this.priceController,
    required this.focusOrder,
    required this.pickedImage,
    required this.onPickImage,
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
                  fontSize: 13, color: Colors.grey.shade400, height: 1.5),
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
                  TextStyle(fontSize: 13, color: Colors.grey.shade400),
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
                  iconColor: Colors.red.shade400,
                  title: 'ไม่เอาเลย',
                  subtitle: 'ยกเลิกรายการนี้ถ้าหาไม่ได้',
                  selected: outOfStockOption == _OutOfStockOption.skip,
                  onTap: () =>
                      onOutOfStockChanged(_OutOfStockOption.skip),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Photo reference
          const Text(
            'แนบรูปสินค้าอ้างอิง (ไม่บังคับ)',
            style: TextStyle(
              fontSize: 12,
              color: _kTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onPickImage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: pickedImage ? 100 : 80,
              decoration: BoxDecoration(
                color: _kBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: pickedImage ? _kPrimary : _kBorder,
                  style: BorderStyle.solid,
                  width: pickedImage ? 1.5 : 1,
                ),
              ),
              child: pickedImage
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: _kPrimary, size: 28),
                        const SizedBox(height: 4),
                        const Text(
                          'แนบรูปแล้ว ✅  แตะเพื่อเปลี่ยน',
                          style: TextStyle(
                              fontSize: 12,
                              color: _kPrimary,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_photo_alternate_outlined,
                            color: _kPrimary, size: 24),
                        const SizedBox(height: 4),
                        Text(
                          'แตะเพื่อแนบรูป',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500),
                        ),
                      ],
                    ),
            ),
          ),
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
              color: selected ? iconColor : Colors.grey.shade400,
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
  final String price;
  final bool hasImage;
  final _OutOfStockOption outOfStockOption;

  const _ConfirmSheet({
    required this.runner,
    required this.order,
    required this.price,
    required this.hasImage,
    required this.outOfStockOption,
  });

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
                color: Colors.grey.shade300,
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
          if (price.isNotEmpty)
            _SummaryRow(label: 'ราคาประมาณ', value: '$price บาท'),
          _SummaryRow(
              label: 'รูปอ้างอิง', value: hasImage ? 'แนบแล้ว ✅' : 'ไม่มี'),
          _SummaryRow(
            label: 'ถ้าของหมด',
            value: outOfStockOption == _OutOfStockOption.substitute
                ? '🔄 เปลี่ยนเป็นอะไรก็ได้ที่มี'
                : '❌ ไม่เอาเลย',
          ),
          const SizedBox(height: 20),

          // Confirm button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                        '✅ ส่งคำขอฝากซื้อสำเร็จ! รอผู้รับฝากตอบรับนะครับ'),
                    backgroundColor: _kPrimary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _kAction,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'ยืนยัน ✓',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
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

// ────────────────────────────────────────────────────────
// 4. Orders Management Section
// ────────────────────────────────────────────────────────

class _OrdersManagementSection extends StatelessWidget {
  final List<_MockOrder> orders;
  final void Function(_MockOrder) onSummary;
  final void Function(_MockOrder) onConfirmPayment;

  const _OrdersManagementSection({
    required this.orders,
    required this.onSummary,
    required this.onConfirmPayment,
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
                  color: _kPrimaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_long_rounded,
                    size: 18, color: _kPrimary),
              ),
              const SizedBox(width: 10),
              const Text(
                'ออเดอร์ที่รับฝาก',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _kTextPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _kPrimaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${orders.length} ออเดอร์',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _kPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...orders.map((order) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _OrderCard(
                  order: order,
                  onSummary: () => onSummary(order),
                  onConfirmPayment: () => onConfirmPayment(order),
                ),
              )),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final _MockOrder order;
  final VoidCallback onSummary;
  final VoidCallback onConfirmPayment;

  const _OrderCard({
    required this.order,
    required this.onSummary,
    required this.onConfirmPayment,
  });

  Color get _statusColor {
    return switch (order.status) {
      _PaymentStatus.pending => _kPrimary,
      _PaymentStatus.waitingPayment => _kAction,
      _PaymentStatus.paid => _kPrimary,
    };
  }

  String get _statusLabel {
    return switch (order.status) {
      _PaymentStatus.pending => '✓ รับออเดอร์แล้ว',
      _PaymentStatus.waitingPayment => '⏳ รอชำระเงิน',
      _PaymentStatus.paid => '💰 ชำระแล้ว',
    };
  }

  @override
  Widget build(BuildContext context) {
    final isPaid = order.status == _PaymentStatus.paid;
    final isWaiting = order.status == _PaymentStatus.waitingPayment;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isPaid ? _kPrimaryLight.withOpacity(0.5) : _kBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _statusColor.withOpacity(0.3),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: avatar + name + status badge
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _statusColor.withOpacity(0.12),
                child: Text(
                  order.ordererInitial,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _statusColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'คุณ${order.ordererName}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _kTextPrimary,
                      ),
                    ),
                    if (isWaiting || isPaid)
                      Text(
                        'ยอด: ${(order.actualPrice! + PromptPayConfig.deliveryFee).toStringAsFixed(0)} บ. · ส่งข้อมูล PromptPay แล้ว',
                        style: TextStyle(
                          fontSize: 11,
                          color: _statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Order items
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_outlined,
                    size: 14, color: _kTextSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order.orderItems,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _kTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Action buttons
          if (!isPaid)
            Row(
              children: [
                if (!isWaiting) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.chat_bubble_outline_rounded,
                          size: 14),
                      label: Text('แชทกับ${order.ordererName}',
                          style: const TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kTextSecondary,
                        side: const BorderSide(color: _kBorder),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onSummary,
                      icon: const Icon(Icons.summarize_rounded, size: 14),
                      label: const Text('สรุปยอด',
                          style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ] else
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onConfirmPayment,
                      icon: const Icon(Icons.check_circle_rounded, size: 14),
                      label: const Text('ยืนยันรับเงิน',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kAction,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.check_circle_rounded, color: _kPrimary, size: 16),
                SizedBox(width: 6),
                Text(
                  'ชำระเงินเรียบร้อยแล้ว',
                  style: TextStyle(
                    fontSize: 13,
                    color: _kPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────
// Payment Summary Bottom Sheet
// ────────────────────────────────────────────────────────

class _PaymentSummarySheet extends StatefulWidget {
  final _MockOrder order;
  final void Function(double actualPrice) onConfirm;

  const _PaymentSummarySheet({
    required this.order,
    required this.onConfirm,
  });

  @override
  State<_PaymentSummarySheet> createState() => _PaymentSummarySheetState();
}

class _PaymentSummarySheetState extends State<_PaymentSummarySheet> {
  late final TextEditingController _actualPriceController =
      TextEditingController(
          text: widget.order.estimatedPrice.toStringAsFixed(0));

  double get _actualPrice =>
      double.tryParse(_actualPriceController.text.trim()) ?? 0;
  double get _total => _actualPrice + PromptPayConfig.deliveryFee;

  @override
  void dispose() {
    _actualPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(context).padding.bottom + 20),
        child: SingleChildScrollView(
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
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _kPrimaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        const Icon(Icons.summarize_rounded, color: _kPrimary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'สรุปยอดสำหรับคุณ${widget.order.ordererName}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _kTextPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Order items
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _kBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _kBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined,
                        size: 16, color: _kTextSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.order.orderItems,
                        style: const TextStyle(
                          fontSize: 14,
                          color: _kTextPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Actual price input
              const Text(
                'ราคาของจริง (บาท)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _kTextSecondary,
                ),
              ),
              const SizedBox(height: 6),
              StatefulBuilder(
                builder: (_, setInner) => TextField(
                  controller: _actualPriceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'กรอกราคาจริงที่ซื้อมา',
                    prefixIcon:
                        const Icon(Icons.attach_money_rounded, color: _kPrimary),
                    suffixText: 'บาท',
                    filled: true,
                    fillColor: _kBg,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 14),
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
              ),
              const SizedBox(height: 12),

              // Fee + Total breakdown
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _kPrimaryLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _kPrimary.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    _PriceRow(
                      label: 'ราคาสินค้า',
                      value: '${_actualPrice.toStringAsFixed(0)} บาท',
                    ),
                    const SizedBox(height: 6),
                    _PriceRow(
                      label: '+ ค่าหิ้ว',
                      value:
                          '${PromptPayConfig.deliveryFee.toStringAsFixed(0)} บาท',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1, color: _kPrimary),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ยอดรวมที่ต้องจ่าย',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _kPrimary,
                          ),
                        ),
                        Text(
                          '${_total.toStringAsFixed(0)} บาท',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: _kPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // PromptPay Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _kPrimary.withOpacity(0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: _kPrimaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.qr_code_rounded,
                              size: 18, color: _kPrimary),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'PromptPay',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _kPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _kPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'ของผู้รับหิ้ว',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _kPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _PromptPayRow(
                      icon: Icons.phone_rounded,
                      label: 'เบอร์โทรศัพท์',
                      value: PromptPayConfig.phone,
                      copyable: true,
                    ),
                    const SizedBox(height: 8),
                    _PromptPayRow(
                      icon: Icons.person_rounded,
                      label: 'ชื่อบัญชี',
                      value: PromptPayConfig.accountName,
                    ),
                    const SizedBox(height: 12),
                    // Mock QR placeholder
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _kPrimary.withOpacity(0.3)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.qr_code_2_rounded,
                                size: 60, color: _kPrimary),
                            const SizedBox(height: 4),
                            Text(
                              'QR PromptPay',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: _kPrimary.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kTextSecondary,
                        side: const BorderSide(color: _kBorder),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('ยกเลิก',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      onPressed: _actualPrice > 0
                          ? () => widget.onConfirm(_actualPrice)
                          : null,
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: const Text(
                        'ส่งยอดและแจ้งเตือน',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        elevation: 2,
                        shadowColor: _kPrimary.withOpacity(0.4),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  const _PriceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: _kTextSecondary)),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                color: _kTextPrimary,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _PromptPayRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool copyable;

  const _PromptPayRow({
    required this.icon,
    required this.label,
    required this.value,
    this.copyable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: _kPrimary),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                color: _kTextSecondary,
                fontWeight: FontWeight.w500)),
        const SizedBox(width: 6),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                color: _kPrimary,
                fontWeight: FontWeight.w700)),
        if (copyable) ...[
          const Spacer(),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('คัดลอกเบอร์แล้ว ✅'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _kPrimaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.copy_rounded, size: 12, color: _kPrimary),
                  SizedBox(width: 3),
                  Text('คัดลอก',
                      style: TextStyle(fontSize: 11, color: _kPrimary)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
