import 'package:equatable/equatable.dart';

/// One trip in the discovery feed — somebody already going somewhere, with room
/// to carry something back.
///
/// This is `NearbyTripResponse` as the feed screens use it. What the API
/// withholds is withheld here too: the origin is an **area name** and never an
/// address, because `GET /trips/nearby` deliberately publishes no coordinate
/// for where a runner lives. [dormitory] keeps its name from when the feed was
/// mocked, and holds `origin.name` — the area the runner sets off from.
class HomeEntity extends Equatable {
  const HomeEntity({
    required this.id,
    required this.name,
    required this.avatarInitial,
    required this.destination,
    required this.dormitory,
    required this.departureTime,
    required this.totalSlots,
    required this.filledSlots,
    this.runnerId = '',
    this.avatarUrl,
    this.rating = 5.0,
    this.reviewCount = 0,
    this.eta = '',
    this.tags = const [],
    this.category = 'food',
    this.distanceMeters,
    this.note = '',
    this.status = 'OPEN',
    this.destinationLatitude,
    this.destinationLongitude,
    this.feeSatang,
  });

  /// The trip's ObjectId. A string because that is what every `/trips/{tripId}`
  /// path takes — an int here was the mock's own invention.
  final String id;

  /// Who is going. `runner.displayName`, and a placeholder when the feed could
  /// not resolve the directory lookup (the API sends no `runner` then).
  final String name;
  final String runnerId;
  final String avatarInitial;
  final String? avatarUrl;

  /// `destination.name`. A public endpoint name — never an address.
  final String destination;

  /// `origin.name`. The same: the area they set off from, rounded by the server.
  final String dormitory;

  /// `departureAt`, already formatted for reading — "14:30 น.".
  final String departureTime;

  final int totalSlots;
  final int filledSlots;
  final double rating;
  final int reviewCount;

  /// Return time. The API has no such field — a trip publishes when it leaves,
  /// not when it gets back — so this is empty on a real feed and the card
  /// simply omits the line.
  final String eta;

  /// The small outlined markers under the route: what the runner charges, and
  /// how far away they are. Derived when the trip is read, so the card stays
  /// the one place that decides how a trip *looks*.
  final List<String> tags;

  /// `food` | `mart` | `pharmacy` | `drink`, for the feed's filter chips.
  ///
  /// The API has no category on a trip — a trip is a journey, not a shop — so
  /// this is read from the destination's name. See `HomeModel._categoryOf`.
  final String category;

  /// Metres from the caller to the end of the trip that matched. Null when the
  /// feed was drawn from the fallback coordinate, where a distance would be a
  /// number nothing measured.
  final int? distanceMeters;

  /// The runner's own terms for whoever asks them for something.
  final String note;

  /// `OPEN` | `IN_PROGRESS` | `COMPLETED` | `CANCELLED`.
  final String status;

  /// Where the trip ends, from `route.destination`.
  ///
  /// The feed publishes this one **exactly** — it is a shop, not somebody's
  /// home — while `route.origin` stays rounded to about a kilometre. It is
  /// carried because placing an order needs the shop's coordinate: an order
  /// names its own store, and this is the one the runner is already going to.
  final double? destinationLatitude;
  final double? destinationLongitude;

  /// The ค่ารับฝาก the runner published, in satang, when they published one at
  /// all. Null under REQUESTER_OFFER, where the requester names the figure —
  /// and a zero there would read as "free".
  final int? feeSatang;

  bool get runnerSetsFee => feeSatang != null;

  int get availableSlots => totalSlots - filledSlots;
  bool get isFull => availableSlots <= 0;

  /// Whether this trip still takes requests. A trip that has set off is still
  /// worth reading and is no longer worth asking.
  bool get isOpen => status == 'OPEN' && !isFull;

  @override
  List<Object?> get props => [
        id,
        runnerId,
        name,
        avatarInitial,
        avatarUrl,
        destination,
        dormitory,
        departureTime,
        totalSlots,
        filledSlots,
        rating,
        reviewCount,
        eta,
        tags,
        category,
        distanceMeters,
        note,
        status,
        destinationLatitude,
        destinationLongitude,
        feeSatang,
      ];
}
