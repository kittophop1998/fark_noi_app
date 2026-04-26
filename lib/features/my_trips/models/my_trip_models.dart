// ─── My Trip Domain Models ──────────────────────────────────────────────────

/// สถานะของทริป
enum TripStatus {
  accepting,   // กำลังรับออเดอร์อยู่
  shopping,    // ออกเดินทางแล้ว กำลังซื้อของ
  delivering,  // กลับมาแล้ว รอส่งของ
  completed,   // จบงานแล้ว
}

extension TripStatusLabel on TripStatus {
  String get label {
    switch (this) {
      case TripStatus.accepting:   return 'กำลังรับออเดอร์';
      case TripStatus.shopping:    return 'กำลังซื้อของ';
      case TripStatus.delivering:  return 'รอส่งมอบของ';
      case TripStatus.completed:   return 'จบงานแล้ว';
    }
  }

  String get emoji {
    switch (this) {
      case TripStatus.accepting:   return '🟢';
      case TripStatus.shopping:    return '🛒';
      case TripStatus.delivering:  return '📦';
      case TripStatus.completed:   return '✅';
    }
  }
}

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

/// ออเดอร์ 1 รายการจากคนฝาก 1 คน
class MyOrderItem {
  final String id;
  final String buyerName;       // ชื่อคนฝาก
  final String buyerInitial;    // อักษรย่อ
  final String itemDescription; // รายการสินค้า เช่น "ข้าวมันไก่ + ไข่ดาว"
  final double? estimatedPrice; // ราคาประเมิน
  final OutOfStockPreference outOfStockPref;
  final String? note;           // โน้ตพิเศษ
  bool isChecked;               // ซื้อแล้ว (checklist)
  bool isDelivered;             // ส่งมอบแล้ว
  double? finalPrice;           // ราคาจริงที่ใส่ตอนสรุปยอด

  MyOrderItem({
    required this.id,
    required this.buyerName,
    required this.buyerInitial,
    required this.itemDescription,
    this.estimatedPrice,
    this.outOfStockPref = OutOfStockPreference.substitute,
    this.note,
    this.isChecked = false,
    this.isDelivered = false,
    this.finalPrice,
  });

  MyOrderItem copyWith({
    bool? isChecked,
    bool? isDelivered,
    double? finalPrice,
  }) {
    return MyOrderItem(
      id: id,
      buyerName: buyerName,
      buyerInitial: buyerInitial,
      itemDescription: itemDescription,
      estimatedPrice: estimatedPrice,
      outOfStockPref: outOfStockPref,
      note: note,
      isChecked: isChecked ?? this.isChecked,
      isDelivered: isDelivered ?? this.isDelivered,
      finalPrice: finalPrice ?? this.finalPrice,
    );
  }
}

/// ทริปของผู้ใช้ (runner)
class MyTrip {
  final String id;
  final String destination;     // ที่หมาย
  final String pickupPoint;     // จุดนัดรับ
  final String departureTime;   // เวลาออก
  final String eta;             // เวลาคาดกลับ
  final int totalSlots;         // slot ทั้งหมด
  final String category;        // food / mart / pharmacy / drink
  TripStatus status;
  List<MyOrderItem> orders;
  DateTime? arrivedAt;          // เวลาที่กด "ถึงจุดนัดรับ"

  MyTrip({
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
  });

  int get filledSlots => orders.length;
  int get availableSlots => totalSlots - filledSlots;
  bool get isFull => availableSlots <= 0;
  int get checkedCount => orders.where((o) => o.isChecked).length;
  int get deliveredCount => orders.where((o) => o.isDelivered).length;
  bool get allChecked => orders.isNotEmpty && orders.every((o) => o.isChecked);
  bool get allDelivered =>
      orders.isNotEmpty && orders.every((o) => o.isDelivered);
}
