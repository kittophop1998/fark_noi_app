import 'package:mobx/mobx.dart';

import '../../../../core/errors/exceptions.dart';
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

  /// Loads the feed.
  ///
  /// [askForLocation] is false on a pull-to-refresh: a permission dialog
  /// appearing over a list the user just tugged is the wrong moment to ask,
  /// and the last fix — or the fallback — is what that gesture wanted anyway.
  @action
  Future<void> fetchHomeData({bool askForLocation = true}) async {
    isLoading = true;
    errorMessage = null;

    try {
      final result = await _getHomeData(askForLocation: askForLocation);
      items = ObservableList.of(result);
    } on AppException catch (e) {
      // The server's own sentence, already in Thai. `e.toString()` here used to
      // put "AppException: …" on the screen.
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'โหลดทริปไม่สำเร็จ กรุณาลองใหม่อีกครั้ง';
    } finally {
      isLoading = false;
    }
  }

  @action
  void clearError() {
    errorMessage = null;
  }
}
