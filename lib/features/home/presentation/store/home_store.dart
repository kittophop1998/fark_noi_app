import 'package:mobx/mobx.dart';

import '../../domain/entities/home_entity.dart';
import '../../domain/usecases/get_home_data_usecase.dart';

part 'home_store.g.dart';

class HomeStore = _HomeStore with _$HomeStore;

abstract class _HomeStore with Store {
  final GetHomeDataUseCase _getHomeData;

  _HomeStore({required GetHomeDataUseCase getHomeData})
      : _getHomeData = getHomeData;

  // ─── Observable State ────────────────────────────────

  @observable
  ObservableList<HomeEntity> items = ObservableList<HomeEntity>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  // ─── Computed ────────────────────────────────────────

  @computed
  bool get hasError => errorMessage != null;

  @computed
  bool get isEmpty => !isLoading && !hasError && items.isEmpty;

  // ─── Actions ─────────────────────────────────────────

  @action
  Future<void> fetchHomeData() async {
    isLoading = true;
    errorMessage = null;

    try {
      final result = await _getHomeData();
      items = ObservableList.of(result);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  void clearError() {
    errorMessage = null;
  }
}
