import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/my_trip_entity.dart';
import '../../data/datasources/my_trips_mock_datasource.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/prompt_pay_config.dart';

// ─── Color shortcuts (all from AppColors) ──────────────
const _kPrimary       = AppColors.primary;
const _kPrimaryLight  = AppColors.primarySoft;
const _kAction        = AppColors.warning;
const _kActionLight   = AppColors.warningSoft;
const _kError         = AppColors.error;
const _kErrorLight    = AppColors.errorSoft;
const _kBg            = AppColors.background;
const _kTextPrimary   = AppColors.text;
const _kTextSecondary = AppColors.muted;
const _kBorder        = AppColors.border;

// ─── Entry Point ────────────────────────────────────────

class MyTripsPage extends StatefulWidget {
  const MyTripsPage({super.key});

  @override
  State<MyTripsPage> createState() => _MyTripsPageState();
}

class _MyTripsPageState extends State<MyTripsPage>
    with SingleTickerProviderStateMixin {
  late MyTripEntity? _trip;
  late AnimationController _badgeAnim;

  // local state for finalPrice editing
  final Map<String, TextEditingController> _priceControllers = {};

  @override
  void initState() {
    super.initState();
    _badgeAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadTrip();
  }

  Future<void> _loadTrip() async {
    final trip = await MyTripsMockDataSource().getActiveTrip();
    if (!mounted) return;
    setState(() {
      _trip = trip;
      if (_trip != null) {
        for (final o in _trip!.orders) {
          _priceControllers[o.id] = TextEditingController(
            text: o.finalPrice != null ? o.finalPrice!.toStringAsFixed(0) : '',
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _badgeAnim.dispose();
    for (final c in _priceControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ─── Actions ────────────────────────────────────────

  void _closeAccepting() {
    if (_trip == null) return;
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'ปิดรับฝากออเดอร์?',
        body: 'หลังจากนี้จะไม่มีใครสามารถฝากซื้อกับคุณในทริปนี้ได้อีก',
        confirmLabel: 'ปิดรับฝาก',
        confirmColor: _kAction,
        onConfirm: () {
          setState(() => _trip = _trip!.copyWith(status: TripStatus.shopping));
        },
      ),
    );
  }

  void _markArrived() {
    if (_trip == null) return;
    setState(() {
      _trip = _trip!.copyWith(
        status: TripStatus.delivering,
        arrivedAt: DateTime.now(),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      _greenSnack(
          '📣 แจ้งเตือนไปยังทุกคนแล้ว: "ของมาถึงแล้ว รีบออกมารับได้เลย!"'),
    );
  }

  void _toggleChecked(MyOrderItem order) {
    setState(() {
      final idx = _trip!.orders.indexOf(order);
      _trip!.orders[idx] = order.copyWith(isChecked: !order.isChecked);
    });
  }

  void _toggleDelivered(MyOrderItem order) {
    setState(() {
      final idx = _trip!.orders.indexOf(order);
      _trip!.orders[idx] = order.copyWith(isDelivered: !order.isDelivered);
    });
  }

  void _openSummarySheet(MyOrderItem order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SummarySheet(
        order: order,
        controller: _priceControllers[order.id]!,
        onConfirm: (price) {
          setState(() {
            final idx = _trip!.orders.indexOf(order);
            _trip!.orders[idx] = order.copyWith(finalPrice: price);
          });
        },
      ),
    );
  }

  void _completeTrip() {
    if (_trip == null) return;
    // Check if arrived
    if (_trip!.status != TripStatus.delivering) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กด "ถึงจุดนัดรับแล้ว" ก่อนนะ'),
          backgroundColor: _kAction,
        ),
      );
      return;
    }

    final arrivedAt = _trip!.arrivedAt!;
    final now = DateTime.now();
    final diff = now.difference(arrivedAt).inMinutes;
    final isHighSpeed = diff <= 15;

    showDialog(
      context: context,
      builder: (_) => _CompleteDialog(
        isHighSpeed: isHighSpeed,
        onConfirm: () {
          setState(() => _trip = _trip!.copyWith(status: TripStatus.completed));
        },
      ),
    );
  }

  SnackBar _greenSnack(String msg) {
    return SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: _kPrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    );
  }

  // ─── Build ───────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_trip == null) {
      return _NoTripView(
        onCreateTrip: () => Navigator.pop(context),
      );
    }

    final trip = _trip!;
    final isCompleted = trip.status == TripStatus.completed;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildAppBar(trip),
      body: isCompleted
          ? _CompletedView(trip: trip)
          : _buildBody(trip),
    );
  }

  AppBar _buildAppBar(MyTripEntity trip) {
    return AppBar(
      backgroundColor: _kBg,
      elevation: 0,
      leading: const BackButton(color: _kTextPrimary),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ทริปไป ${trip.destination}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _kTextPrimary,
            ),
          ),
          Row(
            children: [
              Text(
                trip.status.emoji,
                style: const TextStyle(fontSize: 11),
              ),
              const SizedBox(width: 4),
              Text(
                trip.status.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _statusColor(trip.status),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(TripStatus s) {
    switch (s) {
      case TripStatus.accepting:   return _kPrimary;
      case TripStatus.shopping:    return _kAction;
      case TripStatus.delivering:  return const Color(0xFF1565C0);
      case TripStatus.completed:   return _kTextSecondary;
    }
  }

  Widget _buildBody(MyTripEntity trip) {
    final isDelivering = trip.status == TripStatus.delivering;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              // ── Trip Overview Card ────────────────────
              _TripOverviewCard(trip: trip, onClose: _closeAccepting),
              const SizedBox(height: 16),

              // ── Progress Bar ──────────────────────────
              _ChecklistProgress(trip: trip),
              const SizedBox(height: 16),

              // ── QR Section (delivering mode) ──────────
              if (isDelivering) ...[
                _QRSection(trip: trip),
                const SizedBox(height: 16),
              ],

              // ── Order List ────────────────────────────
              _SectionHeader(
                icon: isDelivering ? Icons.local_shipping_outlined : Icons.checklist_rounded,
                label: isDelivering
                    ? 'รอมารับของ (${trip.orders.length - trip.deliveredCount}/${trip.orders.length})'
                    : 'รายการสั่งซื้อ (${trip.checkedCount}/${trip.orders.length})',
              ),
              const SizedBox(height: 10),
              ...trip.orders.map((order) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: isDelivering
                        ? _DeliveryOrderCard(
                            order: order,
                            onToggleDelivered: _toggleDelivered,
                          )
                        : _ShoppingOrderCard(
                            order: order,
                            onToggle: _toggleChecked,
                            onSummary: _openSummarySheet,
                          ),
                  )),
            ],
          ),
        ),

        // ── Bottom Action Bar ─────────────────────────
        _BottomActionBar(
          trip: trip,
          onMarkArrived: _markArrived,
          onComplete: _completeTrip,
        ),
      ],
    );
  }
}

