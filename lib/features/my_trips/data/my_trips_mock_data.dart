import '../models/my_trip_models.dart';

/// Mock active trip — ใช้แทนข้อมูลจาก backend ระหว่าง dev
class MyTripsMockData {
  /// ทริปที่กำลัง Active อยู่ (null = ไม่มีทริปที่เปิดอยู่)
  static MyTrip? getActiveTrip() {
    return MyTrip(
      id: 'trip_001',
      destination: 'Big C รังสิต',
      pickupPoint: 'หน้าเซเว่น ประตูเชียงราก',
      departureTime: '14:30 น.',
      eta: '~16:00 น.',
      totalSlots: 5,
      category: 'food',
      status: TripStatus.accepting,
      orders: [
        MyOrderItem(
          id: 'order_001',
          buyerName: 'มุก',
          buyerInitial: 'ม',
          itemDescription: 'ข้าวมันไก่ไข่ดาว (Big C สาขา)',
          estimatedPrice: 55.0,
          outOfStockPref: OutOfStockPreference.substitute,
          note: 'ไม่เอาซอสพริก',
        ),
        MyOrderItem(
          id: 'order_002',
          buyerName: 'บิ๊ก',
          buyerInitial: 'บ',
          itemDescription: 'น้ำดื่ม Puriku 1.5L × 2 ขวด',
          estimatedPrice: 40.0,
          outOfStockPref: OutOfStockPreference.substitute,
        ),
        MyOrderItem(
          id: 'order_003',
          buyerName: 'พลอย',
          buyerInitial: 'พ',
          itemDescription: 'ขนมปังกระเทียม + นมช็อกโกแลต',
          estimatedPrice: 70.0,
          outOfStockPref: OutOfStockPreference.skip,
          note: 'ถ้าขนมปังหมดก็ไม่เอาเลยนะ',
        ),
      ],
    );
  }

  /// ประวัติทริปที่จบแล้ว
  static List<MyTrip> getCompletedTrips() {
    return [
      MyTrip(
        id: 'trip_past_001',
        destination: 'เทสโก้ โลตัส รังสิต',
        pickupPoint: 'หอ B ชั้น 2 ห้อง 105',
        departureTime: '10:00 น.',
        eta: '~11:30 น.',
        totalSlots: 4,
        category: 'mart',
        status: TripStatus.completed,
        orders: [
          MyOrderItem(
            id: 'h_001',
            buyerName: 'ต้น',
            buyerInitial: 'ต',
            itemDescription: 'ผงซักฟอกแฟ้บ + น้ำยาล้างจาน',
            isChecked: true,
            isDelivered: true,
            finalPrice: 95.0,
          ),
          MyOrderItem(
            id: 'h_002',
            buyerName: 'แนน',
            buyerInitial: 'น',
            itemDescription: 'โยเกิร์ต Meji × 4 ถ้วย',
            isChecked: true,
            isDelivered: true,
            finalPrice: 80.0,
          ),
        ],
      ),
    ];
  }
}
