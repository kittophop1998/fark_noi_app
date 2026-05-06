# Fark Noi 🛒

> **"ฝากน้อย"** — แอปฝากซื้อของในหมู่บ้าน/หอพัก  
> Flutter boilerplate สำหรับ project ใหม่ที่วางโครงสร้างตาม **Clean Architecture**

---

## 📋 Tech Stack

| Category | Library / Version |
|---|---|
| **Flutter SDK** | `>=3.1.3 <4.0.0` |
| **Dart SDK** | `>=3.1.3 <4.0.0` |
| **Android Gradle Plugin** | `8.1.0` |
| **Gradle Wrapper** | `8.3` |
| **Kotlin** | `1.9.10` |
| **compileSdk / targetSdk** | `34` |
| **minSdk** | `21` (Android 5.0+) |
| **State Management** | MobX `^2.3.3` + flutter_mobx `^2.2.1` |
| **Dependency Injection** | get_it `^7.6.4` |
| **Navigation** | go_router `^12.1.1` |
| **Networking** | Dio `^5.3.3` |
| **Local Storage** | Hive `^2.2.3` + flutter_secure_storage `^9.0.0` + shared_preferences `^2.2.2` |
| **Functional** | dartz `^0.10.1` |
| **Testing** | mocktail `^1.0.1` |

---

## 🏛️ Clean Architecture Overview

โปรเจกต์นี้แบ่งโค้ดออกเป็น 3 ชั้นหลักตาม Clean Architecture:

```
Presentation  ──▶  Domain  ──▶  Data
(UI / Store)       (UseCase      (Repository Impl /
                    Entity        DataSource / Model)
                    Repository)
```

**กฎสำคัญ:** ทิศทาง dependency ไหลเข้าหา Domain เสมอ  
Domain ไม่รู้จัก Presentation หรือ Data เลย

---

## 📁 Project Structure

```
lib/
├── main.dart                   # Entry point — init Hive, DI, run app
├── app.dart                    # MaterialApp.router + Theme + Router
│
├── core/                       # โครงสร้างพื้นฐานที่ทุก feature ใช้ร่วมกัน
│   ├── constants/
│   │   ├── app_colors.dart     # Design system palette (60-30-10 rule)
│   │   ├── app_constants.dart  # Base URL, timeout, misc config
│   │   └── app_strings.dart    # Text constants
│   ├── di/
│   │   └── injection_container.dart  # GetIt service locator setup
│   ├── errors/
│   │   ├── exceptions.dart     # AppException, ServerException, ...
│   │   └── failures.dart       # Failure (Equatable) — used in domain layer
│   ├── local_storage/
│   │   ├── local_storage_service.dart  # Abstract interface
│   │   ├── hive_local_storage.dart     # Hive implementation
│   │   └── hive_box_keys.dart          # Box name & key constants
│   ├── network/
│   │   └── dio_client.dart     # Dio setup + interceptors + error mapping
│   ├── router/
│   │   └── app_router.dart     # GoRouter config + AppRoutes constants
│   ├── theme/
│   │   └── app_theme.dart      # Light & Dark ThemeData
│   ├── utils/
│   │   ├── extensions.dart     # BuildContext / String / DateTime extensions
│   │   └── logger.dart         # App logger wrapper
│   └── widgets/                # (reserved for core-level widgets)
│
├── features/                   # แต่ละ feature มีครบ 3 layer
│   ├── home/
│   │   ├── data/
│   │   │   ├── datasources/    # HomeRemoteDataSource + HomeMockDataSource
│   │   │   ├── models/         # HomeModel (fromJson / toJson)
│   │   │   └── repositories/   # HomeRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/       # HomeEntity (Equatable, no JSON logic)
│   │   │   ├── repositories/   # HomeRepository (abstract)
│   │   │   └── usecases/       # GetHomeDataUseCase
│   │   └── presentation/
│   │       ├── pages/          # HomePage, TripDetailPage
│   │       ├── store/          # HomeStore (MobX)
│   │       └── widgets/        # HomeContent + feature-specific widgets
│   │
│   ├── post_trip/              # เปิดรับฝากออเดอร์
│   ├── my_trips/               # ดูทริปที่กำลัง active + ประวัติ
│   ├── notifications/          # การแจ้งเตือน
│   └── profile/                # โปรไฟล์ผู้ใช้
│
└── shared/                     # Widget / Model ที่ใช้ข้าม feature
    ├── models/
    │   └── prompt_pay_config.dart   # ข้อมูล PromptPay (shared config)
    ├── services/               # (reserved)
    └── widgets/
        ├── app_button.dart     # ElevatedButton / OutlinedButton wrapper
        ├── app_text_field.dart # TextField wrapper
        ├── app_error_view.dart # Full-screen error state + retry button
        ├── loading_overlay.dart# Semi-transparent loading overlay
        ├── noti_badge.dart     # Notification count badge (dot / number)
        └── pulse_dot_widget.dart # Animated pulsing dot (active status)
```

---

## 🔀 Feature Data Flow

