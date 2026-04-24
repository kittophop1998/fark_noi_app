import '../../../../core/network/dio_client.dart';
import '../models/home_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<HomeModel>> getHomeData();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioClient dioClient;

  HomeRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<HomeModel>> getHomeData() async {
    final response = await dioClient.get('/home');
    final List<dynamic> data = response.data['data'] as List<dynamic>;
    return data
        .map((item) => HomeModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
