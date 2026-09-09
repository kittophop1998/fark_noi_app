import 'package:mobx/mobx.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/location/location_service.dart';
import '../../../home/domain/entities/home_entity.dart';
import '../../data/datasources/orders_datasource.dart';
import '../../domain/entities/create_order_request.dart';

part 'create_order_store.g.dart';

class CreateOrderStore = _CreateOrderStore with _$CreateOrderStore;

/// Leaving something with a traveller.
///
/// One errand at a time, on one trip — which is why the trip is a field rather
/// than an argument: every figure on the screen is read against it, and a store
/// that could be pointed at a different trip halfway through would be a way to
/// place an order on the wrong one.
abstract class _CreateOrderStore with Store {
  _CreateOrderStore({
    required OrdersDataSource dataSource,
    required LocationService location,
  })  : _dataSource = dataSource,
        _location = location;

  final OrdersDataSource _dataSource;
  final LocationService _location;

  @observable
  bool isSubmitting = false;

  @observable
  bool isSubmitted = false;

  @observable
  String? errorMessage;

  @computed
  bool get hasError => errorMessage != null;

  @action
  void clearError() => errorMessage = null;

  /// Places the request.
  ///
  /// Returns false and leaves [errorMessage] set on any refusal, so the sheet
  /// that called it can say what happened without inventing a sentence: the
  /// server's own catalogue is already written in Thai.
  @action
  Future<bool> submit({
    required HomeEntity trip,
    required String itemName,
    required int quantity,
    required int expectedPrice,
    required String note,
  }) async {
    final latitude = trip.destinationLatitude;
    final longitude = trip.destinationLongitude;
    if (latitude == null || longitude == null) {
      // The feed publishes the destination exactly, so this is a trip the
      // server answered without geometry — rare, and not something to send a
      // half-built order about.
      errorMessage = 'ทริปนี้ยังไม่มีพิกัดร้านปลายทาง ลองรีเฟรชหน้าแรกอีกครั้ง';
      return false;
    }

    isSubmitting = true;
    errorMessage = null;
    try {
      // Where the goods are wanted: the requester's own place, which is where
      // they are standing when they ask.
      final here = await _location.current();
      await _dataSource.createOrder(
        CreateOrderRequest(
          tripId: trip.id,
          storeName: trip.destination,
          storeLatitude: latitude,
          storeLongitude: longitude,
          itemName: itemName,
          quantity: quantity,
          expectedPrice: expectedPrice,
          deliveryLatitude: here.latitude,
          deliveryLongitude: here.longitude,
          deliveryName: trip.dormitory,
          // On a trip whose runner published a rate the server calculates the
          // fee and ignores anything sent here, so nothing is guessed: the
          // published figure is echoed back, and zero stands where the trip
          // lets the requester name their own.
          rewardAmount: trip.feeSatang == null ? 0 : trip.feeSatang! ~/ 100,
          note: note,
        ),
      );
      isSubmitted = true;
      return true;
    } on AppException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (_) {
      errorMessage = 'ส่งคำฝากไม่สำเร็จ กรุณาลองใหม่อีกครั้ง';
      return false;
    } finally {
      isSubmitting = false;
    }
  }
}
