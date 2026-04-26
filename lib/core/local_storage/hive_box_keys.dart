/// ชื่อ Box และ Key ทั้งหมดที่ใช้ใน Hive
/// แก้ไขที่นี่ที่เดียวเมื่อต้องการเพิ่ม / เปลี่ยนชื่อ

class HiveBoxKeys {
  HiveBoxKeys._();

  // ──────────────────────────────────────────────
  // Box names  (แต่ละ Box เปรียบเหมือน "ตาราง")
  // ──────────────────────────────────────────────

  /// Box สำหรับข้อมูล session / auth token
  static const String authBox = 'auth_box';

  /// Box สำหรับ user preferences / settings ทั่วไป
  static const String settingsBox = 'settings_box';

  /// Box สำหรับ cache ข้อมูล feature ต่าง ๆ
  static const String cacheBox = 'cache_box';

  // ──────────────────────────────────────────────
  // Keys ภายใน authBox
  // ──────────────────────────────────────────────

  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';

  // ──────────────────────────────────────────────
  // Keys ภายใน settingsBox
  // ──────────────────────────────────────────────

  static const String isDarkMode = 'is_dark_mode';
  static const String locale = 'locale';
  static const String isOnboarded = 'is_onboarded';

  // ──────────────────────────────────────────────
  // Keys ภายใน cacheBox  (ตั้งชื่อตาม feature)
  // ──────────────────────────────────────────────

  static const String homeDataCache = 'home_data_cache';
}
