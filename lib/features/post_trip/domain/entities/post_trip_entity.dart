import '../../../../shared/models/catalogue_store.dart';

/// A trip about to be announced.
///
/// The two ends carry coordinates because `POST /api/v1/trips` requires them:
/// a trip is a journey between two places, and the service-area rule is applied
/// to the origin. [destination] is a shop picked from the catalogue — that is
/// where its coordinate comes from — while [origin] is where the runner is
/// standing, with the meeting point they typed as its name.
class PostTripEntity {
  const PostTripEntity({
    required this.destination,
    required this.originName,
    required this.originLatitude,
    required this.originLongitude,
    required this.departureAt,
    required this.maxOrders,
    required this.feePerOrder,
    this.note = '',
  });

  final CatalogueStore destination;

  /// The meeting point, in the runner's own words — "หน้าเซเว่น ประตูเชียงราก".
  final String originName;
  final double originLatitude;
  final double originLongitude;

  /// When they leave. An absolute moment rather than a wall clock: the API
  /// takes RFC 3339, and "14:30" without a date is ambiguous the moment it is
  /// entered close to midnight.
  final DateTime departureAt;

  final int maxOrders;

  /// ค่าหิ้ว per order, in **baht** as the form collects it. Converted to
  /// satang at the datasource, which is the app's one edge for that.
  final int feePerOrder;

  /// The runner's terms for whoever asks them for something. Carries the
  /// categories the form collects, phrased as a sentence — the API has no
  /// category field on a trip, and a note is what a requester actually reads.
  final String note;
}
