import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_router.dart';
import '../store/home_store.dart';
import '../widgets/home_content.dart';

const _kOrange = Color(0xFFF57C00);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeStore _store;

  @override
  void initState() {
    super.initState();
    _store = sl<HomeStore>();
    _store.fetchHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F7),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ฝากของหน่อย 🛍️',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1C1B1F),
              ),
            ),
            Text(
              'มีคนรอช่วยซื้ออยู่นะ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: Color(0xFF1C1B1F)),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Observer(
        builder: (_) {
          if (_store.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1E7B4B)),
            );
          }
          if (_store.hasError) {
            return _ErrorView(
              message: _store.errorMessage!,
              onRetry: _store.fetchHomeData,
            );
          }
          if (_store.isEmpty) {
            return const Center(child: Text('ยังไม่มีคนจะไปซื้อของ'));
          }
          return HomeContent(items: _store.items);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(AppRoutes.postTrip);
        },
        backgroundColor: _kOrange,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
        label: const Text(
          'ฉันจะไปซื้อของ',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

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
              child: const Text('ลองอีกครั้ง'),
            ),
          ],
        ),
      ),
    );
  }
}
