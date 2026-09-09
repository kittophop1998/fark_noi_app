import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../shared/models/catalogue_store.dart';
import '../../domain/entities/post_trip_entity.dart';

abstract class PostTripDataSource {
  /// `POST /api/v1/trips`. Answers 409 TRIP_ALREADY_ACTIVE when the runner is
  /// already on one, and 422 OUT_OF_SERVICE_AREA when the origin falls outside
  /// every enabled zone — both carry their own sentence, which the form shows.
  Future<void> createPostTrip(PostTripEntity trip);

  /// The shops to offer as a destination. Nearest first when a coordinate is
  /// given; [term] narrows by name or branch.
  Future<List<CatalogueStore>> searchStores({
    String term = '',
    double? latitude,
    double? longitude,
    int limit = 12,
  });
}

class PostTripRemoteDataSource implements PostTripDataSource {
  const PostTripRemoteDataSource({required this.client});

  final DioClient client;

  @override
  Future<void> createPostTrip(PostTripEntity trip) async {
    await client.post(
      ApiEndpoints.trips,
      data: {
        'origin': {
          'name': trip.originName,
          'latitude': trip.originLatitude,
          'longitude': trip.originLongitude,
        },
        'destination': {
          'name': trip.destination.label,
          if (trip.destination.address.isNotEmpty)
            'address': trip.destination.address,
          'latitude': trip.destination.latitude,
          'longitude': trip.destination.longitude,
        },
        // UTC, which is what RFC 3339 with a `Z` means and what the Go handler
        // parses. The form collects a wall clock in the device's zone.
        'departureAt': trip.departureAt.toUtc().toIso8601String(),
        'maxOrders': trip.maxOrders,
        if (trip.note.isNotEmpty) 'note': trip.note,
        // The runner naming their own rate is TRAVELER_DEFINED, and a flat fee
        // is what this form has always collected — one figure per order rather
        // than per piece. Satang: the app converts once, here.
        'pricing': {
          'mode': 'TRAVELER_DEFINED',
          'type': 'FLAT',
          'flatFee': trip.feePerOrder * 100,
        },
      },
    );
  }

  @override
  Future<List<CatalogueStore>> searchStores({
    String term = '',
    double? latitude,
    double? longitude,
    int limit = 12,
  }) async {
    final response = await client.get(
      ApiEndpoints.stores,
      queryParameters: {
        if (term.trim().isNotEmpty) 'q': term.trim(),
        if (latitude != null) 'lat': latitude,
        if (longitude != null) 'lng': longitude,
        'limit': limit,
      },
    );
    return DioClient.unwrapList(response)
        .whereType<Map>()
        .map((item) => CatalogueStore.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
