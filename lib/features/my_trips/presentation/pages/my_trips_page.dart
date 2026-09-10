import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:flutter_mobx/flutter_mobx.dart';

import '../../domain/entities/my_trip_entity.dart';
import '../store/my_trips_store.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/promptpay_qr.dart';
import '../../../../shared/services/media_upload_service.dart';
import '../../../../shared/widgets/app_states.dart';

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
  late final MyTripsStore _store;
  late AnimationController _badgeAnim;

  /// The trip is the store's, not this widget's. Read through a getter so the
  /// two thousand lines below keep the shape they had when it was a field.
  MyTripEntity? get _trip => _store.trip;

  // local state for finalPrice editing
  final Map<String, TextEditingController> _priceControllers = {};

  @override
  void initState() {
    super.initState();
    _store = sl<MyTripsStore>();
    _badgeAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadTrip();
  }

  Future<void> _loadTrip() async {
    await _store.load();
    if (!mounted) return;
    // One controller per errand, created on arrival and reused across reloads —
    // a fresh controller on every read would drop whatever the runner was
    // halfway through typing into it.
    for (final order in _trip?.orders ?? const <MyOrderItem>[]) {
      _controllerFor(order);
    }
    setState(() {});
  }

  /// The price controller for one errand, created on first use.
  ///
  /// [_loadTrip] warms this map for every order already on the trip, but an
  /// order the runner just accepted reaches the checklist through the store's
  /// own reload — not through [_loadTrip] — so a controller cannot be assumed
  /// to exist yet by the time the summary sheet opens for it.
  TextEditingController _controllerFor(MyOrderItem order) {
    return _priceControllers.putIfAbsent(
      order.id,
      () => TextEditingController(
        text: order.finalPrice?.toStringAsFixed(0) ?? '',
      ),
    );
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
        // `POST /trips/{id}/start`. Past this the trip takes no new requests —
        // which is exactly what the dialog above promised.
        onConfirm: () async {
          final ok = await _store.startTrip();
          if (!mounted) return;
          if (!ok) _showError();
        },
      ),
    );
  }

  /// The server's own sentence, in the one place a failed milestone can be seen.
  void _showError() {
    final message = _store.errorMessage;
    if (message == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorFill,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
    _store.clearError();
  }

  void _markArrived() {
    if (_trip == null) return;
    // The app's own milestone: the API has no trip-level "I am back at the
    // meeting point" state, and this is the moment the runner announces to
    // everybody waiting at once. See [TripStatus.delivering].
    _store.markArrivedAtPickup();
    ScaffoldMessenger.of(context).showSnackBar(
      _greenSnack(
          '📣 แจ้งเตือนไปยังทุกคนแล้ว: "ของมาถึงแล้ว รีบออกมารับได้เลย!"'),
    );
  }

  Future<void> _acceptOrder(MyOrderItem order) async {
    final ok = await _store.acceptOrder(order.id);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        _greenSnack('รับคำฝากของคุณ${order.buyerName}แล้ว'),
      );
    } else {
      _showError();
    }
  }

  Future<void> _rejectOrder(MyOrderItem order) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => _RejectDialog(buyerName: order.buyerName),
    );
    if (reason == null) return;
    final ok = await _store.rejectOrder(order.id, reason: reason);
    if (!mounted) return;
    if (!ok) _showError();
  }

  void _openSummarySheet(MyOrderItem order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SummarySheet(
        order: order,
        controller: _controllerFor(order),
        onConfirm: (price, proofMediaIds) async {
          var ok = await _store.purchaseOrder(
            order,
            actualPrice: price,
            proofMediaIds: proofMediaIds,
          );
          if (ok) {
            // The runner is done at this shop the moment the receipt is
            // recorded — this app has no separate "left the store" tap, so
            // PURCHASED moves straight to DELIVERING. Its own failure has to
            // sink `ok`: the receipt was recorded either way, but the sheet's
            // success message and dismissal are wrong if the order is still
            // sitting in PURCHASED.
            ok = await _store.startDelivery(order.id);
          }
          if (!mounted) return false;
          if (!ok) _showError();
          return ok;
        },
      ),
    );
  }

  Future<void> _confirmDelivery(MyOrderItem order) async {
    final proof = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DeliveryProofSheet(order: order),
    );
    if (proof == null || proof.isEmpty || !mounted) return;
    final ok = await _store.deliverOrder(order.id, proofMediaIds: proof);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        _greenSnack('ส่งของให้คุณ${order.buyerName}แล้ว รอยืนยันรับเงิน'),
      );
    } else {
      _showError();
    }
  }

  Future<void> _confirmPaymentReceived(MyOrderItem order) async {
    final ok = await _store.completeOrder(order.id);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        _greenSnack('ยืนยันรับเงินจากคุณ${order.buyerName}แล้ว 🎉'),
      );
    } else {
      _showError();
    }
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
        // `POST /trips/{id}/complete`. The journey is over and every errand on
        // it settles with it.
        onConfirm: () async {
          final ok = await _store.completeTrip();
          if (!mounted) return;
          if (!ok) _showError();
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
    return Observer(
      builder: (_) {
        if (_store.isLoading && _trip == null) {
          return const Scaffold(
            backgroundColor: _kBg,
            body: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: SkeletonList(),
            ),
          );
        }
        if (_store.hasError && _trip == null) {
          return Scaffold(
            backgroundColor: _kBg,
            body: ErrorState(
              message: _store.errorMessage!,
              onRetry: _loadTrip,
            ),
          );
        }
        if (_trip == null) {
          return _NoTripView(
            onCreateTrip: () => Navigator.pop(context),
          );
        }

        final trip = _trip!;

        return Scaffold(
          backgroundColor: _kBg,
          appBar: _buildAppBar(trip),
          body: trip.isFinished
              ? _CompletedView(trip: trip)
              : _buildBody(trip),
        );
      },
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
      case TripStatus.delivering:  return AppColors.info;
      case TripStatus.completed:   return _kTextSecondary;
      // A cancelled trip is not a failure to warn about, it is a trip that is
      // over — so it takes the same quiet grey a finished one does rather than
      // the error red. The label beside it is what says which ending it was.
      case TripStatus.cancelled:   return _kTextSecondary;
    }
  }

  Widget _buildBody(MyTripEntity trip) {
    final isDelivering = trip.status == TripStatus.delivering;
    final pending = trip.orders.where((o) => o.isPending).toList();
    final active = trip.orders.where((o) => !o.isPending && !o.isClosed).toList();
    final closed = trip.orders.where((o) => o.isClosed).toList();
    final deliveredCount = active.where((o) => o.isAwaitingPayment || o.isCompleted).length;
    final purchasedCount = active.where((o) => !o.isPending).length;

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
                const _QRSection(),
                const SizedBox(height: 16),
              ],

              // ── Pending Requests ───────────────────────
              if (pending.isNotEmpty) ...[
                _SectionHeader(
                  icon: Icons.mark_email_unread_outlined,
                  label: 'คำขอใหม่ (${pending.length})',
                ),
                const SizedBox(height: 10),
                ...pending.map((order) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _PendingOrderCard(
                        order: order,
                        onAccept: () => _acceptOrder(order),
                        onReject: () => _rejectOrder(order),
                      ),
                    )),
                const SizedBox(height: 16),
              ],

              // ── Order List ────────────────────────────
              _SectionHeader(
                icon: isDelivering ? Icons.local_shipping_outlined : Icons.checklist_rounded,
                label: isDelivering
                    ? 'รอมารับของ ($deliveredCount/${active.length})'
                    : 'รายการสั่งซื้อ ($purchasedCount/${active.length})',
              ),
              const SizedBox(height: 10),
              if (active.isEmpty)
                const _EmptyActiveOrders()
              else
                ...active.map((order) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: isDelivering
                          ? _DeliveryOrderCard(
                              order: order,
                              onDeliver: () => _confirmDelivery(order),
                              onConfirmPayment: () =>
                                  _confirmPaymentReceived(order),
                            )
                          : _ShoppingOrderCard(
                              order: order,
                              onSummary: () => _openSummarySheet(order),
                            ),
                    )),
              if (closed.isNotEmpty) ...[
                const SizedBox(height: 16),
                _SectionHeader(
                  icon: Icons.block_rounded,
                  label: 'ปฏิเสธ/ยกเลิก (${closed.length})',
                ),
                const SizedBox(height: 10),
                ...closed.map((order) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ClosedOrderRow(order: order),
                    )),
              ],
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
                  color: AppColors.muted,
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
        // Teal, not coral. This hero states *what is happening* — the trip you
        // are running — while the committing action below it is coral. Two
        // filled corals stacked would leave the screen with no primary.
        gradient: const LinearGradient(
          colors: [AppColors.secondaryHover, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
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
    final total = trip.activeOrders.length;
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
                        : AppColors.muted,
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
  final VoidCallback onSummary;

  const _ShoppingOrderCard({
    required this.order,
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
                // Checkbox — reflects the order's real status; tapping it
                // opens the same "สรุปยอด" flow the button below does, since
                // marking ซื้อแล้ว for real requires a receipt photo.
                GestureDetector(
                  onTap: isDone ? null : onSummary,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isDone ? _kPrimary : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: isDone ? _kPrimary : AppColors.disabled,
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
                              ? AppColors.faint
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
                    onPressed: onSummary,
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

  /// Not yet delivered — opens the photo + GPS confirmation.
  final VoidCallback onDeliver;

  /// Delivered and the money is owed — the runner says it arrived.
  final VoidCallback onConfirmPayment;

  const _DeliveryOrderCard({
    required this.order,
    required this.onDeliver,
    required this.onConfirmPayment,
  });

  @override
  Widget build(BuildContext context) {
    final awaitingPayment = order.isAwaitingPayment;
    final done = order.isCompleted;
    final settled = awaitingPayment || done;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: settled ? _kPrimaryLight : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: settled ? _kPrimary.withOpacity(0.4) : _kBorder,
            width: settled ? 1.5 : 1),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(initial: order.buyerInitial),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.buyerName,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: done ? AppColors.faint : _kTextPrimary,
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
                    color: done ? AppColors.disabled : _kPrimary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            order.itemDescription,
            style: TextStyle(
              fontSize: 12,
              color: done ? AppColors.disabled : AppColors.muted,
              decoration: done ? TextDecoration.lineThrough : null,
            ),
          ),
          const SizedBox(height: 10),
          if (done)
            const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: _kPrimary, size: 16),
                SizedBox(width: 6),
                Text(
                  'ปิดงานแล้ว — รับเงินเรียบร้อย',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _kPrimary),
                ),
              ],
            )
          else if (awaitingPayment)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onConfirmPayment,
                icon: const Icon(Icons.payments_rounded, size: 16),
                label: Text(
                  order.paymentAmount != null
                      ? 'ยืนยันรับเงิน ฿${order.paymentAmount!.toStringAsFixed(0)} แล้ว'
                      : 'ยืนยันรับเงินแล้ว',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onDeliver,
                icon: const Icon(Icons.camera_alt_rounded, size: 16),
                label: const Text(
                  'ถ่ายรูปส่งของ',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kAction,
                  side: const BorderSide(color: _kAction),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── QR Section ──────────────────────────────────────────

/// The runner's own receiving QR — a real PromptPay payload built on-device
/// from `session.user.promptPayId`, not tied to one order's amount. A person
/// scanning it enters what they owe themselves, which is what a general
/// "pay me" code is for; a per-order amount belongs on the DELIVERED card's
/// own confirm-payment step instead, where `OrderPayment.amount` is real.
class _QRSection extends StatelessWidget {
  const _QRSection();

  @override
  Widget build(BuildContext context) {
    final user = sl<SessionController>().user;
    final promptPayId = user?.promptPayId ?? '';
    final payload =
        promptPayId.isEmpty ? '' : PromptPayQr.build(promptPayId: promptPayId);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.08),
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
                  color: AppColors.secondarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.qr_code_2_rounded,
                    color: AppColors.secondary, size: 20),
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
          if (payload.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kErrorLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'ยังไม่ได้ตั้งค่าพร้อมเพย์ — ไปที่โปรไฟล์เพื่อเพิ่มเบอร์รับเงิน',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    color: _kError,
                    fontWeight: FontWeight.w600),
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kBorder, width: 2),
              ),
              child: QrImageView(
                data: payload,
                version: QrVersions.auto,
                size: 180,
                gapless: true,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.secondarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'PromptPay: $promptPayId',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: promptPayId));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('คัดลอกเลขพร้อมเพย์แล้ว')),
                );
              },
              icon: const Icon(Icons.copy_rounded, size: 14),
              label: const Text('คัดลอกเลข'),
              style: TextButton.styleFrom(
                  foregroundColor: AppColors.muted,
                  textStyle: const TextStyle(fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }
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
                  backgroundColor: _kPrimary,
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

  /// Uploads the receipt(s) and calls `POST /orders/{id}/purchase`. Returns
  /// whether it succeeded — the sheet only closes on true, so a rejected
  /// price or a failed upload leaves the runner exactly where they were.
  final Future<bool> Function(double actualPrice, List<String> proofMediaIds)
      onConfirm;

  const _SummarySheet({
    required this.order,
    required this.controller,
    required this.onConfirm,
  });

  @override
  State<_SummarySheet> createState() => _SummarySheetState();
}

