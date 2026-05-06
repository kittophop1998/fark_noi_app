import 'package:flutter/material.dart';

/// Widget แสดงสถานะ Error พร้อม icon และปุ่ม retry
///
/// ใช้สำหรับ full-screen error state ใน page หลัก
///
/// ตัวอย่างการใช้งาน:
/// ```dart
/// if (store.hasError)
///   AppErrorView(
///     message: store.errorMessage!,
///     onRetry: store.fetchData,
///   )
/// ```
class AppErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  const AppErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    this.retryLabel = 'ลองอีกครั้ง',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
