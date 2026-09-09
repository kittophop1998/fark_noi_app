import '../../domain/entities/notification_entity.dart';

/// `NotificationResponse` read into [NotificationEntity].
///
/// The title and body come from the server already written in Thai — they are
/// composed where the event happens, which is the only place that knows whose
/// name to put in them — so nothing here rewrites copy. What is decided here is
/// only how loudly the row should ask, and what its one control should say.
class NotificationModel {
  NotificationModel._();

  static NotificationEntity fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? '';
    return NotificationEntity(
      id: json['id']?.toString() ?? '',
      type: _toneOf(type),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      time: DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      actionLabel: _actionLabelOf(type),
      actionUrl: json['actionUrl'] as String? ?? '',
      entityType: json['entityType'] as String? ?? '',
      entityId: json['entityId']?.toString() ?? '',
      // `readAt` is absent while unread — the API omits it rather than sending
      // null — so its presence is the whole test.
      isRead: (json['readAt'] as String?)?.isNotEmpty == true,
    );
  }

  /// Which of the three kinds an event is.
  ///
  /// A new event name the app has not been taught falls to [NotiType.general]:
  /// an unknown notification is still worth showing, and showing it as
  /// "something needs you" would be a claim the client cannot support.
  static NotiType _toneOf(String type) {
    switch (type) {
      // Somebody is waiting on the reader to answer or to settle.
      case 'ORDER_REQUESTED':
      case 'OPEN_ORDER_CLAIMED':
      case 'TRAVELER_ARRIVED':
        return NotiType.actionRequired;

      // Progress on something already agreed.
      case 'TRAVELER_STARTED':
      case 'TRAVELER_DELIVERING':
      case 'ORDER_ACCEPTED':
        return NotiType.update;

      case 'ORDER_REJECTED':
      case 'ORDER_CANCELLED':
      case 'ORDER_COMPLETED':
      default:
        return NotiType.general;
    }
  }

  static String? _actionLabelOf(String type) {
    switch (type) {
      case 'ORDER_REQUESTED':
        return 'ดูคำฝาก';
      case 'OPEN_ORDER_CLAIMED':
        return 'ดูงานที่รับ';
      case 'TRAVELER_ARRIVED':
        return 'ออกไปรับของ';
      default:
        return null;
    }
  }
}
