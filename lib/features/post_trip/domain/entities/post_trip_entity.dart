class PostTripEntity {
  final String destination;
  final String departureTime; // format: "HH:mm"
  final String returnTime; // format: "HH:mm"
  final int maxOrders;
  final int feePerOrder;
  final List<String> categories;
  final String pickupPoint;

  const PostTripEntity({
    required this.destination,
    required this.departureTime,
    required this.returnTime,
    required this.maxOrders,
    required this.feePerOrder,
    required this.categories,
    required this.pickupPoint,
  });
}
