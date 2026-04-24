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

  const HomeEntity({
    required this.id,
    required this.name,
    required this.avatarInitial,
    required this.destination,
    required this.dormitory,
    required this.departureTime,
    required this.totalSlots,
    required this.filledSlots,
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
      ];
}
