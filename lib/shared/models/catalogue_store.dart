/// A shop the platform keeps on file, as `GET /api/v1/stores` answers with it.
///
/// Shared rather than owned by one feature: the same row is the destination of
/// a trip being opened and the shop an order is for, and two readings of it
/// would be two places for a coordinate to be wrong.
class CatalogueStore {
  const CatalogueStore({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.branchName = '',
    this.address = '',
    this.category = '',
    this.distanceMeters,
  });

  final String id;
  final String name;

  /// Tells two branches of one chain apart. Empty for a shop that is not one.
  final String branchName;

  final String address;
  final String category;
  final double latitude;
  final double longitude;

  /// Present only when the search carried a coordinate. Absent means "not
  /// measured", never zero metres away.
  final int? distanceMeters;

  /// What a chip or a row shows: the chain and the branch as one phrase.
  String get label => branchName.isEmpty ? name : '$name $branchName';

  factory CatalogueStore.fromJson(Map<String, dynamic> json) {
    return CatalogueStore(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      branchName: json['branchName'] as String? ?? '',
      address: json['address'] as String? ?? '',
      category: json['category'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      distanceMeters: json['distanceMeters'] is num
          ? (json['distanceMeters'] as num).round()
          : null,
    );
  }

  /// The distance as a phrase, or null when nothing measured one.
  String? get distanceLabel {
    final metres = distanceMeters;
    if (metres == null) return null;
    return metres < 1000
        ? '$metres ม.'
        : '${(metres / 1000).toStringAsFixed(1)} กม.';
  }
}
