/// Abstract interface สำหรับ local storage
/// ทำให้ swap implementation ได้ง่าย (Hive, SharedPreferences, ฯลฯ)

abstract class LocalStorageService {
  // ── Generic read / write ──────────────────────────────────────────────────

  /// เขียน [value] ลง [box] ด้วย [key]
  Future<void> write<T>({
    required String box,
    required String key,
    required T value,
  });

  /// อ่านค่า [T] จาก [box] ด้วย [key]
  /// คืน [defaultValue] ถ้าไม่พบ
  T? read<T>({
    required String box,
    required String key,
    T? defaultValue,
  });

  /// ลบค่าด้วย [key] ออกจาก [box]
  Future<void> delete({
    required String box,
    required String key,
  });

  /// ลบทุก key ใน [box]
  Future<void> clearBox(String box);

  /// ลบทุก box ทั้งหมด (ใช้ตอน logout)
  Future<void> clearAll();

  // ── Helpers สำหรับ primitive types ───────────────────────────────────────

  Future<void> writeString({
    required String box,
    required String key,
    required String value,
  }) =>
      write<String>(box: box, key: key, value: value);

  String? readString({required String box, required String key}) =>
      read<String>(box: box, key: key);

  Future<void> writeBool({
    required String box,
    required String key,
    required bool value,
  }) =>
      write<bool>(box: box, key: key, value: value);

  bool? readBool({required String box, required String key}) =>
      read<bool>(box: box, key: key);

  Future<void> writeInt({
    required String box,
    required String key,
    required int value,
  }) =>
      write<int>(box: box, key: key, value: value);

  int? readInt({required String box, required String key}) =>
      read<int>(box: box, key: key);
}
