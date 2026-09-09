import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/my_trip_entity.dart';
import '../models/my_trip_model.dart';
import 'my_trips_datasource.dart';

class MyTripsRemoteDataSource implements MyTripsDataSource {
  const MyTripsRemoteDataSource({required this.client});

  final DioClient client;

  @override
  Future<MyTripEntity?> getActiveTrip() async {
    // The API refuses a second live trip — one runner, one journey — so at most
    // one of these two lists has anything in it, and OPEN is asked for first
    // because that is the trip still taking requests.
    for (final status in const ['OPEN', 'IN_PROGRESS']) {
      final trips = await _listTrips(status: status, limit: 1);
      if (trips.isEmpty) continue;
      final trip = trips.first;
      return MyTripModel.fromJson(
        trip,
        orders: await _orders(trip['id']?.toString() ?? ''),
      );
    }
    return null;
  }

  @override
  Future<List<MyTripEntity>> getCompletedTrips() async {
    final trips = await _listTrips(status: 'COMPLETED', limit: 20);
    // Deliberately without their errands. A history list draws a destination, a
    // time and a count; fetching the orders of twenty trips to render that
    // would be twenty round trips for something no row shows.
    return trips.map((trip) => MyTripModel.fromJson(trip)).toList();
  }

  @override
  Future<void> startTrip(String tripId) async {
    await client.post(ApiEndpoints.tripStart(tripId));
  }

  @override
  Future<void> completeTrip(String tripId) async {
    await client.post(ApiEndpoints.tripComplete(tripId));
  }

  @override
  Future<void> cancelTrip(String tripId) async {
    await client.post(ApiEndpoints.tripCancel(tripId));
  }

  @override
  Future<void> acceptOrder(String orderId) async {
    await client.post(ApiEndpoints.orderAccept(orderId));
  }

  @override
  Future<void> rejectOrder(String orderId, {String? reason}) async {
    await client.post(
      ApiEndpoints.orderReject(orderId),
      data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
    );
  }

  @override
  Future<void> startPurchasing(
    String orderId, {
    double? latitude,
    double? longitude,
  }) async {
    await client.post(
      ApiEndpoints.orderStartPurchasing(orderId),
      data: {
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );
  }

  @override
  Future<void> completeOrder(String orderId) async {
    await client.post(ApiEndpoints.orderComplete(orderId));
  }

  Future<List<Map<String, dynamic>>> _listTrips({
    required String status,
    required int limit,
  }) async {
    final response = await client.get(
      ApiEndpoints.myTrips,
      queryParameters: {'status': status, 'limit': limit, 'page': 1},
    );
    return DioClient.unwrapList(response)
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<List<dynamic>> _orders(String tripId) async {
    if (tripId.isEmpty) return const [];
    final response = await client.get(ApiEndpoints.tripOrders(tripId));
    return DioClient.unwrapList(response);
  }
}
