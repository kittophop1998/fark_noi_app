import '../entities/home_entity.dart';
import '../repositories/home_repository.dart';

class GetHomeDataUseCase {
  final HomeRepository repository;

  GetHomeDataUseCase(this.repository);

  Future<List<HomeEntity>> call() async {
    return await repository.getHomeData();
  }
}
