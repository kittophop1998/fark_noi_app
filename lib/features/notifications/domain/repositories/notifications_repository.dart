import '../entities/notification_entity.dart';

abstract class NotificationsRepository {
  Future<List<NotificationEntity>> list({int limit});
  Future<void> markRead(String id);
  Future<void> markAllRead();
  Future<void> delete(String id);
}