class _SummarySheetState extends State<_SummarySheet> {
  final _photos = <File>[];
  bool _submitting = false;

  double get _actualPrice =>
      double.tryParse(widget.controller.text.trim()) ?? 0;
  double get _total => _actualPrice + widget.order.rewardAmount;

  Future<void> _addPhoto(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    setState(() => _photos.add(File(picked.path)));
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final mediaIds = await sl<MediaUploadService>().uploadAll(
        files: _photos,
        purpose: MediaPurpose.orderProof,
      );
      final ok = await widget.onConfirm(_actualPrice, mediaIds);
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '📣 แจ้ง ${widget.order.buyerName} ยอด ฿${_total.toStringAsFixed(0)} แล้ว'),
            backgroundColor: _kPrimary,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (_) {
      // The page's own error banner (from the store's `_act`) covers a
      // purchase-call failure; an upload failure alone still needs a word
      // here, since it never reaches the store at all.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('อัปโหลดรูปไม่สำเร็จ ลองใหม่อีกครั้ง')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
                    color: AppColors.borderStrong,
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
                      label: '+ ค่ารับฝาก',
                      value:
                          '${widget.order.rewardAmount.toStringAsFixed(0)} บาท',
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

              // Receipt photo — required by `PurchaseOrderRequest.proofMediaIds`
              const Text(
                'รูปใบเสร็จ (จำเป็น)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _kTextSecondary,
                ),
              ),
              const SizedBox(height: 6),
              _PhotoPicker(
                photos: _photos,
                onAdd: _addPhoto,
                onRemove: (i) => setState(() => _photos.removeAt(i)),
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
                      onPressed: (_actualPrice > 0 &&
                              _photos.isNotEmpty &&
                              !_submitting)
                          ? _submit
                          : null,
                      icon: _submitting
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded, size: 16),
                      label: const Text(
                        'ส่งยอดและแจ้งลูกค้า',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.borderStrong,
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
                color: AppColors.warningSoft,
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

// ─── Photo Picker ─────────────────────────────────────────

/// Camera-or-gallery tiles feeding one upload list, shared by the purchase
/// receipt and the delivery-proof sheets — both send `proofMediaIds` and
/// differ only in what purpose the media is uploaded under.
class _PhotoPicker extends StatelessWidget {
  final List<File> photos;
  final Future<void> Function(ImageSource source) onAdd;
  final void Function(int index) onRemove;

  const _PhotoPicker({
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (var i = 0; i < photos.length; i++)
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(photos[i],
                    width: 84, height: 84, fit: BoxFit.cover),
              ),
              Positioned(
                top: -6,
                right: -6,
                child: GestureDetector(
                  onTap: () => onRemove(i),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                        color: Colors.black54, shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded,
                        size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        GestureDetector(
          onTap: () => _pick(context),
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: _kBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorder),
            ),
            child: const Icon(Icons.add_a_photo_outlined,
                color: _kTextSecondary),
          ),
        ),
      ],
    );
  }

  void _pick(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('ถ่ายรูป'),
              onTap: () {
                Navigator.pop(sheetContext);
                onAdd(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('เลือกจากคลังภาพ'),
              onTap: () {
                Navigator.pop(sheetContext);
                onAdd(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pending Order Card (Accept / Reject) ────────────────

class _PendingOrderCard extends StatelessWidget {
  final MyOrderItem order;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _PendingOrderCard({
    required this.order,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kActionLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kAction.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(initial: order.buyerInitial),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.buyerName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: _kTextPrimary),
                ),
              ),
              if (order.rewardAmount > 0)
                Text(
                  'ค่ารับฝาก ฿${order.rewardAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _kAction),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(order.itemDescription,
              style: const TextStyle(fontSize: 13, color: _kTextPrimary)),
          if (order.note != null) ...[
            const SizedBox(height: 4),
            Text('โน้ต: ${order.note}',
                style: const TextStyle(
                    fontSize: 11,
                    color: _kTextSecondary,
                    fontStyle: FontStyle.italic)),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('ปฏิเสธ',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('รับคำฝากนี้',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Closed Order Row (rejected / cancelled) ─────────────

class _ClosedOrderRow extends StatelessWidget {
  final MyOrderItem order;
  const _ClosedOrderRow({required this.order});

  @override
  Widget build(BuildContext context) {
    final label = switch (order.status) {
      'REJECTED' => 'ปฏิเสธแล้ว',
      'CANCELLED' => 'ยกเลิกแล้ว',
      _ => 'หมดเวลาแล้ว',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _kBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${order.buyerName} · ${order.itemDescription}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.disabled,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.disabled)),
        ],
      ),
    );
  }
}

class _EmptyActiveOrders extends StatelessWidget {
  const _EmptyActiveOrders();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: const Text(
        'ยังไม่มีคำฝากที่รับไว้ในทริปนี้',
        style: TextStyle(fontSize: 13, color: _kTextSecondary),
      ),
    );
  }
}

// ─── Delivery Proof Sheet ─────────────────────────────────

/// Photos for `DeliverOrderRequest.proofMediaIds`. The coordinate travels
/// with the call itself — `TripActionsUseCase.deliverOrder` resolves it —
/// so this sheet only has to get the photographs uploaded and hand back
/// their ids.
class _DeliveryProofSheet extends StatefulWidget {
  final MyOrderItem order;
  const _DeliveryProofSheet({required this.order});

  @override
  State<_DeliveryProofSheet> createState() => _DeliveryProofSheetState();
}

class _DeliveryProofSheetState extends State<_DeliveryProofSheet> {
  final _photos = <File>[];
  bool _submitting = false;

  Future<void> _addPhoto(ImageSource source) async {
    final picked =
        await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    setState(() => _photos.add(File(picked.path)));
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final mediaIds = await sl<MediaUploadService>().uploadAll(
        files: _photos,
        purpose: MediaPurpose.orderProof,
      );
      if (!mounted) return;
      Navigator.of(context).pop(mediaIds);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('อัปโหลดรูปไม่สำเร็จ ลองใหม่อีกครั้ง')),
        );
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(context).padding.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Text(
              'ถ่ายรูปส่งของให้คุณ${widget.order.buyerName}',
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _kTextPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'ระบบจะบันทึกตำแหน่งปัจจุบันของคุณไว้เป็นหลักฐานการส่งด้วย',
              style: TextStyle(fontSize: 12, color: _kTextSecondary),
            ),
            const SizedBox(height: 16),
            _PhotoPicker(
              photos: _photos,
              onAdd: _addPhoto,
              onRemove: (i) => setState(() => _photos.removeAt(i)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    (_photos.isNotEmpty && !_submitting) ? _submit : null,
                icon: _submitting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.location_on_rounded, size: 16),
                label: const Text(
                  'ยืนยันการส่งของ',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.borderStrong,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reject Dialog ────────────────────────────────────────

class _RejectDialog extends StatefulWidget {
  final String buyerName;
  const _RejectDialog({required this.buyerName});

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('ปฏิเสธคำฝากของคุณ${widget.buyerName}?',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      content: TextField(
        controller: _controller,
        maxLength: 200,
        decoration: const InputDecoration(
          hintText: 'เหตุผล (ไม่บังคับ)',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ยกเลิก'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('ปฏิเสธ',
              style: TextStyle(color: AppColors.error)),
        ),
      ],
    );
  }
}

// ─── Avatar ──────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String initial;
  const _Avatar({required this.initial});

  /// A deterministic identity palette — the same person keeps the same colour.
  /// Five *token* hues rather than five invented ones, each dark enough to
  /// carry a white initial. The legacy orange here fought the coral beside it.
  static const _colors = [
    AppColors.secondary,
    AppColors.warningFill,
    AppColors.infoFill,
    AppColors.successFill,
    AppColors.primaryInk,
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