// ─── No Trip View ────────────────────────────────────────

class _NoTripView extends StatelessWidget {
  final VoidCallback onCreateTrip;
  const _NoTripView({required this.onCreateTrip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: const BackButton(color: _kTextPrimary),
        title: const Text(
          'ประกาศของฉัน',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _kTextPrimary,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: _kPrimaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shopping_bag_outlined,
                    size: 48, color: _kPrimary),
              ),
              const SizedBox(height: 24),
              const Text(
                'ยังไม่มีทริปที่เปิดอยู่',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _kTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'กดปุ่ม "เปิดรับฝาก" ในหน้าหลัก\nเพื่อเริ่มทริปแรกของคุณ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onCreateTrip,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('เปิดรับฝาก — ฉันจะไปซื้อของ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kAction,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Trip Overview Card ──────────────────────────────────

class _TripOverviewCard extends StatelessWidget {
  final MyTripEntity trip;
  final VoidCallback onClose;

  const _TripOverviewCard({required this.trip, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final isAccepting = trip.status == TripStatus.accepting;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E7B4B), Color(0xFF2E9D5E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _kPrimary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.store_mall_directory_outlined,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    trip.destination,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (isAccepting)
                  GestureDetector(
                    onTap: onClose,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.5), width: 1),
                      ),
                      child: const Text(
                        'ปิดรับฝาก',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Info row
            Row(
              children: [
                _InfoChip(
                    icon: Icons.access_time, label: trip.departureTime),
                const SizedBox(width: 8),
                _InfoChip(icon: Icons.flag_outlined, label: trip.eta),
                const SizedBox(width: 8),
                _InfoChip(
                    icon: Icons.location_on_outlined,
                    label: trip.pickupPoint,
                    flex: true),
              ],
            ),
            const SizedBox(height: 14),
            // Slot indicator
            Row(
              children: [
                Text(
                  'ออเดอร์: ${trip.filledSlots}/${trip.totalSlots} slot',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                _SlotDots(filled: trip.filledSlots, total: trip.totalSlots),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: trip.totalSlots > 0
                    ? (trip.filledSlots / trip.totalSlots).clamp(0.0, 1.0)
                    : 0.0,
                backgroundColor: Colors.white.withOpacity(0.25),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool flex;

  const _InfoChip(
      {required this.icon, required this.label, this.flex = false});

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white70),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
    return flex ? Expanded(child: chip) : chip;
  }
}

class _SlotDots extends StatelessWidget {
  final int filled;
  final int total;
  const _SlotDots({required this.filled, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        total,
        (i) => Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: i < filled
                ? Colors.white
                : Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ─── Checklist Progress ──────────────────────────────────

class _ChecklistProgress extends StatelessWidget {
  final MyTripEntity trip;
  const _ChecklistProgress({required this.trip});

  @override
  Widget build(BuildContext context) {
    final checked = trip.checkedCount;
    final total = trip.orders.length;
    final pct = total > 0 ? (checked / total * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: total > 0 ? checked / total : 0,
                  strokeWidth: 5,
                  backgroundColor: _kBorder,
                  valueColor: const AlwaysStoppedAnimation<Color>(_kPrimary),
                ),
                Center(
                  child: Text(
                    '$pct%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _kTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ซื้อแล้ว $checked/$total รายการ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: _kTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  checked == total && total > 0
                      ? '✅ ซื้อครบแล้ว พร้อมกลับ!'
                      : 'เหลือ ${total - checked} รายการที่ยังไม่ได้ซื้อ',
                  style: TextStyle(
                    fontSize: 12,
                    color: checked == total && total > 0
                        ? _kPrimary
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ──────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _kTextPrimary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: _kTextPrimary,
          ),
        ),
      ],
    );
  }
}

// ─── Shopping Order Card (Checklist mode) ────────────────

class _ShoppingOrderCard extends StatelessWidget {
  final MyOrderItem order;
  final ValueChanged<MyOrderItem> onToggle;
  final ValueChanged<MyOrderItem> onSummary;

  const _ShoppingOrderCard({
    required this.order,
    required this.onToggle,
    required this.onSummary,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = order.isChecked;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: isDone ? _kPrimaryLight : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? _kPrimary.withOpacity(0.4) : _kBorder,
          width: isDone ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Main row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox
                GestureDetector(
                  onTap: () => onToggle(order),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isDone ? _kPrimary : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: isDone ? _kPrimary : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: isDone
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _Avatar(initial: order.buyerInitial),
                          const SizedBox(width: 6),
                          Text(
                            order.buyerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: _kTextPrimary,
                            ),
                          ),
                          if (order.finalPrice != null) ...[
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _kPrimary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '฿${order.finalPrice!.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _kPrimary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        order.itemDescription,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDone
                              ? Colors.grey.shade500
                              : _kTextPrimary,
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : null,
                          height: 1.4,
                        ),
                      ),
                      if (order.note != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.sticky_note_2_outlined,
                                size: 12, color: _kAction),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                order.note!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _kAction,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _MiniTag(
                            label: order.outOfStockPref.label,
                            color: order.outOfStockPref ==
                                    OutOfStockPreference.substitute
                                ? _kAction
                                : _kError,
                          ),
                          if (order.estimatedPrice != null) ...[
                            const SizedBox(width: 6),
                            _MiniTag(
                              label:
                                  'ประมาณ ฿${order.estimatedPrice!.toStringAsFixed(0)}',
                              color: _kTextSecondary,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Action row
          Container(
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(
                      color: isDone
                          ? _kPrimary.withOpacity(0.2)
                          : _kBorder)),
            ),
            child: Row(
              children: [
                // Summary button
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => onSummary(order),
                    icon: const Icon(Icons.receipt_long_outlined, size: 14),
                    label: Text(
                      order.finalPrice != null
                          ? 'แก้ไขยอด'
                          : 'สรุปยอด',
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: _kPrimary,
                      textStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                Container(width: 1, height: 32, color: _kBorder),
                // Chat button
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('เปิดแชทกับ ${order.buyerName}...'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded,
                        size: 14),
                    label: Text('แชทกับ ${order.buyerName}'),
                    style: TextButton.styleFrom(
                      foregroundColor: _kTextSecondary,
                      textStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Delivery Order Card (Handover mode) ─────────────────

class _DeliveryOrderCard extends StatelessWidget {
  final MyOrderItem order;
  final ValueChanged<MyOrderItem> onToggleDelivered;

  const _DeliveryOrderCard(
      {required this.order, required this.onToggleDelivered});

  @override
  Widget build(BuildContext context) {
    final done = order.isDelivered;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: done ? _kPrimaryLight : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: done ? _kPrimary.withOpacity(0.4) : _kBorder,
            width: done ? 1.5 : 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
        leading: GestureDetector(
          onTap: () => onToggleDelivered(order),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: done ? _kPrimary : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: done ? _kPrimary : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: done
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 18)
                : null,
          ),
        ),
        title: Row(
          children: [
            _Avatar(initial: order.buyerInitial),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                order.buyerName,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: done ? Colors.grey.shade500 : _kTextPrimary,
                  decoration: done ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (order.finalPrice != null)
              Text(
                '฿${order.finalPrice!.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: done ? Colors.grey.shade400 : _kPrimary,
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            order.itemDescription,
            style: TextStyle(
              fontSize: 12,
              color: done ? Colors.grey.shade400 : Colors.grey.shade600,
              decoration: done ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        trailing: done
            ? const Icon(Icons.check_circle_rounded,
                color: _kPrimary, size: 22)
            : const Icon(Icons.radio_button_unchecked,
                color: Colors.grey, size: 22),
      ),
    );
  }
}

// ─── QR Section ──────────────────────────────────────────

class _QRSection extends StatelessWidget {
  final MyTripEntity trip;
  const _QRSection({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.qr_code_2_rounded,
                    color: Color(0xFF1565C0), size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QR พร้อมเพย์รับเงิน',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _kTextPrimary,
                      ),
                    ),
                    Text(
                      'ให้คนฝากสแกนจ่ายทันที',
                      style: TextStyle(fontSize: 12, color: _kTextSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // QR Placeholder
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorder, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CustomPaint(
                painter: _QRMockPainter(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'PromptPay: 091-234-5678',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF1565C0),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(
                  const ClipboardData(text: '0912345678'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('คัดลอกเลขพร้อมเพย์แล้ว')),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 14),
            label: const Text('คัดลอกเลข'),
            style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                textStyle: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

/// วาด QR mock pattern ด้วย CustomPainter
class _QRMockPainter extends CustomPainter {
  static final _rng = math.Random(42);
  static late final List<Offset> _cells;
  static bool _init = false;

  static void _buildCells(Size size) {
    if (_init) return;
    _init = true;
    const int count = 17;
    final cellSize = size.width / count;
    _cells = [];
    for (int r = 0; r < count; r++) {
      for (int c = 0; c < count; c++) {
        // corner finder patterns
        final inCorner = (r < 7 && c < 7) ||
            (r < 7 && c >= count - 7) ||
            (r >= count - 7 && c < 7);
        if (inCorner) {
          final onCornerEdge = (r < 7 && c < 7) &&
              (r == 0 || r == 6 || c == 0 || c == 6);
          final onCornerInner = r >= 2 && r <= 4 && c >= 2 && c <= 4;
          if (onCornerEdge || onCornerInner) {
            _cells.add(Offset(c * cellSize, r * cellSize));
          }
          continue;
        }
        if (_rng.nextBool()) {
          _cells.add(Offset(c * cellSize, r * cellSize));
        }
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _buildCells(size);
    final count = 17;
    final cellSize = size.width / count;
    final paint = Paint()..color = Colors.black;

    // draw finder patterns manually
    _drawFinder(canvas, paint, 0, 0, cellSize);
    _drawFinder(canvas, paint, (count - 7) * cellSize, 0, cellSize);
    _drawFinder(canvas, paint, 0, (count - 7) * cellSize, cellSize);

    // draw random data cells
    for (final cell in _cells) {
      canvas.drawRect(
        Rect.fromLTWH(cell.dx + 1, cell.dy + 1, cellSize - 2, cellSize - 2),
        paint,
      );
    }
  }

  void _drawFinder(Canvas canvas, Paint paint, double x, double y, double cs) {
    // outer 7×7 border
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = cs;
    canvas.drawRect(
        Rect.fromLTWH(x + cs / 2, y + cs / 2, 6 * cs, 6 * cs), paint);
    // inner 3×3
    paint.style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromLTWH(x + 2 * cs, y + 2 * cs, 3 * cs, 3 * cs), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Bottom Action Bar ───────────────────────────────────

class _BottomActionBar extends StatelessWidget {
  final MyTripEntity trip;
  final VoidCallback onMarkArrived;
  final VoidCallback onComplete;

  const _BottomActionBar({
    required this.trip,
    required this.onMarkArrived,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isDelivering = trip.status == TripStatus.delivering;
    final isShopping = trip.status == TripStatus.shopping;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4)),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 14,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDelivering) ...[
            // ปิดงาน
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onComplete,
                icon: const Icon(Icons.celebration_rounded),
                label: const Text('จบงานทริปนี้'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ),
          ] else if (isShopping) ...[
            // ถึงจุดนัดรับ
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onMarkArrived,
                icon: const Icon(Icons.location_on_rounded),
                label: const Text('ถึงจุดนัดรับแล้ว — แจ้งทุกคน'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 15),
                ),
              ),
            ),
          ] else ...[
            // Still accepting — show hint
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'กด "ปิดรับฝาก" ในการ์ดด้านบนก่อน จากนั้นระบบจะเปลี่ยนเป็นโหมดซื้อของ'),
                    ),
                  );
                },
                icon: const Icon(Icons.info_outline, size: 16),
                label: const Text('ปิดรับฝากก่อน แล้วเริ่มซื้อของ'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kTextSecondary,
                  side: const BorderSide(color: _kBorder),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Summary Sheet ───────────────────────────────────────

class _SummarySheet extends StatefulWidget {
  final MyOrderItem order;
  final TextEditingController controller;
  final ValueChanged<double> onConfirm;

  const _SummarySheet({
    required this.order,
    required this.controller,
    required this.onConfirm,
  });

  @override
  State<_SummarySheet> createState() => _SummarySheetState();
}

class _SummarySheetState extends State<_SummarySheet> {
  double get _actualPrice =>
      double.tryParse(widget.controller.text.trim()) ?? 0;
  double get _total => _actualPrice + PromptPayConfig.deliveryFee;

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
                    child: const Icon(Icons.summarize_rounded,
                        color: _kPrimary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'สรุปยอดสำหรับคุณ${widget.order.buyerName}',
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
                        widget.order.itemDescription,
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
                  controller: widget.controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'กรอกราคาจริงที่ซื้อมา',
                    prefixIcon: const Icon(Icons.attach_money_rounded,
                        color: _kPrimary),
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
                          border:
                              Border.all(color: _kPrimary.withOpacity(0.3)),
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
                          ? () {
                              widget.onConfirm(_actualPrice);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '📣 แจ้ง ${widget.order.buyerName} ยอด ฿${_actualPrice.toStringAsFixed(0)} แล้ว'),
                                  backgroundColor: _kPrimary,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.send_rounded, size: 16),
                      label: const Text(
                        'ส่งยอดและแจ้งลูกค้า',
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

// ─── Confirm Dialog ──────────────────────────────────────

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String body;
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;

  const _ConfirmDialog({
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
      content: Text(body,
          style: const TextStyle(color: _kTextSecondary, height: 1.5)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ยกเลิก',
              style: TextStyle(color: _kTextSecondary)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

// ─── Complete Dialog ─────────────────────────────────────

class _CompleteDialog extends StatelessWidget {
  final bool isHighSpeed;
  final VoidCallback onConfirm;

  const _CompleteDialog(
      {required this.isHighSpeed, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Text(isHighSpeed ? '⚡' : '🎉',
              style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'จบงานทริปนี้?',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ทริปนี้จะถูกย้ายไปที่ "ประวัติ" และระบบจะให้คะแนนรีวิวแก่คุณ',
            style: TextStyle(color: _kTextSecondary, height: 1.5),
          ),
          if (isHighSpeed) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF8E1), Color(0xFFFFF3E0)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _kAction.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Text('⚡', style: TextStyle(fontSize: 24)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'High Speed Picker!',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: _kAction,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'ส่งของได้ภายใน 15 นาที\nคุณได้รับเหรียญ "ไว" เพิ่ม!',
                          style: TextStyle(
                            fontSize: 12,
                            color: _kTextSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ยังไม่จบ',
              style: TextStyle(color: _kTextSecondary)),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          icon: const Icon(Icons.check_rounded),
          label: const Text('จบงานเลย'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _kPrimary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}

// ─── Completed View ──────────────────────────────────────

class _CompletedView extends StatelessWidget {
  final MyTripEntity trip;
  const _CompletedView({required this.trip});

  @override
  Widget build(BuildContext context) {
    final total = trip.orders.fold(
        0.0, (sum, o) => sum + (o.finalPrice ?? 0.0));

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                  color: _kPrimaryLight, shape: BoxShape.circle),
              child: const Icon(Icons.celebration_rounded,
                  size: 52, color: _kPrimary),
            ),
            const SizedBox(height: 24),
            const Text(
              '🎉 จบงานเรียบร้อย!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: _kTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ทริปไป ${trip.destination}',
              style: const TextStyle(fontSize: 14, color: _kTextSecondary),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kBorder),
              ),
              child: Column(
                children: [
                  _SummaryRow('จำนวนออเดอร์',
                      '${trip.orders.length} รายการ'),
                  const SizedBox(height: 8),
                  _SummaryRow('ยอดรวม',
                      '฿${total.toStringAsFixed(0)}'),
                  const SizedBox(height: 8),
                  _SummaryRow('Slot ที่ใช้',
                      '${trip.filledSlots}/${trip.totalSlots}'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _kActionLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kAction.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Text('⚡', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'เหรียญ High Speed Picker ถูกเพิ่มในโปรไฟล์แล้ว!',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _kAction,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.home_rounded),
                label: const Text('กลับหน้าหลัก'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 13, color: _kTextSecondary)),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary)),
      ],
    );
  }
}

// ─── Mini Tag ────────────────────────────────────────────

class _MiniTag extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

// ─── Price Row ───────────────────────────────────────────

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

// ─── PromptPay Row ───────────────────────────────────────

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
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

// ─── Avatar ──────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String initial;
  const _Avatar({required this.initial});

  static const _colors = [
    Color(0xFF1E7B4B),
    Color(0xFFF57C00),
    Color(0xFF1565C0),
    Color(0xFF6A1B9A),
    Color(0xFFAD1457),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[initial.codeUnitAt(0) % _colors.length];
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: color),
        ),
      ),
    );
  }
}
