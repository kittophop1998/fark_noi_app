import 'package:equatable/equatable.dart';

/// Runner = คนที่จะไปซื้อของและรับฝากสินค้า
class HomeEntity extends Equatable {
  final int id;
  final String name;           // ชื่อ runner
  final String avatarInitial;  // อักษรย่อสำหรับ Avatar
  final String destination;    // ที่หมาย เช่น "Big C รามคำแหง"
  final String dormitory;      // ที่อยู่ เช่น "หอ A ตึก 3 ห้อง 201"
  final String departureTime;  // เวลาออก เช่น "14:30 น."
  final int totalSlots;        // จำนวน slot ทั้งหมด
  final int filledSlots;       // slot ที่ถูกจองแล้ว
  final double rating;         // คะแนน เช่น 4.9
  final int reviewCount;       // จำนวนรีวิว
  final String eta;            // เวลากลับถึงหอ เช่น "~15:30 น."
  final List<String> tags;     // เช่น ['ของกิน', 'ไม่รับของหนัก']
  final String category;       // หมวดหมู่หลัก เช่น 'food', 'mart', 'pharmacy', 'drink'

  const HomeEntity({
    required this.id,
    required this.name,
    required this.avatarInitial,
    required this.destination,
    required this.dormitory,
    required this.departureTime,
    required this.totalSlots,
    required this.filledSlots,
    this.rating = 5.0,
    this.reviewCount = 0,
    this.eta = '',
    this.tags = const [],
    this.category = 'food',
  });

  int get availableSlots => totalSlots - filledSlots;
  bool get isFull => availableSlots <= 0;

  @override
  List<Object?> get props => [
        id,
        name,
        avatarInitial,
        destination,
        dormitory,
        departureTime,
        totalSlots,
        filledSlots,
        rating,
        reviewCount,
        eta,
        tags,
        category,
      ];
}
