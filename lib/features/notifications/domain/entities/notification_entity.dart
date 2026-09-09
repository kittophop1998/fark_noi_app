import 'package:equatable/equatable.dart';

/// How loudly a notification asks to be dealt with.
///
/// The API sends an event name, not a priority — `ORDER_REQUESTED`,
/// `TRAVELER_ARRIVED` — because what an event *means* depends on which side of
/// the errand you are on. Grouping them into three is the client's job, and it
/// is the whole basis of this screen's filters.
enum NotiType {
  /// Something is waiting on the reader: a request to answer, an errand to
  /// settle. The only kind that gets a coral action.
  actionRequired,

  /// Progress on something already agreed — the runner set off, has arrived.
  update,

  /// Everything else.
  general,
}

enum NotiFilter { all, updates, payments }

class NotificationEntity extends Equatable {
  const NotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.actionLabel,
    this.actionUrl = '',
    this.entityType = '',
    this.entityId = '',
    this.isRead = false,
  });

  final String id;
  final NotiType type;
  final String title;
  final String body;
  final DateTime time;

  /// The label on the row's one control. Null when there is nothing to do.
  final String? actionLabel;

  /// Where tapping it goes — an in-app path the API supplies.
  final String actionUrl;

  final String entityType;
  final String entityId;
  final bool isRead;

  NotificationEntity copyWith({bool? isRead}) => NotificationEntity(
        id: id,
        type: type,
        title: title,
        body: body,
        time: time,
        actionLabel: actionLabel,
        actionUrl: actionUrl,
        entityType: entityType,
        entityId: entityId,
        isRead: isRead ?? this.isRead,
      );

  @override
  List<Object?> get props =>
      [id, type, title, body, time, actionLabel, actionUrl, isRead];
}
