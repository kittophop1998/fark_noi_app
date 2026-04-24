import '../../domain/entities/post_trip_entity.dart';

class PostTripModel extends PostTripEntity {
  const PostTripModel({
    required super.destination,
    required super.departureTime,
    required super.returnTime,
    required super.maxOrders,
    required super.feePerOrder,
    required super.categories,
    required super.pickupPoint,
  });

  factory PostTripModel.fromEntity(PostTripEntity entity) => PostTripModel(
        destination: entity.destination,
        departureTime: entity.departureTime,
        returnTime: entity.returnTime,
        maxOrders: entity.maxOrders,
        feePerOrder: entity.feePerOrder,
        categories: entity.categories,
        pickupPoint: entity.pickupPoint,
      );

  Map<String, dynamic> toJson() => {
        'destination': destination,
        'departure_time': departureTime,
        'return_time': returnTime,
        'max_orders': maxOrders,
        'fee_per_order': feePerOrder,
        'categories': categories,
        'pickup_point': pickupPoint,
      };
}
