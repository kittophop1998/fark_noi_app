import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/create_order_request.dart';

abstract class OrdersDataSource {
  /// Places one request on a trip. Answers 409 when the trip is no longer open
  /// or every seat is taken, and 422 INSUFFICIENT_CREDIT when the requester
  /// cannot fund it — each with its own sentence, which the sheet shows.
  Future<void> createOrder(CreateOrderRequest request);
}

class OrdersRemoteDataSource implements OrdersDataSource {
  const OrdersRemoteDataSource({required this.client});

  final DioClient client;

  @override
  Future<void> createOrder(CreateOrderRequest request) async {
    await client.post(
      ApiEndpoints.tripOrders(request.tripId),
      data: {
        'store': {
          'name': request.storeName,
          'latitude': request.storeLatitude,
          'longitude': request.storeLongitude,
        },
        'items': [
          {
            'name': request.itemName,
            'quantity': request.quantity,
            'expectedPrice': request.expectedPrice * 100,
          },
        ],
        'deliveryLocation': {
          if (request.deliveryName.isNotEmpty) 'name': request.deliveryName,
          'latitude': request.deliveryLatitude,
          'longitude': request.deliveryLongitude,
        },
        'rewardAmount': request.rewardAmount * 100,
        // The ceiling the runner may spend on the goods. It is what the
        // requester's credit is held against together with the reward, so it is
        // the whole item cost rather than the per-piece estimate.
        'maxItemBudget': request.expectedPrice * request.quantity * 100,
        if (request.note.isNotEmpty) 'note': request.note,
      },
    );
  }
}
