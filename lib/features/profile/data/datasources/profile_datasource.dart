import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/reputation_entity.dart';

abstract class ProfileDataSource {
  Future<ReputationEntity> reputation();
  Future<CreditBalanceEntity> credits();

  /// `GET /users/{userId}/reviews` — what has been said about somebody,
  /// newest first. Called with the caller's own id for "รีวิวที่ได้รับ".
  Future<UserReviewsEntity> userReviews(String userId);

  /// `PATCH /me`. Every field is left out of the body when null, so a caller
  /// changing only the PromptPay id does not also overwrite the name with
  /// itself — the server's own partial-update semantics, mirrored here.
  Future<void> updateProfile({
    String? displayName,
    String? promptPayId,
    String? avatarMediaId,
    bool? removeAvatar,
  });
}

class ProfileRemoteDataSource implements ProfileDataSource {
  const ProfileRemoteDataSource({required this.client});

  final DioClient client;

  @override
  Future<ReputationEntity> reputation() async {
    final response = await client.get(ApiEndpoints.myReputation);
    return ReputationEntity.fromJson(DioClient.unwrap(response));
  }

  @override
  Future<CreditBalanceEntity> credits() async {
    final response = await client.get(ApiEndpoints.myCredits);
    return CreditBalanceEntity.fromJson(DioClient.unwrap(response));
  }

  @override
  Future<UserReviewsEntity> userReviews(String userId) async {
    final response = await client.get(ApiEndpoints.userReviews(userId));
    return UserReviewsEntity.fromJson(DioClient.unwrap(response));
  }

  @override
  Future<void> updateProfile({
    String? displayName,
    String? promptPayId,
    String? avatarMediaId,
    bool? removeAvatar,
  }) async {
    await client.patch(
      ApiEndpoints.me,
      data: {
        if (displayName != null) 'displayName': displayName,
        if (promptPayId != null) 'promptPayId': promptPayId,
        if (avatarMediaId != null) 'avatarMediaId': avatarMediaId,
        if (removeAvatar != null) 'removeAvatar': removeAvatar,
      },
    );
  }
}
