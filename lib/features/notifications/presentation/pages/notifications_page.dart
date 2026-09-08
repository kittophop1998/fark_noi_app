import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';

// ─── Data Models ───────────────────────────────────────────────────────────────

enum NotiType { actionRequired, update, general }

enum NotiFilter { all, updates, payments }

class NotiItem {
  final String id;
  final NotiType type;
  final String? avatarUrl;
  final String title;
  final String body;
  final DateTime time;
  final String? actionLabel;
  final VoidCallback? onAction;
  final int groupCount; // >1 = grouped
  final bool isRead;

  const NotiItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.avatarUrl,
    this.actionLabel,
    this.onAction,
    this.groupCount = 1,
    this.isRead = false,
  });

  NotiItem copyWith({bool? isRead}) => NotiItem(
        id: id,
        type: type,
        avatarUrl: avatarUrl,
        title: title,
        body: body,
        time: time,
        actionLabel: actionLabel,
        onAction: onAction,
        groupCount: groupCount,
        isRead: isRead ?? this.isRead,
      );
}

// ─── Mock Data ─────────────────────────────────────────────────────────────────

final _mockNotifications = <NotiItem>[
  NotiItem(
    id: '1',
    type: NotiType.actionRequired,
    title: 'คุณมินส่งยอดสรุปมาให้แล้ว 💸',
    body: 'ชำระเงิน 75 บาท — ทริป Big C รังสิต',
    time: DateTime.now().subtract(const Duration(minutes: 2)),
    actionLabel: 'ดูยอด / จ่ายเงิน',
    isRead: false,
  ),
  NotiItem(
    id: '2',
    type: NotiType.update,
    title: 'คุณแพรถึงจุดนัดรับแล้ว! 📍',
    body: 'ออกไปรับของได้ที่หน้าหอ A เลยนะ',
    time: DateTime.now().subtract(const Duration(minutes: 10)),
    isRead: false,
  ),
  NotiItem(
    id: '3',
    type: NotiType.general,
    title: 'มีออเดอร์ใหม่ 3 รายการในทริปของคุณ 🛍️',
    body: 'คนมาฝากซื้อเพิ่มในทริป Big C ของคุณ',
    time: DateTime.now().subtract(const Duration(minutes: 30)),
    groupCount: 3,
    isRead: false,
  ),
  NotiItem(
    id: '4',
    type: NotiType.actionRequired,
    title: 'คุณโบส่งสลิปมาแล้ว ✅',
    body: 'ยอด 120 บาท — ทริป Lotus\'s รังสิต รอยืนยัน',
    time: DateTime.now().subtract(const Duration(hours: 1)),
    actionLabel: 'ยืนยันรับเงิน',
    isRead: true,
  ),
  NotiItem(
    id: '5',
    type: NotiType.update,
    title: 'ทริป 7-Eleven ปิดรับฝากแล้ว',
    body: 'คุณนิกปิดรับออเดอร์แล้ว — 5 คิว เต็ม!',
    time: DateTime.now().subtract(const Duration(hours: 2)),
    isRead: true,
  ),
  NotiItem(
    id: '6',
    type: NotiType.general,
    title: 'มีคนอยากให้คุณไปทริป Makro 🏪',
    body: 'เพื่อนใกล้เคียงอยากฝากซื้อของ รีบเปิดรับก่อนคนอื่นเลย!',
    time: DateTime.now().subtract(const Duration(hours: 5)),
    isRead: true,
  ),
];

