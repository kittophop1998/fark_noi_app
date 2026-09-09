import 'package:mobx/mobx.dart';

import '../../../../core/session/session_controller.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../data/datasources/profile_datasource.dart';
import '../../domain/entities/reputation_entity.dart';

part 'profile_store.g.dart';

class ProfileStore = _ProfileStore with _$ProfileStore;

/// Who the reader is, and what the platform has to say about them.
///
/// The *identity* is not held here — [SessionController] already owns it, and a
/// second copy would be a second thing to keep in step after an edit. What this
/// adds is the two figures only this screen asks for: the reputation and the
/// wallet.
abstract class _ProfileStore with Store {
  _ProfileStore({
    required ProfileDataSource dataSource,
    required SessionController session,
  })  : _dataSource = dataSource,
        _session = session;

  final ProfileDataSource _dataSource;
  final SessionController _session;

  AuthUser? get user => _session.user;

  @observable
  ReputationEntity? reputation;

  @observable
  CreditBalanceEntity? credits;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @computed
  bool get hasError => errorMessage != null;

  @action
  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    try {
      // Three independent reads, in parallel: the profile screen draws all of
      // them at once, so waiting for them in turn would be three round trips of
      // blank card.
      final results = await Future.wait([
        _dataSource.reputation(),
        _dataSource.credits(),
        _session.refreshUser(),
      ]);
      reputation = results[0] as ReputationEntity;
      credits = results[1] as CreditBalanceEntity;
    } catch (_) {
      errorMessage = 'โหลดข้อมูลโปรไฟล์ไม่สำเร็จ';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> signOut() => _session.signOut();
}
