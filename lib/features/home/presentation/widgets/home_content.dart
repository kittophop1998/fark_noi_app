import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/home_entity.dart';

// ─── Color shortcuts (all from AppColors) ──────────────
const _kPrimary     = Color(AppColors.primary);
const _kPrimaryLight = AppColors.primaryLight;
const _kAction      = AppColors.action;
const _kActionLight = AppColors.actionLight;
const _kTextPrimary = Color(AppColors.textPrimary);
const _kTextSecondary = Color(AppColors.textSecondary);

// ─── Category Filter Data ───────────────────────────────
const _kCategories = [
  _Category(key: 'all', label: 'ทั้งหมด', emoji: '🏠'),
  _Category(key: 'food', label: 'ของกิน', emoji: '🍟'),
  _Category(key: 'mart', label: 'ห้าง/ตลาด', emoji: '🛒'),
  _Category(key: 'pharmacy', label: 'ร้านยา', emoji: '🏥'),
  _Category(key: 'drink', label: 'ชานม', emoji: '🥤'),
];

class _Category {
  final String key;
  final String label;
  final String emoji;
  const _Category({required this.key, required this.label, required this.emoji});
}

// ─── Home Content (StatefulWidget for filter state) ────

class HomeContent extends StatefulWidget {
  final List<HomeEntity> items;
  const HomeContent({super.key, required this.items});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _selectedCategory = 'all';

  List<HomeEntity> get _filtered {
    if (_selectedCategory == 'all') return widget.items;
    return widget.items
        .where((r) => r.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = widget.items.where((r) => !r.isFull).length;
    final filtered = _filtered;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // ── Carousel Banner ──────────────────────────────
        _CarouselBanner(activeCount: activeCount, items: widget.items),
        const SizedBox(height: 16),

        // ── Quick Filter Chips ────────────────────────────
        _QuickFilter(
          selected: _selectedCategory,
          onChanged: (val) => setState(() => _selectedCategory = val),
        ),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _kPrimaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${filtered.length} คน',
                style: const TextStyle(
                  fontSize: 12,
                  color: _kPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Runner Cards ─────────────────────────────────
        if (filtered.isEmpty)
          const _EmptyFilter()
        else
          ...filtered.map(
            (runner) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RunnerCard(runner: runner),
            ),
          ),
      ],
    );
  }
}

// ─── Carousel Banner ─────────────────────────────────────

class _CarouselBanner extends StatefulWidget {
  final int activeCount;
  final List<HomeEntity> items;
  const _CarouselBanner({required this.activeCount, required this.items});

  @override
  State<_CarouselBanner> createState() => _CarouselBannerState();
}

class _CarouselBannerState extends State<_CarouselBanner> {
  final _controller = PageController();
  int _page = 0;

