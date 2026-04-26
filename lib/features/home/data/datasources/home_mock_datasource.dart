import '../models/home_model.dart';
import 'home_remote_datasource.dart';

/// Mock datasource — ใช้แทน API จริงระหว่าง development
class HomeMockDataSource implements HomeRemoteDataSource {
  @override
  Future<List<HomeModel>> getHomeData() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return const [
      HomeModel(
        id: 1,
        name: 'มิน',
        avatarInitial: 'ม',
        destination: 'Big C รังสิต',
        dormitory: 'หน้าเซเว่น ประตูเชียงราก',
        departureTime: '14:30 น.',
        eta: '~16:00 น.',
        totalSlots: 3,
        filledSlots: 2,
        rating: 4.9,
        reviewCount: 20,
        tags: ['ของกิน', 'สูงสุด 3 ชิ้น'],
        category: 'food',
      ),
      HomeModel(
        id: 2,
        name: 'ปลา',
        avatarInitial: 'ป',
        destination: 'เทสโก้ โลตัส รังสิต',
        dormitory: 'หอ B ชั้น 2 ห้อง 105',
        departureTime: '15:00 น.',
        eta: '~16:30 น.',
        totalSlots: 4,
        filledSlots: 4,
        rating: 4.7,
        reviewCount: 15,
        tags: ['ของกิน', 'ของใช้'],
        category: 'mart',
      ),
      HomeModel(
        id: 3,
        name: 'แพร',
        avatarInitial: 'พ',
        destination: '7-Eleven สาขาหน้าหอ',
        dormitory: 'หน้าลิฟต์ชั้น 1 ตึก C',
        departureTime: '16:00 น.',
        eta: '~16:30 น.',
        totalSlots: 2,
        filledSlots: 0,
        rating: 5.0,
        reviewCount: 8,
        tags: ['ของกิน', 'เครื่องดื่ม'],
        category: 'drink',
      ),
      HomeModel(
        id: 4,
        name: 'เจ',
        avatarInitial: 'จ',
        destination: 'ร้านยา Boots รังสิต',
        dormitory: 'หอ A ตึก 1 ห้อง 310',
        departureTime: '17:00 น.',
        eta: '~17:45 น.',
        totalSlots: 5,
        filledSlots: 1,
        rating: 4.8,
        reviewCount: 12,
        tags: ['ยา', 'ของใช้'],
        category: 'pharmacy',
      ),
    ];
  }
}