// ─── Page ──────────────────────────────────────────────────────────────────────

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  NotiFilter _filter = NotiFilter.all;

  late final List<NotiItem> _items = List.from(_mockNotifications);

  List<NotiItem> get _filtered {
    switch (_filter) {
      case NotiFilter.all:
        return _items;
      case NotiFilter.updates:
        return _items.where((n) => n.type == NotiType.update).toList();
      case NotiFilter.payments:
        return _items.where((n) => n.type == NotiType.actionRequired).toList();
    }
  }

  int get _unreadCount =>
      _items.where((n) => n.isRead == false).length;

  void _dismiss(String id) {
    setState(() => _items.removeWhere((n) => n.id == id));
  }

  void _markRead(String id) {
    setState(() {
      final i = _items.indexWhere((n) => n.id == id);
      if (i != -1) _items[i] = _items[i].copyWith(isRead: true);
    });
  }

  void _markAllRead() {
    setState(() {
      for (int i = 0; i < _items.length; i++) {
        _items[i] = _items[i].copyWith(isRead: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: const Color(AppColors.textPrimary), size: 20),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'การแจ้งเตือน 🔔',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(AppColors.textPrimary),
              ),
            ),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.action,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text(
                'อ่านทั้งหมด',
                style: TextStyle(
                  color: Color(AppColors.primary),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else if (_items.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => _items.clear()),
              child: const Text(
                'ล้างทั้งหมด',
                style: TextStyle(
                  color: Color(AppColors.primary),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // ── Filter Tabs ──────────────────────────────────────────────────
          _FilterBar(
            selected: _filter,
            onChanged: (f) => setState(() => _filter = f),
          ),
          const SizedBox(height: 4),

          // ── List ─────────────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _NotiCard(
                        key: ValueKey(item.id),
                        item: item,
                        onDismiss: () => _dismiss(item.id),
                        onTap: () => _markRead(item.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Bar ────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final NotiFilter selected;
  final ValueChanged<NotiFilter> onChanged;

  const _FilterBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgPage,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _FilterChip(
            label: 'ทั้งหมด',
            isSelected: selected == NotiFilter.all,
            onTap: () => onChanged(NotiFilter.all),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '📦 อัปเดต',
            isSelected: selected == NotiFilter.updates,
            onTap: () => onChanged(NotiFilter.updates),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '💸 การชำระเงิน',
            isSelected: selected == NotiFilter.payments,
            onTap: () => onChanged(NotiFilter.payments),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(AppColors.primary);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primary : AppColors.border,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(AppColors.textSecondary),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─── Notification Card ─────────────────────────────────────────────────────────

class _NotiCard extends StatelessWidget {
  final NotiItem item;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const _NotiCard({
    super.key,
    required this.item,
    required this.onDismiss,
    required this.onTap,
  });

  Color get _accentColor {
    switch (item.type) {
      case NotiType.actionRequired:
        return AppColors.action; // Orange-Red #FF4500 — urgent / payment
      case NotiType.update:
        return const Color(AppColors.primary); // Purple — info update
      case NotiType.general:
        return Color(AppColors.primary); // Lavender purple — soft general
    }
  }

  Color get _bgColor {
    switch (item.type) {
      case NotiType.actionRequired:
        return AppColors.actionLight; // soft orange-red tint
      case NotiType.update:
        return AppColors.primaryLight; // soft purple tint
      case NotiType.general:
        return AppColors.primaryLight; // soft lavender
    }
  }

  IconData get _typeIcon {
    switch (item.type) {
      case NotiType.actionRequired:
        return Icons.payments_rounded;
      case NotiType.update:
        return Icons.local_shipping_rounded;
      case NotiType.general:
        return Icons.shopping_bag_rounded;
    }
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'เมื่อกี้นี้';
    if (diff.inMinutes < 60) return '${diff.inMinutes} นาทีที่แล้ว';
    if (diff.inHours < 24) return '${diff.inHours} ชั่วโมงที่แล้ว';
    return '${diff.inDays} วันที่แล้ว';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
            SizedBox(height: 2),
            Text(
              'ลบ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: item.isRead ? Colors.white : _bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(color: _accentColor, width: 4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Left: Icon ─────────────────────────────────────────
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_typeIcon, color: _accentColor, size: 22),
                    ),
                    // Group count badge
                    if (item.groupCount > 1)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _accentColor,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              '${item.groupCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 12),

                // ── Middle: Text ───────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ── Unread dot ──────────────────────────────
                          if (!item.isRead) ...[
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 6, top: 1),
                              decoration: BoxDecoration(
                                color: item.type == NotiType.actionRequired
                                    ? AppColors.action
                                    : const Color(AppColors.primary),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: item.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                                color: item.isRead
                                    ? const Color(AppColors.textSecondary)
                                    : const Color(AppColors.textPrimary),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.body,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 11, color: Colors.grey.shade400),
                          const SizedBox(width: 3),
                          Text(
                            _timeAgo(item.time),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),

                      // ── Action Button (if any) ────────────────────
                      if (item.actionLabel != null) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            onPressed: item.onAction ?? () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accentColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: Text(item.actionLabel!),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Right: Chat shortcut ──────────────────────────────
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Icon(Icons.chat_bubble_outline_rounded,
                        size: 15, color: Colors.grey.shade500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(AppColors.primary).withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: Text('🧸', style: TextStyle(fontSize: 60)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'ยังไม่มีแจ้งเตือนใหม่นะ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ตอนนี้ทุกอย่างสงบดีครับ 😌\nลองเช็คอีกครั้งทีหลังนะ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