  List<_BannerSlide> get _slides => [
        _BannerSlide(
          icon: Icons.shopping_cart_rounded,
          title: '${widget.items.length} คนกำลังจะไปซื้อของ',
          subtitle:
              'มีที่ว่าง ${widget.activeCount} ที่ • แตะ Card เพื่อฝากสินค้า',
        ),
        _BannerSlide(
          icon: Icons.local_fire_department_rounded,
          title: 'ร้านยอดฮิตวันนี้ 🔥',
          subtitle: 'Big C รังสิต • มีคนรอหิ้วอยู่ 2 คน',
        ),
        _BannerSlide(
          icon: Icons.access_time_rounded,
          title: 'จุดนัดรับต้องชัด! 📍',
          subtitle: 'ระบุหน้าอาคาร/ชั้น เพื่อไม่ให้หาตัวกันไม่เจอ',
        ),
      ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 110,
          child: PageView.builder(
            controller: _controller,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _BannerSlideWidget(slide: _slides[i]),
          ),
        ),
        const SizedBox(height: 8),
        // Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (i) {
            final active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: active ? 20 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: active
                    ? Colors.white
                    : Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _BannerSlide {
  final IconData icon;
  final String title;
  final String subtitle;
  const _BannerSlide(
      {required this.icon, required this.title, required this.subtitle});
}

class _BannerSlideWidget extends StatelessWidget {
  final _BannerSlide slide;
  const _BannerSlideWidget({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kPrimary, _kPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _kPrimary.withOpacity(0.35),
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
            child: Icon(slide.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  slide.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  slide.subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
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

// ─── Quick Filter ─────────────────────────────────────────

class _QuickFilter extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _QuickFilter({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _kCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = _kCategories[i];
          final isSelected = selected == cat.key;
          return GestureDetector(
            onTap: () => onChanged(cat.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? _kPrimary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? _kPrimary : AppColors.border,
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _kPrimary.withOpacity(0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cat.emoji, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 5),
                  Text(
                    cat.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : _kTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
    final double progress = runner.totalSlots > 0
        ? (runner.filledSlots / runner.totalSlots).toDouble()
        : 0.0;
    // Progress color: green → orange → red
    final Color progressColor = progress < 0.5
        ? _kPrimary
        : progress < 0.85
            ? _kAction
            : Colors.red.shade400;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.detail, extra: runner),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Row: Avatar + Info + StatusDot ───
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor:
                            isFull ? Colors.grey.shade200 : _kPrimaryLight,
                        child: Text(
                          runner.avatarInitial,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isFull ? Colors.grey.shade500 : _kPrimary,
                          ),
                        ),
                      ),
                      // Pulse dot
                      Positioned(
                        bottom: 1,
                        right: 1,
                        child: _PulseDot(active: !isFull),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + Rating
                        Row(
                          children: [
                            Text(
                              runner.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _kTextPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.star_rounded,
                                size: 13, color: Color(0xFFFFC107)),
                            const SizedBox(width: 2),
                            Text(
                              '${runner.rating.toStringAsFixed(1)} (${runner.reviewCount})',
                              style: const TextStyle(
                                fontSize: 11,
                                color: _kTextSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        // Destination
                        Row(
                          children: [
                            const Icon(Icons.store_rounded,
                                size: 13, color: _kPrimary),
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
                        // Pickup point
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 13, color: _kAction),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                runner.dormitory,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _kTextSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status badge (top-right)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isFull
                          ? Colors.red.shade50
                          : _kPrimaryLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isFull
                            ? Colors.red.shade200
                            : _kPrimary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      isFull ? 'เต็ม' : 'ว่าง',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color:
                            isFull ? Colors.red.shade600 : _kPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Tags ─────────────────────────────────
              if (runner.tags.isNotEmpty)
                Wrap(
                  spacing: 6,
                  children: runner.tags
                      .map((tag) => _TagChip(label: tag))
                      .toList(),
                ),
              const SizedBox(height: 10),

              // ── Time Row ─────────────────────────────
              Row(
                children: [
                  Icon(Icons.flight_takeoff_rounded,
                      size: 13, color: _kPrimary),
                  const SizedBox(width: 4),
                  Text(
                    runner.departureTime,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _kPrimary,
                    ),
                  ),
                  if (runner.eta.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded,
                        size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 6),
                    Icon(Icons.home_rounded,
                        size: 13, color: _kAction),
                    const SizedBox(width: 4),
                    Text(
                      'ถึงหอ ${runner.eta}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _kAction,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    isFull
                        ? 'เต็มแล้ว'
                        : 'ว่าง ${runner.availableSlots}/${runner.totalSlots}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isFull ? Colors.red.shade400 : _kPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // ── Linear Progress Bar ───────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0).toDouble(),
                  minHeight: 7,
                  backgroundColor: AppColors.border,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Pulse Dot ───────────────────────────────────────────

class _PulseDot extends StatefulWidget {
  final bool active;
  const _PulseDot({required this.active});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.active ? const Color(0xFF4CAF50) : Colors.red.shade400;
    if (!widget.active) {
      return Container(
        width: 11,
        height: 11,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      );
    }
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 11,
        height: 11,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tag Chip ────────────────────────────────────────────

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _kPrimaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: _kPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Empty Filter State ──────────────────────────────────

class _EmptyFilter extends StatelessWidget {
  const _EmptyFilter();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Text('🔍', style: TextStyle(fontSize: 40)),
          SizedBox(height: 12),
          Text(
            'ยังไม่มีผู้รับฝากในหมวดนี้',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF49454F),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
