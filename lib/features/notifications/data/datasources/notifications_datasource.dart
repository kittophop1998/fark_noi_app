import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/notification_entity.dart';
import '../models/notification_model.dart';

abstract class NotificationsDataSource {
  Future<List<NotificationEntity>> list({int limit = 30});
  Future<void> markRead(String id);
  Future<void> markAllRead();
  Future<void> delete(String id);
}

class NotificationsRemoteDataSource implements NotificationsDataSource {
  const NotificationsRemoteDataSource({required this.client});

  final DioClient client;

  @override
  Future<List<NotificationEntity>> list({int limit = 30}) async {
    final response = await client.get(
      ApiEndpoints.myNotifications,
      queryParameters: {'limit': limit, 'page': 1},
    );
    return DioClient.unwrapList(response)
        .whereType<Map>()
        .map((item) =>
            NotificationModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<void> markRead(String id) async {
    await client.patch(ApiEndpoints.notificationRead(id));
  }

  @override
  Future<void> markAllRead() async {
    await client.post(ApiEndpoints.notificationsReadAll);
  }

  @override
  Future<void> delete(String id) async {
    // The API deletes a *read* notification only — dismissing an unread one
    // would be a way to lose something nobody has seen — so the read is sent
    // first. Both are idempotent, so a row already read costs one extra call
    // and nothing else.
    await client.patch(ApiEndpoints.notificationRead(id));
    await client.delete(ApiEndpoints.notification(id));
  }
}
