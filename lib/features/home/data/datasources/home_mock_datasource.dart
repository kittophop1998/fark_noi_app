import '../models/home_model.dart';
import 'home_remote_datasource.dart';

/// Mock datasource — ใช้แทน API จริงระหว่าง development
/// เปลี่ยนกลับไปใช้ [HomeRemoteDataSourceImpl] ใน injection_container.dart เมื่อพร้อม
class HomeMockDataSource implements HomeRemoteDataSource {
  @override
  Future<List<HomeModel>> getHomeData() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return const [
      HomeModel(
        id: 1,
        name: 'มิน',
        avatarInitial: 'ม',
        destination: 'Big C รามคำแหง',
        dormitory: 'หอ A ตึก 3 ห้อง 201',
        departureTime: '14:30 น.',
        totalSlots: 3,
        filledSlots: 2,
      ),
      HomeModel(
        id: 2,
        name: 'ปลา',
        avatarInitial: 'ป',
        destination: 'เทสโก้ โลตัส',
        dormitory: 'หอ B ชั้น 2 ห้อง 105',
        departureTime: '15:00 น.',
        totalSlots: 4,
        filledSlots: 4,
      ),
      HomeModel(
        id: 3,
        name: 'แพร',
        avatarInitial: 'พ',
        destination: '7-Eleven สาขาหน้าหอ',
        dormitory: 'หอ C ชั้น 5 ห้อง 502',
        departureTime: '16:00 น.',
        totalSlots: 2,
        filledSlots: 0,
      ),
      HomeModel(
        id: 4,
        name: 'เจ',
        avatarInitial: 'จ',
        destination: 'Makro ลาดพร้าว',
        dormitory: 'หอ A ตึก 1 ห้อง 310',
        departureTime: '17:30 น.',
        totalSlots: 5,
        filledSlots: 1,
      ),
    ];
  }
}
