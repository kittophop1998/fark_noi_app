import '../entities/my_trip_entity.dart';

/// Abstract repository สำหรับ my_trips feature
abstract class MyTripsRepository {
  /// ดึงทริปที่กำลัง active อยู่ (null = ไม่มีทริปที่เปิดอยู่)
  Future<MyTripEntity?> getActiveTrip();

  /// ดึงประวัติทริปที่จบแล้ว
  Future<List<MyTripEntity>> getCompletedTrips();
}
