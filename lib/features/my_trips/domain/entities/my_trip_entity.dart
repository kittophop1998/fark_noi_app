import 'package:equatable/equatable.dart';

// ─── Trip Status ─────────────────────────────────────────────────────────────

/// สถานะของทริป
///
/// Four of these are the API's own (`OPEN`, `IN_PROGRESS`, `COMPLETED`,
/// `CANCELLED`); [delivering] is the app's alone. The server has no "I am back
/// at the meeting point" state for a trip — that milestone lives per *order*,
/// as `DELIVERING` — but the runner's screen needs it as one moment, because
/// arriving is what they announce to everybody waiting at once. It is entered
/// locally, and [MyTripEntity.arrivedAt] is when.
enum TripStatus {
  accepting,  // กำลังรับออเดอร์อยู่          — OPEN
  shopping,   // ออกเดินทางแล้ว กำลังซื้อของ  — IN_PROGRESS
  delivering, // กลับมาแล้ว รอส่งของ          — IN_PROGRESS + arrivedAt
  completed,  // จบงานแล้ว                    — COMPLETED
  cancelled,  // ยกเลิกแล้ว                   — CANCELLED
}

/// The four values `TripResponse.status` can hold, read into [TripStatus].
///
/// `IN_PROGRESS` resolves to [TripStatus.shopping]; a trip only becomes
/// [TripStatus.delivering] once its runner says so on this device.
TripStatus tripStatusFromWire(String? wire) {
  switch (wire) {
    case 'IN_PROGRESS':
      return TripStatus.shopping;
    case 'COMPLETED':
      return TripStatus.completed;
    case 'CANCELLED':
      return TripStatus.cancelled;
    case 'OPEN':
    default:
      return TripStatus.accepting;
  }
}

extension TripStatusLabel on TripStatus {
  String get label {
    switch (this) {
      case TripStatus.accepting:
        return 'กำลังรับออเดอร์';
      case TripStatus.shopping:
        return 'กำลังซื้อของ';
      case TripStatus.delivering:
        return 'รอส่งมอบของ';
      case TripStatus.completed:
        return 'จบงานแล้ว';
      case TripStatus.cancelled:
        return 'ยกเลิกแล้ว';
    }
  }

  String get emoji {
    switch (this) {
      case TripStatus.accepting:
        return '🟢';
      case TripStatus.shopping:
        return '🛒';
      case TripStatus.delivering:
        return '📦';
      case TripStatus.completed:
        return '✅';
      case TripStatus.cancelled:
        return '⛔';
    }
  }
}

// ─── Out-of-Stock Preference ──────────────────────────────────────────────────

/// ตัวเลือกกรณีสินค้าหมด
enum OutOfStockPreference {
  substitute, // เปลี่ยนเป็นอย่างอื่นที่มี
  skip,       // ไม่เอาเลย
}

extension OutOfStockLabel on OutOfStockPreference {
  String get label => this == OutOfStockPreference.substitute
      ? 'เปลี่ยนเป็นอย่างอื่นที่มี'
      : 'ไม่เอาเลย ถ้าหมด';
}

// ─── MyOrderItem Entity ───────────────────────────────────────────────────────

/// ออเดอร์ 1 รายการจากคนฝาก 1 คน
class MyOrderItem extends Equatable {
  final String id;
  final String buyerId;         // ผู้ฝากคนนี้ — reviewee ของรีวิวที่รันเนอร์ให้
  final String buyerName;       // ชื่อคนฝาก
  final String buyerInitial;    // อักษรย่อ

  /// The single line item's own id — every order this app creates carries
  /// exactly one. `PurchaseOrderRequest.items[].orderItemId` needs it; empty
  /// for an order read before this field existed on the client.
  final String orderItemId;
  final String itemDescription; // รายการสินค้า เช่น "ข้าวมันไก่ + ไข่ดาว"
  final double? estimatedPrice; // ราคาประเมิน
  final OutOfStockPreference outOfStockPref;
  final String? note;           // โน้ตพิเศษ
  final bool isChecked;         // ซื้อแล้ว (checklist)
  final bool isDelivered;       // ส่งมอบแล้ว
  final double? finalPrice;     // ราคาจริงที่ใส่ตอนสรุปยอด

  /// The order's own status on the wire — `REQUESTED`, `ACCEPTED`,
  /// `PURCHASING`, `PURCHASED`, `DELIVERING`, `DELIVERED`, `COMPLETED`,
  /// `REJECTED`, `CANCELLED`.
  ///
  /// [isChecked] and [isDelivered] are derived from it when the trip is read
  /// and then moved optimistically as the runner taps, so the checklist stays
  /// responsive while the call is in flight. This field is what the truth was
  /// last time the server was asked.
  final String status;

  /// The ค่ารับฝาก this errand pays the runner, in baht. Satang on the wire;
  /// the client divides once, at its own edge.
  final double rewardAmount;

  /// The ceiling the requester authorised for the goods, in baht.
  final double maxItemBudget;

  /// The requester's phone, disclosed by the API only to the assigned runner
  /// and only once delivery has arrived. Null everywhere else.
  final String? buyerPhone;

  /// Present only while DELIVERED and the runner has a payment account —
  /// `OrderPayment` on the wire. Its presence is the server's own "ask for the
  /// money now" signal, which is what draws the receiving QR on this order.
  final double? paymentAmount;

  /// Whether the caller has already rated this errand — `OrderReviews.mine`
  /// read back onto the row, so a completed order that was already reviewed
  /// does not offer the form a second time.
  final bool alreadyReviewed;

