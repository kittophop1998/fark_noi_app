import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../my_trips/domain/entities/my_trip_entity.dart';
import '../../../my_trips/presentation/store/my_trips_store.dart';
import '../../domain/entities/reputation_entity.dart';
import '../store/profile_store.dart';

// ─── Color shortcuts (all from AppColors) ──────────────
const _kPrimary       = AppColors.primary;
const _kPrimaryLight  = AppColors.primarySoft;
const _kBg            = AppColors.background;
const _kTextPrimary   = AppColors.text;
const _kTextSecondary = AppColors.muted;
const _kBorder        = AppColors.border;
const _kTrust         = AppColors.secondary;
const _kTrustDeep     = AppColors.secondaryHover;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileStore _store;
  late final MyTripsStore _trips;

  @override
  void initState() {
    super.initState();
    _store = sl<ProfileStore>();
    _trips = sl<MyTripsStore>();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _store.load(),
      _trips.load(),
      _trips.loadHistory(),
    ]);
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'ออกจากระบบ?',
        body: 'คุณจะต้องเข้าสู่ระบบใหม่เพื่อใช้งานฝากหน่อยอีกครั้ง',
        confirmLabel: 'ออกจากระบบ',
        confirmColor: AppColors.dangerFill,
      ),
    );
    if (confirmed != true) return;
    // Signing out is a navigation nobody has to write: the router watches the
    // session and sends the app back to the sign-in screen on its own.
    await _store.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) => _build(context));
  }

  Widget _build(BuildContext context) {
    final activeTrip = _trips.trip;
    final completed = _trips.history;
    final user = _store.user;
    final reputation = _store.reputation;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: const BackButton(color: _kTextPrimary),
        title: const Text(
          'โปรไฟล์',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _kTextPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          // ── Profile Card ──────────────────────────────
          _ProfileCard(
            user: user,
            reputation: reputation,
            tripCount: reputation?.completedTotal ?? 0,
          ),
          const SizedBox(height: 16),

          // ── Badges ────────────────────────────────────
          _BadgesRow(),
          const SizedBox(height: 20),

          // ── My Active Trip Section ─────────────────────
          _SectionLabel(label: 'งานของฉัน', icon: Icons.work_outline_rounded),
          const SizedBox(height: 10),
          if (activeTrip != null) ...[
            _ActiveTripEntry(
              destination: activeTrip.destination,
              filledSlots: activeTrip.filledSlots,
              totalSlots: activeTrip.totalSlots,
              statusLabel: activeTrip.status.label,
              onTap: () => context.push(AppRoutes.myTrips),
            ),
          ] else ...[
            _EmptyTripEntry(
              onTap: () => context.push(AppRoutes.postTrip),
            ),
          ],
          const SizedBox(height: 20),

          // ── History ───────────────────────────────────
          _SectionLabel(
              label: 'ประวัติทริป (${completed.length})',
              icon: Icons.history_rounded),
          const SizedBox(height: 10),
          ...completed.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _HistoryCard(
                destination: t.destination,
                orderCount: t.orders.length,
                totalEarned: t.orders
                    .fold(0.0, (s, o) => s + (o.finalPrice ?? 0.0)),
              ),
            ),
          ),

          // ── Menu Items ────────────────────────────────
          const SizedBox(height: 20),
          _SectionLabel(
              label: 'ตั้งค่า', icon: Icons.settings_outlined),
          const SizedBox(height: 10),
          _MenuItem(
              icon: Icons.payment_outlined,
              label: 'ข้อมูลพร้อมเพย์',
              // Absent means they have not set one, and no payment QR can be
              // drawn for the errands they run — so the row says exactly that
              // rather than showing a blank.
              subtitle: user?.promptPayId ?? 'ยังไม่ได้ตั้งค่า'),
          _MenuItem(
              icon: Icons.star_outline_rounded,
              label: 'รีวิวที่ได้รับ',
              subtitle: _ratingLine(reputation)),
          _MenuItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'เครดิตของฉัน',
              subtitle: _store.credits == null
                  ? '—'
                  : '฿${_store.credits!.depositBalance.toStringAsFixed(0)}'),
          _MenuItem(
              icon: Icons.logout_rounded,
              label: 'ออกจากระบบ',
              subtitle: '',
              isDestructive: true,
              onTap: _confirmSignOut),
        ],
      ),
    );
  }
}

/// The rating as one line, or the honest absence of one.
String _ratingLine(ReputationEntity? reputation) {
  if (reputation == null) return '—';
  if (!reputation.rated) return 'ยังไม่มีรีวิว';
  return '⭐ ${reputation.averageRating.toStringAsFixed(1)} '
      '(${reputation.reviewCount} รีวิว)';
}

