import 'package:mobx/mobx.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';

part 'notifications_store.g.dart';

class NotificationsStore = _NotificationsStore with _$NotificationsStore;

/// The inbox.
///
/// Every write here is **optimistic**: the row is redrawn the moment it is
/// tapped and the call follows. Marking something read is not a transaction —
/// nothing is lost if it fails — and a list that waits on a round trip before
/// dimming a row feels broken on a slow connection. A failure re-reads rather
/// than rolls back, so the screen ends up agreeing with the server either way.
abstract class _NotificationsStore with Store {
  _NotificationsStore({required NotificationsRepository repository})
      : _repository = repository;

  final NotificationsRepository _repository;

  @observable
  ObservableList<NotificationEntity> items =
      ObservableList<NotificationEntity>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @computed
  bool get hasError => errorMessage != null;

  @computed
  int get unreadCount => items.where((n) => !n.isRead).length;

  @computed
  bool get isEmpty => !isLoading && !hasError && items.isEmpty;

  @action
  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    try {
      items = ObservableList.of(await _repository.list(limit: 30));
    } on AppException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'โหลดการแจ้งเตือนไม่สำเร็จ';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> markRead(String id) async {
    _patch(id, (n) => n.copyWith(isRead: true));
    try {
      await _repository.markRead(id);
    } catch (_) {
      await load();
    }
  }

  @action
  Future<void> markAllRead() async {
    items = ObservableList.of(
      items.map((n) => n.copyWith(isRead: true)).toList(),
    );
    try {
      await _repository.markAllRead();
    } catch (_) {
      await load();
    }
  }

  @action
  Future<void> dismiss(String id) async {
    final removed = items.firstWhere((n) => n.id == id);
    items = ObservableList.of(items.where((n) => n.id != id).toList());
    try {
      await _repository.delete(id);
    } catch (_) {
      // Put it back where it was rather than re-reading: a row that vanished
      // and then reappeared at the top of the list is worse than one that
      // simply did not go away.
      final restored = [...items, removed]
        ..sort((a, b) => b.time.compareTo(a.time));
      items = ObservableList.of(restored);
    }
  }

  @action
  void clearError() => errorMessage = null;

  void _patch(String id, NotificationEntity Function(NotificationEntity) f) {
    final index = items.indexWhere((n) => n.id == id);
    if (index < 0) return;
    final next = [...items]..[index] = f(items[index]);
    items = ObservableList.of(next);
  }
}
