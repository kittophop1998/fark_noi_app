import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/di/injection_container.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/app_states.dart';
import '../../domain/entities/notification_entity.dart';
import '../store/notifications_store.dart';

/// The row type this screen draws. One name for the entity so the six hundred
/// lines below keep the shape they had when the list was a constant.
typedef NotiItem = NotificationEntity;

// ─── Page ──────────────────────────────────────────────────────────────────────

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  NotiFilter _filter = NotiFilter.all;
  late final NotificationsStore _store;

  @override
  void initState() {
    super.initState();
    _store = sl<NotificationsStore>()..load();
  }

  List<NotiItem> get _items => _store.items;

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

  int get _unreadCount => _store.unreadCount;

  void _dismiss(String id) => _store.dismiss(id);

  void _markRead(String id) => _store.markRead(id);

  void _markAllRead() => _store.markAllRead();

  /// Where a notification's own control goes.
  ///
  /// The API's `actionUrl` is a path into the **web** app, and pushing it here
  /// would land on a route this router does not have. The `entityType` is the
  /// portable half of the same fact, so it is what the destination is chosen
  /// from — and an event about something this app has no screen for gets no
  /// button rather than a broken one.
  VoidCallback? _actionFor(NotiItem item) {
    switch (item.entityType.toUpperCase()) {
      case 'ORDER':
      case 'TRIP':
        return () {
          _markRead(item.id);
          context.push(AppRoutes.myTrips);
        };
      default:
        return null;
    }
  }

  /// "ล้างทั้งหมด" — every row, one call each. The API deletes one at a time
  /// and only a read one, which [NotificationsStore.dismiss] already handles.
  Future<void> _clearAll() async {
    for (final item in [..._items]) {
      await _store.dismiss(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) => _build(context));
  }

  Widget _build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.text, size: 20),
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
                color: AppColors.text,
              ),
            ),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning,
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
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else if (_items.isNotEmpty)
            TextButton(
              onPressed: _clearAll,
              child: const Text(
                'ล้างทั้งหมด',
                style: TextStyle(
                  color: AppColors.primary,
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
            child: _store.isLoading && _items.isEmpty
                ? const Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: SkeletonList(),
                  )
                : _store.hasError && _items.isEmpty
                    ? ErrorState(
                        message: _store.errorMessage!,
                        onRetry: _store.load,
                      )
                    : filtered.isEmpty
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
                                onAction: _actionFor(item),
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
      color: AppColors.background,
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
    const primary = AppColors.primary;
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
            color: isSelected ? Colors.white : AppColors.muted,
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

  /// The row's one control, when the event is something the reader has to act
  /// on. Null on the rest, and the button is simply not drawn.
  final VoidCallback? onAction;

  const _NotiCard({
    super.key,
    required this.item,
    required this.onDismiss,
    required this.onTap,
    this.onAction,
  });

  Color get _accentColor {
    switch (item.type) {
      case NotiType.actionRequired:
        return AppColors.warning; // urgent / payment
      case NotiType.update:
        return AppColors.primary; // Purple — info update
      case NotiType.general:
        return AppColors.primary; // Lavender purple — soft general
    }
  }

  Color get _bgColor {
    switch (item.type) {
      case NotiType.actionRequired:
        return AppColors.warningSoft; // soft orange-red tint
      case NotiType.update:
        return AppColors.primarySoft; // soft purple tint
      case NotiType.general:
        return AppColors.primarySoft; // soft lavender
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
          color: AppColors.error,
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
                                    ? AppColors.warning
                                    : AppColors.primary,
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
                                    ? AppColors.muted
                                    : AppColors.text,
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
                          color: AppColors.muted,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 11, color: AppColors.disabled),
                          const SizedBox(width: 3),
                          Text(
                            _timeAgo(item.time),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.disabled,
                            ),
                          ),
                        ],
                      ),

                      // ── Action Button (if any) ────────────────────
                      if (item.actionLabel != null && onAction != null) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            onPressed: onAction,
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
                        size: 15, color: AppColors.faint),
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
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
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
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ตอนนี้ทุกอย่างสงบดีครับ 😌\nลองเช็คอีกครั้งทีหลังนะ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.faint,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
