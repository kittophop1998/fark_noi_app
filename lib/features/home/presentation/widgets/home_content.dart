import 'package:flutter/material.dart';

import '../../domain/entities/home_entity.dart';

// ─── Color Palette ─────────────────────────────────────
const _kGreen = Color(0xFF1E7B4B);
const _kGreenLight = Color(0xFF2E9D5E);
const _kGreenBg = Color(0xFFE8F5EE);
const _kOrange = Color(0xFFF57C00);
const _kTextPrimary = Color(0xFF1C1B1F);
const _kTextSecondary = Color(0xFF49454F);
const _kBorder = Color(0xFFE0E0E0);

// ─── Home Content ───────────────────────────────────────

class HomeContent extends StatelessWidget {
  final List<HomeEntity> items;

  const HomeContent({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final activeCount = items.where((r) => !r.isFull).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // ── Hero Banner ──────────────────────────────────
        _HeroBanner(activeCount: activeCount, totalCount: items.length),
        const SizedBox(height: 20),

        // ── Section Header ───────────────────────────────
        Row(
          children: [
            Text(
              'ผู้รับฝาก',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _kTextPrimary,
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _kGreenBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${items.length} คน',
                style: const TextStyle(
                  fontSize: 12,
                  color: _kGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Runner Cards ─────────────────────────────────
        ...items.map((runner) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RunnerCard(runner: runner),
            )),
      ],
    );
  }
}

// ─── Hero Banner ────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final int activeCount;
  final int totalCount;

  const _HeroBanner({required this.activeCount, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kGreen, _kGreenLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _kGreen.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.shopping_cart_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalCount คนกำลังจะไปซื้อของ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'มีที่ว่าง $activeCount ร้าน • แตะเพื่อฝากสินค้า',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: Colors.white, size: 22),
        ],
      ),
    );
  }
}

// ─── Runner Card ─────────────────────────────────────────

class _RunnerCard extends StatelessWidget {
  final HomeEntity runner;

  const _RunnerCard({required this.runner});

  @override
  Widget build(BuildContext context) {
    final isFull = runner.isFull;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Avatar ─────────────────────────────
                CircleAvatar(
                  radius: 22,
                  backgroundColor: isFull ? Colors.grey.shade200 : _kGreenBg,
                  child: Text(
                    runner.avatarInitial,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isFull ? Colors.grey.shade500 : _kGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // ── Info ────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + destination
                      Text(
                        runner.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _kTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.store_rounded,
                              size: 13, color: _kGreen),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              runner.destination,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _kTextPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 13, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              runner.dormitory,
                              style: TextStyle(
                                fontSize: 12,
                                color: _kTextSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // ── Slots + Time ─────────────────
                      Row(
                        children: [
                          _SlotIndicator(
                            total: runner.totalSlots,
                            filled: runner.filledSlots,
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded,
                                  size: 13, color: Colors.grey.shade500),
                              const SizedBox(width: 3),
                              Text(
                                runner.departureTime,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _kTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Status Dot (top-right) ────────────────────
          Positioned(
            top: 10,
            right: 12,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isFull ? Colors.red.shade400 : const Color(0xFF4CAF50),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isFull ? Colors.red : Colors.green)
                        .withOpacity(0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
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

// ─── Slot Indicator ──────────────────────────────────────

class _SlotIndicator extends StatelessWidget {
  final int total;
  final int filled;

  const _SlotIndicator({required this.total, required this.filled});

  @override
  Widget build(BuildContext context) {
    final available = total - filled;
    final isFull = available <= 0;

    return Row(
      children: [
        Row(
          children: List.generate(total, (i) {
            final isUsed = i < filled;
            return Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: isUsed ? Colors.grey.shade400 : _kGreen,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
        const SizedBox(width: 6),
        Text(
          isFull
              ? 'เต็มแล้ว'
              : 'ว่าง $available/${total}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isFull ? Colors.red.shade400 : _kGreen,
          ),
        ),
      ],
    );
  }
}
