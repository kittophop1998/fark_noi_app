import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/reputation_entity.dart';

abstract class ProfileDataSource {
  Future<ReputationEntity> reputation();
  Future<CreditBalanceEntity> credits();
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
}
