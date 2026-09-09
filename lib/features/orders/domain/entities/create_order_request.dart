/// What the requester decides when they leave something with a traveller.
///
/// The shape `POST /api/v1/trips/{tripId}/orders` takes, in the units the form
/// collects — **baht**, converted to satang once, at the datasource. Nothing
/// here is a calculated total: the server owns the arithmetic, and a client
/// that computed a figure would be a second opinion about money.
class CreateOrderRequest {
  const CreateOrderRequest({
    required this.tripId,
    required this.storeName,
    required this.storeLatitude,
    required this.storeLongitude,
    required this.itemName,
    required this.quantity,
    required this.expectedPrice,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    this.deliveryName = '',
    this.rewardAmount = 0,
    this.note = '',
  });

  final String tripId;

  /// The shop the runner is already going to — the trip's own destination.
  final String storeName;
  final double storeLatitude;
  final double storeLongitude;

  final String itemName;
  final int quantity;

  /// What the requester thinks it costs, per piece, in baht. It becomes the
  /// **ceiling** the runner may spend: `maxItemBudget`. Anything unspent comes
  /// straight back when the errand settles, so a generous figure costs nothing.
  final int expectedPrice;

  /// Where the goods are wanted.
  final double deliveryLatitude;
  final double deliveryLongitude;
  final String deliveryName;

  /// The ค่ารับฝาก, in baht.
  ///
  /// Sent only where the trip lets the requester name it. On a trip whose
  /// runner published a rate the server calculates this from that rate and
  /// ignores whatever arrives here — which is why nothing on this screen
  /// pretends to be the figure.
  final int rewardAmount;

  final String note;
}
