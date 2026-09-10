import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/profile_datasource.dart';
import '../../domain/entities/reputation_entity.dart';

const _kPrimary = AppColors.primary;
const _kBg = AppColors.background;
const _kTextPrimary = AppColors.text;
const _kTextSecondary = AppColors.muted;
const _kBorder = AppColors.border;

/// `GET /users/{userId}/reviews` for the signed-in user's own id — every
/// review anyone has left them, either side.
class ReviewsPage extends StatefulWidget {
  final String userId;
  const ReviewsPage({super.key, required this.userId});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  late final ProfileDataSource _dataSource = sl<ProfileDataSource>();
  UserReviewsEntity? _data;
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      final data = await _dataSource.userReviews(widget.userId);
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: const BackButton(color: _kTextPrimary),
        title: const Text('รีวิวที่ได้รับ',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _kTextPrimary)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('โหลดรีวิวไม่สำเร็จ',
                          style: TextStyle(color: _kTextSecondary)),
                      const SizedBox(height: 8),
                      TextButton(onPressed: _load, child: const Text('ลองอีกครั้ง')),
                    ],
                  ),
                )
              : _buildList(_data!),
    );
  }

  Widget _buildList(UserReviewsEntity data) {
    if (data.items.isEmpty) {
      return const Center(
        child: Text('ยังไม่มีใครรีวิวคุณ', style: TextStyle(color: _kTextSecondary)),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.rating, size: 28),
              const SizedBox(width: 10),
              Text(
                data.reputation.rated
                    ? data.reputation.averageRating.toStringAsFixed(1)
                    : '—',
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w900, color: _kTextPrimary),
              ),
              const SizedBox(width: 8),
              Text('จาก ${data.total} รีวิว',
                  style: const TextStyle(color: _kTextSecondary, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...data.items.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _kBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(r.reviewerName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: _kTextPrimary)),
                        ),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < r.rating
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              size: 14,
                              color: AppColors.rating,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (r.comment != null) ...[
                      const SizedBox(height: 6),
                      Text(r.comment!,
                          style: const TextStyle(fontSize: 13, color: _kTextPrimary)),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      r.role == 'REQUESTER' ? 'รีวิวในฐานะคนฝาก' : 'รีวิวในฐานะผู้หิ้ว',
                      style: const TextStyle(fontSize: 11, color: _kTextSecondary),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
