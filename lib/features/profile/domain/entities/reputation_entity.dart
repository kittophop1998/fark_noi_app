import 'package:equatable/equatable.dart';

/// What everybody who has dealt with this person thinks, and how much they have
/// actually done.
///
/// The counts sit beside the average deliberately: they are the half a friend
/// leaving a review cannot inflate, and they are what makes a 5.0 from one
/// errand readable as what it is.
class ReputationEntity extends Equatable {
  const ReputationEntity({
    this.averageRating = 0,
    this.reviewCount = 0,
    this.rated = false,
    this.completedAsRunner = 0,
    this.completedAsRequester = 0,
    this.cancelledAsRunner = 0,
    this.cancelledAsRequester = 0,
  });

  final double averageRating;
  final int reviewCount;

  /// Whether anybody has reviewed them at all.
  ///
  /// This is what a screen branches on: somebody nobody has reviewed comes back
  /// with an average of 0, which is **not** the same as a bad score and must
  /// never be drawn as one.
  final bool rated;

  final int completedAsRunner;
  final int completedAsRequester;
  final int cancelledAsRunner;
  final int cancelledAsRequester;

  int get completedTotal => completedAsRunner + completedAsRequester;

  factory ReputationEntity.fromJson(Map<String, dynamic> json) {
    final rating = json['rating'] is Map
        ? Map<String, dynamic>.from(json['rating'] as Map)
        : const <String, dynamic>{};
    return ReputationEntity(
      averageRating: (rating['averageRating'] as num?)?.toDouble() ?? 0,
      reviewCount: (rating['reviewCount'] as num?)?.toInt() ?? 0,
      rated: rating['rated'] as bool? ?? false,
      completedAsRunner: (json['completedAsRunner'] as num?)?.toInt() ?? 0,
      completedAsRequester:
          (json['completedAsRequester'] as num?)?.toInt() ?? 0,
      cancelledAsRunner: (json['cancelledAsRunner'] as num?)?.toInt() ?? 0,
      cancelledAsRequester:
          (json['cancelledAsRequester'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        averageRating,
        reviewCount,
        rated,
        completedAsRunner,
        completedAsRequester,
        cancelledAsRunner,
        cancelledAsRequester,
      ];
}

/// The two wallets, in baht.
///
/// Kept apart because they are not interchangeable: the deposit wallet is what
/// an errand is funded out of, the earning wallet is what a runner may withdraw.
/// Presenting them as one figure would tell somebody they hold money they can
/// neither spend nor withdraw.
class CreditBalanceEntity extends Equatable {
  const CreditBalanceEntity({
    this.depositBalance = 0,
    this.depositReserved = 0,
    this.earningBalance = 0,
    this.pendingEarnings = 0,
  });

  final double depositBalance;
  final double depositReserved;
  final double earningBalance;

  /// Earned on finished errands but not released yet. Deliberately in no total:
  /// it is not in the account, and counting it would be a promise.
  final double pendingEarnings;

  factory CreditBalanceEntity.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> wallet(String key) => json[key] is Map
        ? Map<String, dynamic>.from(json[key] as Map)
        : const <String, dynamic>{};

    final deposit = wallet('deposit');
    final earning = wallet('earning');
    return CreditBalanceEntity(
      // Satang on the wire, like every amount this API sends.
      depositBalance: _baht(deposit['balance'] ?? json['balance']),
      depositReserved: _baht(deposit['reserved'] ?? json['reserved']),
      earningBalance: _baht(earning['balance']),
      pendingEarnings: _baht(json['pendingEarnings']),
    );
  }

  static double _baht(dynamic satang) => satang is num ? satang / 100 : 0;

  @override
  List<Object?> get props =>
      [depositBalance, depositReserved, earningBalance, pendingEarnings];
}