/// A destructive confirmation. Its own small dialog rather than the shared
/// `AppNotice` family: this asks a question and returns an answer, which is a
/// different job from telling somebody something.
class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.confirmColor,
  });

  final String title;
  final String body;
  final String confirmLabel;
  final Color confirmColor;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: _kTextPrimary,
        ),
      ),
      content: Text(
        body,
        style: const TextStyle(fontSize: 14, color: _kTextSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('ยกเลิก',
              style: TextStyle(color: _kTextSecondary)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            confirmLabel,
            style: TextStyle(color: confirmColor, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

// ─── Profile Card ─────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.user,
    required this.reputation,
    required this.tripCount,
  });

  final AuthUser? user;
  final ReputationEntity? reputation;
  final int tripCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              // Teal, not coral: an avatar is who you are, not something to
              // tap. Identity is the trust accent's job.
              gradient: LinearGradient(
                colors: [_kTrustDeep, _kTrust],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user?.initial ?? '·',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'กำลังโหลด…',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: _kTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                // Somebody nobody has reviewed is drawn as new, never as zero:
                // `rated: false` is not a bad score and must not read as one.
                if (reputation?.rated == true)
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.rating, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        reputation!.averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: _kTextPrimary,
                        ),
                      ),
                      Text(
                        ' · ${reputation!.reviewCount} รีวิว',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.faint),
                      ),
                    ],
                  )
                else
                  const Text(
                    'ยังไม่มีรีวิว',
                    style: TextStyle(fontSize: 12, color: AppColors.faint),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _StatChip(
                        label: '$tripCount ทริป',
                        icon: Icons.directions_walk),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: _kTextSecondary, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final IconData? icon;

  const _StatChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    const color = _kPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _kPrimaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ],
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}

// ─── Badges Row ───────────────────────────────────────────

class _BadgesRow extends StatelessWidget {
  final _badges = const [
    _Badge(emoji: '⚡', label: 'High Speed', desc: 'ส่งเร็ว ×3'),
    _Badge(emoji: '🛒', label: 'ครบถ้วน', desc: 'ซื้อครบ 100%'),
    _Badge(emoji: '⭐', label: 'ท็อปเรท', desc: '4.9 ดาว'),
    _Badge(emoji: '🔥', label: '5 ทริป', desc: 'สะสม 5 งาน'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _badges.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final b = _badges[i];
          return Container(
            width: 80,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kBorder),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(b.emoji,
                    style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 4),
                Text(b.label,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _kTextPrimary,
                    )),
                Text(b.desc,
                    style: const TextStyle(
                        fontSize: 9, color: _kTextSecondary)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Badge {
  final String emoji;
  final String label;
  final String desc;
  const _Badge(
      {required this.emoji, required this.label, required this.desc});
}

// ─── Section Label ────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionLabel({required this.label, required this.icon});

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

// ─── Active Trip Entry ────────────────────────────────────

class _ActiveTripEntry extends StatelessWidget {
  final String destination;
  final int filledSlots;
  final int totalSlots;
  final String statusLabel;
  final VoidCallback onTap;

  const _ActiveTripEntry({
    required this.destination,
    required this.filledSlots,
    required this.totalSlots,
    required this.statusLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: _kPrimary.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _kPrimary.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _kPrimaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.store_mall_directory_outlined,
                  color: _kPrimary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ไป $destination',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: _kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$filledSlots/$totalSlots คิว · $statusLabel',
                    style: const TextStyle(
                        fontSize: 12, color: _kTextSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _kPrimary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'จัดการ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty Trip Entry ─────────────────────────────────────

class _EmptyTripEntry extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyTripEntry({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceStrong,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_shopping_cart_rounded,
                  color: _kTextSecondary, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ยังไม่มีทริปที่เปิดอยู่',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: _kTextPrimary),
                  ),
                  Text(
                    'กดเพื่อเปิดรับฝากทริปใหม่',
                    style:
                        TextStyle(fontSize: 12, color: _kTextSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: _kTextSecondary),
          ],
        ),
      ),
    );
  }
}

// ─── History Card ─────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final String destination;
  final int orderCount;
  final double totalEarned;

  const _HistoryCard({
    required this.destination,
    required this.orderCount,
    required this.totalEarned,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceStrong,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_circle_outline_rounded,
                color: _kTextSecondary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: _kTextPrimary,
                  ),
                ),
                Text(
                  '$orderCount ออเดอร์ · ฿${totalEarned.toStringAsFixed(0)}',
                  style:
                      const TextStyle(fontSize: 11, color: _kTextSecondary),
                ),
              ],
            ),
          ),
          const Icon(Icons.star_rounded, color: AppColors.rating, size: 14),
          const SizedBox(width: 2),
          const Text('5.0',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _kTextPrimary)),
        ],
      ),
    );
  }
}

// ─── Menu Item ────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isDestructive;

  /// Null for the rows that are not wired to anything yet — the tile still
  /// draws, and tapping it does nothing rather than pretending to.
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : _kTextPrimary;

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 20),
        title: Text(
          label,
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14, color: color),
        ),
        trailing: subtitle.isNotEmpty
            ? Text(subtitle,
                style: const TextStyle(
                    fontSize: 12, color: _kTextSecondary))
            : const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: _kTextSecondary),
        onTap: onTap,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