```
HomePage
  └─ HomeStore (MobX)
       └─ GetHomeDataUseCase
            └─ HomeRepository (abstract)
                 └─ HomeRepositoryImpl
                      └─ HomeRemoteDataSource  ← สลับกับ HomeMockDataSource ระหว่าง dev
```

**การสลับ Mock ↔ Real:**  
ใน `lib/core/di/injection_container.dart` ให้เปลี่ยน:

```dart
// Mock (dev)
sl.registerLazySingleton<HomeRemoteDataSource>(() => HomeMockDataSource());

// Real (prod)
sl.registerLazySingleton<HomeRemoteDataSource>(() => HomeRemoteDataSourceImpl(sl()));
```

---

## 🚀 Getting Started

### Prerequisites

| Tool | Version |
|---|---|
| Flutter | `>=3.1.3` (แนะนำ `3.24.x` stable) |
| Dart | `>=3.1.3` |
| fvm (optional) | `latest` — สำหรับจัดการ Flutter version |
| Java / JDK | `17` (Android build) |
| Android Studio / Xcode | ตามระบบปฏิบัติการ |

> ตรวจสอบ Flutter version ของเครื่อง: `flutter --version`

---

### 1. Clone & Install

```bash
git clone https://github.com/kittophop1998/fark_noi_app.git
cd fark_noi_app

# ติดตั้ง dependencies
flutter pub get
```

### 2. Code Generation (MobX + Hive)

```bash
# สร้าง .g.dart files (ต้องรันทุกครั้งที่แก้ไข store หรือ Hive model)
dart run build_runner build --delete-conflicting-outputs
```

### 3. Run

```bash
# Debug mode (default)
flutter run

# Release mode
flutter run --release

# ระบุ device
flutter run -d <device_id>

# ดู device ที่ต่ออยู่
flutter devices
```

---

## 🔧 Environment Config

แก้ไข base URL และค่าต่างๆ ใน:

```
lib/core/constants/app_constants.dart
```

---

## 🧪 Testing

```bash
# รัน unit tests ทั้งหมด
flutter test

# รัน test เฉพาะ file
flutter test test/widget_test.dart
```

---

## 📦 Build

### Android

```bash
# APK
flutter build apk --release

# App Bundle (สำหรับ Play Store)
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

> ⚠️ iOS build ต้องใช้ macOS + Xcode เท่านั้น  
> ⚠️ สำหรับ Release ต้องตั้งค่า signing ใน `android/app/build.gradle` ก่อน

---

## 🧩 Adding a New Feature

> ใช้ template นี้ทุกครั้งเมื่อสร้าง feature ใหม่

```
lib/features/<feature_name>/
├── data/
│   ├── datasources/
│   │   ├── <feature>_remote_datasource.dart   # abstract + impl
│   │   └── <feature>_mock_datasource.dart      # mock สำหรับ dev
│   ├── models/
│   │   └── <feature>_model.dart               # fromJson / toJson / toEntity
│   └── repositories/
│       └── <feature>_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── <feature>_entity.dart              # extends Equatable
│   ├── repositories/
│   │   └── <feature>_repository.dart          # abstract
│   └── usecases/
│       └── <usecase_name>_usecase.dart
└── presentation/
    ├── pages/
    │   └── <feature>_page.dart
    ├── store/
    │   ├── <feature>_store.dart               # MobX store
    │   └── <feature>_store.g.dart             # generated
    └── widgets/
        └── <feature>_content.dart             # feature-specific widgets
```

**Checklist เมื่อสร้าง feature ใหม่:**
- [ ] สร้างไฟล์ครบทุก layer
- [ ] Register ใน `injection_container.dart`
- [ ] เพิ่ม route ใน `app_router.dart`
- [ ] รัน `dart run build_runner build` เพื่อ generate store

---

## 🎨 Design System

ใช้หลัก **60-30-10 Color Rule:**

| Role | % | Color |
|---|---|---|
| Background / Surface / Border | 60% | `bgPage`, `surface`, `border` |
| Text hierarchy | 30% | `textPrimary`, `textSecondary` |
| Primary accent + Action | 10% | `primary` (Charcoal Blue), `action` (Teal) |
| Error / Destructive | — | `error` (Red) |

ดูรายละเอียด: `lib/core/constants/app_colors.dart`

---

## 📝 Shared Widgets

Widget ที่ใช้ข้าม feature ให้วางใน `lib/shared/widgets/` เสมอ

| Widget | ใช้สำหรับ |
|---|---|
| `AppButton` | Primary / Outlined button |
| `AppTextField` | Input field |
| `AppErrorView` | Full-screen error state + retry |
| `LoadingOverlay` | Semi-transparent loading blocker |
| `NotiBadge` | Notification count badge (dot / number) |
| `PulseDotWidget` | Animated pulsing dot (active status) |

---

## 🗺️ Roadmap

- [ ] Auth feature (Login / Register)
- [ ] Connect real backend API
- [ ] Push notifications
- [ ] Payment QR Code generator
- [ ] Rating & Review system
- [ ] Dark mode polish

---

## 👨‍💻 Contributing

Branch naming: `feature/<name>`, `fix/<name>`, `chore/<name>`  
Default branch: `develop`


- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
