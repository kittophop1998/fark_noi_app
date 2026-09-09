import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_datasource.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl({required this.dataSource});

  final NotificationsDataSource dataSource;

  @override
  Future<List<NotificationEntity>> list({int limit = 30}) =>
      dataSource.list(limit: limit);

  @override
  Future<void> markRead(String id) => dataSource.markRead(id);

  @override
  Future<void> markAllRead() => dataSource.markAllRead();

  @override
  Future<void> delete(String id) => dataSource.delete(id);
}