  const MyOrderItem({
    required this.id,
    this.buyerId = '',
    required this.buyerName,
    required this.buyerInitial,
    this.orderItemId = '',
    required this.itemDescription,
    this.estimatedPrice,
    this.outOfStockPref = OutOfStockPreference.substitute,
    this.note,
    this.isChecked = false,
    this.isDelivered = false,
    this.finalPrice,
    this.status = 'ACCEPTED',
    this.rewardAmount = 0,
    this.maxItemBudget = 0,
    this.buyerPhone,
    this.paymentAmount,
    this.alreadyReviewed = false,
  });

  /// A request the runner has not answered yet. It holds no seat until they do.
  bool get isPending => status == 'REQUESTED' || status == 'WAITING_MATCH';

  /// Off the trip — refused, called off, or timed out.
  bool get isClosed =>
      status == 'REJECTED' || status == 'CANCELLED' || status == 'EXPIRED';

  /// The runner has said "ถึงร้านแล้ว" and may now record what they bought.
  bool get isPurchasing => status == 'PURCHASING';

  /// Bought, and ready for "ออกส่ง".
  bool get isPurchased => status == 'PURCHASED';

  /// Out for handover.
  bool get isOutForDelivery => status == 'DELIVERING';

  /// Handed over; the money is still owed.
  bool get isAwaitingPayment => status == 'DELIVERED';

  bool get isCompleted => status == 'COMPLETED';

  MyOrderItem copyWith({
    bool? isChecked,
    bool? isDelivered,
    double? finalPrice,
    String? status,
    bool? alreadyReviewed,
  }) {
    return MyOrderItem(
      id: id,
      buyerId: buyerId,
      buyerName: buyerName,
      buyerInitial: buyerInitial,
      orderItemId: orderItemId,
      itemDescription: itemDescription,
      estimatedPrice: estimatedPrice,
      outOfStockPref: outOfStockPref,
      note: note,
      isChecked: isChecked ?? this.isChecked,
      isDelivered: isDelivered ?? this.isDelivered,
      finalPrice: finalPrice ?? this.finalPrice,
      status: status ?? this.status,
      rewardAmount: rewardAmount,
      maxItemBudget: maxItemBudget,
      buyerPhone: buyerPhone,
      paymentAmount: paymentAmount,
      alreadyReviewed: alreadyReviewed ?? this.alreadyReviewed,
    );
  }

  @override
  List<Object?> get props => [
        id,
        buyerId,
        buyerName,
        buyerInitial,
        orderItemId,
        itemDescription,
        estimatedPrice,
        outOfStockPref,
        note,
        isChecked,
        isDelivered,
        finalPrice,
        status,
        rewardAmount,
        maxItemBudget,
        buyerPhone,
        paymentAmount,
        alreadyReviewed,
      ];
}

// ─── MyTrip Entity ────────────────────────────────────────────────────────────

/// ทริปของผู้ใช้ (runner)
class MyTripEntity extends Equatable {
  final String id;
  final String destination;    // ที่หมาย
  final String pickupPoint;    // จุดนัดรับ
  final String departureTime;  // เวลาออก
  final String eta;            // เวลาคาดกลับ
  final int totalSlots;        // slot ทั้งหมด
  final String category;       // food / mart / pharmacy / drink
  final TripStatus status;
  final List<MyOrderItem> orders;
  final DateTime? arrivedAt;   // เวลาที่กด "ถึงจุดนัดรับ"

  /// The runner's own terms, as they wrote them on the trip.
  final String note;

  const MyTripEntity({
    required this.id,
    required this.destination,
    required this.pickupPoint,
    required this.departureTime,
    required this.eta,
    required this.totalSlots,
    this.category = 'food',
    this.status = TripStatus.accepting,
    required this.orders,
    this.arrivedAt,
    this.note = '',
  });

  /// Over, one way or the other. The two endings read differently on screen but
  /// behave the same: nothing on the trip can be acted on any more.
  bool get isFinished =>
      status == TripStatus.completed || status == TripStatus.cancelled;

  /// Orders that still occupy a seat — everything except the ones that were
  /// refused, called off, or timed out. A rejected request frees the slot it
  /// never should have kept.
  int get filledSlots => orders.where((o) => !o.isClosed).length;
  int get availableSlots => totalSlots - filledSlots;
  bool get isFull => availableSlots <= 0;

  /// Accepted errands the runner is actually on the hook for — a pending
  /// request has not been taken on yet, and a closed one never will be, so
  /// neither belongs in a denominator about shopping progress.
  List<MyOrderItem> get activeOrders =>
      orders.where((o) => !o.isPending && !o.isClosed).toList();

  int get checkedCount => activeOrders.where((o) => o.isChecked).length;
  int get deliveredCount => activeOrders.where((o) => o.isDelivered).length;
  bool get allChecked =>
      activeOrders.isNotEmpty && activeOrders.every((o) => o.isChecked);
  bool get allDelivered =>
      activeOrders.isNotEmpty && activeOrders.every((o) => o.isDelivered);

  MyTripEntity copyWith({
    TripStatus? status,
    List<MyOrderItem>? orders,
    DateTime? arrivedAt,
  }) {
    return MyTripEntity(
      id: id,
      destination: destination,
      pickupPoint: pickupPoint,
      departureTime: departureTime,
      eta: eta,
      totalSlots: totalSlots,
      category: category,
      status: status ?? this.status,
      orders: orders ?? this.orders,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      note: note,
    );
  }

  @override
  List<Object?> get props => [
        id,
        destination,
        pickupPoint,
        departureTime,
        eta,
        totalSlots,
        category,
        status,
        orders,
        arrivedAt,
        note,
      ];
}
