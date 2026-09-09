import '../../domain/entities/home_entity.dart';

/// `NearbyTripResponse` read into [HomeEntity].
///
/// Everything the card shows and the API does not send is derived here rather
/// than in the widget, so the feed and any future search result draw the same
/// trip the same way.
class HomeModel extends HomeEntity {
  const HomeModel({
    required super.id,
    required super.name,
    required super.avatarInitial,
    required super.destination,
    required super.dormitory,
    required super.departureTime,
    required super.totalSlots,
    required super.filledSlots,
    super.runnerId,
    super.avatarUrl,
    super.rating,
    super.reviewCount,
    super.eta,
    super.tags,
    super.category,
    super.distanceMeters,
    super.note,
    super.status,
    super.destinationLatitude,
    super.destinationLongitude,
    super.feeSatang,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    final runner = _map(json['runner']);
    final rating = _map(runner['rating']);
    final origin = _map(json['origin']);
    final destination = _map(json['destination']);
    final pricing = _map(json['pricing']);
    final route = _map(json['route']);
    final routeDestination = _map(route['destination']);

    final displayName = (runner['displayName'] as String?)?.trim() ?? '';
    final destinationName = destination['name'] as String? ?? '';
    final maxOrders = _int(json['maxOrders']);
    final available = _int(json['availableSlots']);
    final distance = json['distanceFromMeMeters'] is num
        ? (json['distanceFromMeMeters'] as num).round()
        : null;

    return HomeModel(
      id: json['id']?.toString() ?? '',
      runnerId: runner['id']?.toString() ?? '',
      // The feed omits `runner` entirely when the directory lookup was
      // unavailable. A trip is still worth showing then — the route and the
      // time are the trip — so the card gets a neutral noun rather than a gap.
      name: displayName.isEmpty ? 'ผู้เดินทาง' : displayName,
      avatarInitial: displayName.isEmpty
          ? '?'
          : String.fromCharCode(displayName.runes.first),
      avatarUrl: (runner['avatarUrl'] as String?)?.isNotEmpty == true
          ? runner['avatarUrl'] as String
          : null,
      destination: destinationName,
      dormitory: origin['name'] as String? ?? '',
      departureTime: formatTime(json['departureAt'] as String?),
      totalSlots: maxOrders,
      // The API sends what is *left*; the card counts what is *taken*. Derived
      // from availableSlots rather than from activeOrderCount, which counts
      // requests still waiting for an answer as well as the ones holding a seat.
      filledSlots: (maxOrders - available).clamp(0, maxOrders),
      rating: (rating['averageRating'] as num?)?.toDouble() ?? 0,
      reviewCount: _int(rating['reviewCount']),
      tags: _tags(pricing: pricing, distanceMeters: distance),
      category: _categoryOf(destinationName),
      distanceMeters: distance,
      note: json['note'] as String? ?? '',
      status: json['status'] as String? ?? 'OPEN',
      destinationLatitude: (routeDestination['latitude'] as num?)?.toDouble(),
      destinationLongitude: (routeDestination['longitude'] as num?)?.toDouble(),
      feeSatang: _feeSatang(pricing),
    );
  }

  /// `departureAt` as a wall clock in the device's zone. The API sends UTC;
  /// a trip leaving at 14:30 has to read as 14:30 to the person deciding
  /// whether they will be back in time.
  static String formatTime(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return '';
    final local = parsed.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute น.';
  }

  /// The markers under the route: what the errand costs, and how far away it
  /// is. Both are the questions a reader asks before opening a card, and
  /// neither is worth a row of its own.
  static List<String> _tags({
    required Map<String, dynamic> pricing,
    int? distanceMeters,
  }) {
    final tags = <String>[];

    // Only a TRAVELER_DEFINED trip has a rate to publish. Under
    // REQUESTER_OFFER there is nothing to print — a zero would read as "free".
    if (pricing['mode'] == 'TRAVELER_DEFINED') {
      final type = pricing['type'];
      if (type == 'FLAT' && pricing['flatFee'] is num) {
        tags.add('ค่าหิ้ว ${_baht(pricing['flatFee'] as num)}');
      } else if (type == 'PER_ITEM' && pricing['pricePerItem'] is num) {
        tags.add('ค่าหิ้ว ${_baht(pricing['pricePerItem'] as num)}/ชิ้น');
      }
    } else {
      tags.add('เสนอค่าหิ้วเองได้');
    }

    if (distanceMeters != null) {
      tags.add(distanceMeters < 1000
          ? 'ห่าง $distanceMeters ม.'
          : 'ห่าง ${(distanceMeters / 1000).toStringAsFixed(1)} กม.');
    }
    return tags;
  }

  /// The published rate in satang, or null when the trip publishes none.
  ///
  /// Only a TRAVELER_DEFINED trip has a rate; under REQUESTER_OFFER the figure
  /// is the requester's to name, and reporting a zero would read as "free".
  static int? _feeSatang(Map<String, dynamic> pricing) {
    if (pricing['mode'] != 'TRAVELER_DEFINED') return null;
    final amount = pricing['type'] == 'PER_ITEM'
        ? pricing['pricePerItem']
        : pricing['flatFee'];
    return amount is num ? amount.toInt() : null;
  }

  /// Satang to a baht label. Every amount this API sends is satang, and the
  /// client divides once, at its own edge.
  static String _baht(num satang) {
    final baht = satang / 100;
    return baht == baht.roundToDouble()
        ? '฿${baht.round()}'
        : '฿${baht.toStringAsFixed(2)}';
  }

  /// Which filter chip a trip falls under.
  ///
  /// A trip has no category on the wire, and it is right that it does not — a
  /// journey is not a shop. But the feed's chips are how somebody narrows a
  /// long list, so the destination's own name is read for the words that decide
  /// it. Unmatched falls to `mart`, the widest of the four, rather than to a
  /// fifth "อื่นๆ" chip the design does not have.
  static String _categoryOf(String destination) {
    final name = destination.toLowerCase();
    bool has(List<String> needles) => needles.any(name.contains);

    if (has(['ยา', 'pharmacy', 'boots', 'watsons', 'ฟาสซิโน', 'save drug'])) {
      return 'pharmacy';
    }
    if (has(['ชา', 'กาแฟ', 'cafe', 'café', 'coffee', 'tea', 'amazon', 'starbucks'])) {
      return 'drink';
    }
    if (has(['ข้าว', 'ก๋วยเตี๋ยว', 'อาหาร', 'ครัว', 'food', 'kfc', 'mcdonald',
        'ร้านอาหาร', 'โรงอาหาร'])) {
      return 'food';
    }
    return 'mart';
  }

  static Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  static int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
}
