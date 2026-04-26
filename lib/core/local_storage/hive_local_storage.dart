import 'package:hive_flutter/hive_flutter.dart';

import 'hive_box_keys.dart';
import 'local_storage_service.dart';

/// Hive implementation ของ [LocalStorageService]
///
/// วิธีใช้งาน:
/// ```dart
/// final storage = sl<LocalStorageService>();
///
/// // เขียน
/// await storage.writeString(box: HiveBoxKeys.authBox, key: HiveBoxKeys.accessToken, value: 'abc123');
///
/// // อ่าน
/// final token = storage.readString(box: HiveBoxKeys.authBox, key: HiveBoxKeys.accessToken);
///
/// // ลบ
/// await storage.delete(box: HiveBoxKeys.authBox, key: HiveBoxKeys.accessToken);
///
/// // ลบทั้งหมด (logout)
/// await storage.clearAll();
/// ```
class HiveLocalStorage extends LocalStorageService {
  /// รายชื่อ box ที่ต้องเปิดก่อนใช้งาน
  static const List<String> _boxes = [
    HiveBoxKeys.authBox,
    HiveBoxKeys.settingsBox,
    HiveBoxKeys.cacheBox,
  ];

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// เรียกใน `main.dart` หลัง `Hive.initFlutter()`
  static Future<void> openBoxes() async {
    for (final boxName in _boxes) {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<dynamic>(boxName);
      }
    }
  }

  // ── Private helper ────────────────────────────────────────────────────────

  Box<dynamic> _box(String boxName) {
    if (!Hive.isBoxOpen(boxName)) {
      throw HiveError(
        'Box "$boxName" ยังไม่ได้เปิด — เรียก HiveLocalStorage.openBoxes() ก่อน',
      );
    }
    return Hive.box<dynamic>(boxName);
  }

  // ── LocalStorageService implementation ───────────────────────────────────

  @override
  Future<void> write<T>({
    required String box,
    required String key,
    required T value,
  }) async {
    await _box(box).put(key, value);
  }

  @override
  T? read<T>({
    required String box,
    required String key,
    T? defaultValue,
  }) {
    return _box(box).get(key, defaultValue: defaultValue) as T?;
  }

  @override
  Future<void> delete({
    required String box,
    required String key,
  }) async {
    await _box(box).delete(key);
  }

  @override
  Future<void> clearBox(String box) async {
    await _box(box).clear();
  }

  @override
  Future<void> clearAll() async {
    for (final boxName in _boxes) {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box<dynamic>(boxName).clear();
      }
    }
  }
}
