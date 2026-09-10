import '../../domain/entities/my_trip_entity.dart';

/// `TripResponse` + its `OrderResponse` list, read into [MyTripEntity].
///
/// The two are fetched separately — `/me/trips` answers with trips and
/// `/trips/{id}/orders` with what is on one — and joined here, because the
/// runner's screen is about a trip *and* the errands on it as one thing.
class MyTripModel {
  MyTripModel._();

  static MyTripEntity fromJson(
    Map<String, dynamic> trip, {
    List<dynamic> orders = const [],
  }) {
    final origin = _map(trip['origin']);
    final destination = _map(trip['destination']);

    return MyTripEntity(
      id: trip['id']?.toString() ?? '',
      destination: destination['name'] as String? ?? '',
      // The runner's own trip, so this is the real pin rather than the rounded
      // area the discovery feed publishes — they are the one person entitled
      // to it. The address is preferred where there is one: "หน้าเซเว่น
      // ประตูเชียงราก" is what somebody waiting needs, not a district name.
      pickupPoint: (origin['address'] as String?)?.isNotEmpty == true
          ? origin['address'] as String
          : origin['name'] as String? ?? '',
      departureTime: formatTime(trip['departureAt'] as String?),
      // The API publishes when a trip leaves, never when it gets back. Left
      // empty rather than guessed — a made-up return time is the one number on
      // this screen somebody would plan around.
      eta: '',
      totalSlots: _int(trip['maxOrders']),
      category: 'food',
      status: tripStatusFromWire(trip['status'] as String?),
      note: trip['note'] as String? ?? '',
      orders: orders
          .whereType<Map>()
          .map((o) => orderFromJson(Map<String, dynamic>.from(o)))
          .toList(),
    );
  }

  /// One `OrderResponse` as a row of the runner's checklist.
  static MyOrderItem orderFromJson(Map<String, dynamic> json) {
    final requester = _map(json['requester']);
    final items = (json['items'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((i) => Map<String, dynamic>.from(i))
        .toList();

    final buyerName = (requester['displayName'] as String?)?.trim() ?? '';
    final status = json['status'] as String? ?? 'ACCEPTED';
    final payment = _map(json['payment']);

    return MyOrderItem(
      id: json['id']?.toString() ?? '',
      buyerId: requester['id']?.toString() ?? '',
      buyerName: buyerName.isEmpty ? 'ผู้ฝาก' : buyerName,
      buyerInitial: buyerName.isEmpty
          ? '?'
          : String.fromCharCode(buyerName.runes.first),
      // An open-request order (`productDescription`, no `items[]` row from the
      // client) still reads back as one purchasable thing — its own id is the
      // only row `purchase` can name, so it stands in for the missing item id
      // rather than sending the server an empty `objectid`.
      orderItemId: items.isNotEmpty
          ? items.first['id']?.toString() ?? ''
          : json['id']?.toString() ?? '',
      buyerPhone: (json['requesterPhone'] as String?)?.isNotEmpty == true
          ? json['requesterPhone'] as String
          : null,
      itemDescription: _describe(json, items),
      estimatedPrice: _bahtOrNull(json['estimatedProductPrice']) ??
          _bahtOrNull(json['maxItemBudget']),
      // The API has no "what if it is out of stock" field. The runner's
      // instruction lives in the free-text note, which is where the requester
      // actually writes it, so the default stands and the note is shown.
      note: (json['note'] as String?)?.isNotEmpty == true
          ? json['note'] as String
          : null,
      status: status,
      rewardAmount: _baht(json['rewardAmount']),
      maxItemBudget: _baht(json['maxItemBudget']),
      // Derived once, here, from where the errand actually is. The screen then
      // moves them optimistically as the runner taps.
      isChecked: _isAtLeast(status, 'PURCHASED'),
      isDelivered: _isAtLeast(status, 'DELIVERED'),
      finalPrice: _bahtOrNull(json['itemTotalAmount']),
      paymentAmount: _bahtOrNull(payment['amount']),
    );
  }

  /// What the runner has to buy, in one line.
  ///
  /// An order carries either a row list (a direct request) or a single
  /// `productDescription` (the open-request form). Both are drawn the same way
  /// on the checklist, so both are flattened here rather than in the widget.
  static String _describe(Map<String, dynamic> json, List<Map<String, dynamic>> items) {
    final description = (json['productDescription'] as String?)?.trim() ?? '';
    if (items.isEmpty) {
      return description.isEmpty ? 'ไม่ได้ระบุรายการ' : description;
    }
    return items.map((item) {
      final name = item['name'] as String? ?? '';
      final quantity = _int(item['quantity']);
      return quantity > 1 ? '$name × $quantity' : name;
    }).join(' + ');
  }

  /// Whether an order has reached a milestone. The statuses are a line, so
  /// "purchased" is true of a delivered order too — a checklist that unticked
  /// itself when the goods were handed over would be a bug the runner had to
  /// work around.
  static const _progression = [
    'WAITING_MATCH',
    'REQUESTED',
    'ACCEPTED',
    'PURCHASING',
    'PURCHASED',
    'DELIVERING',
    'DELIVERED',
    'COMPLETED',
  ];

  static bool _isAtLeast(String status, String milestone) {
    final at = _progression.indexOf(status);
    final target = _progression.indexOf(milestone);
    // A rejected, cancelled or expired order is not on the line at all, and is
    // past no milestone.
    return at >= 0 && target >= 0 && at >= target;
  }

  static String formatTime(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return '';
    final local = parsed.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')} น.';
  }

  /// Satang to baht. Every amount this API sends is satang.
  static double _baht(dynamic satang) =>
      satang is num ? satang / 100 : 0;

  static double? _bahtOrNull(dynamic satang) =>
      satang is num && satang > 0 ? satang / 100 : null;

  static Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  static int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
}
