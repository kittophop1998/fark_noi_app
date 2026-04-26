import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../my_trips/models/my_trip_models.dart';
import '../../../my_trips/data/my_trips_mock_data.dart';

// ─── Color shortcuts (all from AppColors) ──────────────
const _kPrimary       = Color(AppColors.primary);
const _kPrimaryLight  = AppColors.primaryLight;
const _kAction        = AppColors.action;
const _kActionLight   = AppColors.actionLight;
const _kBg            = AppColors.bgPage;
const _kTextPrimary   = Color(AppColors.textPrimary);
const _kTextSecondary = Color(AppColors.textSecondary);
const _kBorder        = AppColors.border;

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final activeTrip = MyTripsMockData.getActiveTrip();
    final completed = MyTripsMockData.getCompletedTrips();

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
          _ProfileCard(),
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
              subtitle: '091-234-5678'),
          _MenuItem(
              icon: Icons.star_outline_rounded,
              label: 'รีวิวที่ได้รับ',
              subtitle: '⭐ 4.9 (32 รีวิว)'),
          _MenuItem(
              icon: Icons.notifications_outlined,
              label: 'การแจ้งเตือน',
              subtitle: 'เปิดอยู่'),
          _MenuItem(
              icon: Icons.logout_rounded,
              label: 'ออกจากระบบ',
              subtitle: '',
              isDestructive: true),
        ],
      ),
    );
  }
}

// ─── Profile Card ─────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
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
              gradient: LinearGradient(
                colors: [Color(0xFF1E7B4B), Color(0xFF2E9D5E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'ม',
                style: TextStyle(
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
                const Text(
                  'มิน สมใจ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: _kTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Colors.amber, size: 14),
                    const SizedBox(width: 3),
                    const Text(
                      '4.9',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: _kTextPrimary,
                      ),
                    ),
                    Text(
                      ' · 32 รีวิว',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _StatChip(label: '8 ทริป', icon: Icons.directions_walk),
                    const SizedBox(width: 6),
                    _StatChip(
                        label: '⚡ High Speed ×3',
                        icon: null,
                        isOrange: true),
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
  final bool isOrange;

  const _StatChip(
      {required this.label, required this.icon, this.isOrange = false});

  @override
  Widget build(BuildContext context) {
    final color = isOrange ? _kAction : _kPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOrange ? _kActionLight : _kPrimaryLight,
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
                color: const Color(0xFFF3F3F3),
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
              color: const Color(0xFFF3F3F3),
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
          const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
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

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? const Color(0xFFD32F2F) : _kTextPrimary;

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
        onTap: () {},
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
