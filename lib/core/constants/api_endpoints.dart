/// Every path this app calls, written once.
///
/// Paths are relative to [AppConstants.baseUrl] + [AppConstants.apiVersion],
/// which `DioClient` sets as the Dio base URL — so `/trips` here is
/// `https://…/api/v1/trips` on the wire. The names mirror the Go router's
/// groups (`internal/adapters/inbound/http/router.go`) so a route added there
/// has one obvious place to land here.
class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth ──────────────────────────────────────────────────────────────
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const refresh = '/auth/refresh';
  static const signupOtpSend = '/auth/signup/otp/send';
  static const signupOtpVerify = '/auth/signup/otp/verify';

  // ── Me ────────────────────────────────────────────────────────────────
  static const me = '/me';
  static const myTrips = '/me/trips';
  static const myOrders = '/me/orders';
  static const myReputation = '/me/reputation';
  static const myCredits = '/me/credits';
  static const myCreditTransactions = '/me/credits/transactions';
  static const myEarnings = '/me/earnings';
  static const myNotifications = '/me/notifications';
  static const notificationsReadAll = '/me/notifications/read-all';

  static String notification(String id) => '/me/notifications/$id';
  static String notificationRead(String id) => '/me/notifications/$id/read';

  // ── Trips ─────────────────────────────────────────────────────────────
  static const trips = '/trips';
  static const nearbyTrips = '/trips/nearby';

  static String trip(String id) => '/trips/$id';
  static String tripOrders(String id) => '/trips/$id/orders';
  static String tripStart(String id) => '/trips/$id/start';
  static String tripComplete(String id) => '/trips/$id/complete';
  static String tripCancel(String id) => '/trips/$id/cancel';

  // ── Orders ────────────────────────────────────────────────────────────
  static String order(String id) => '/orders/$id';
  static String orderAccept(String id) => '/orders/$id/accept';
  static String orderReject(String id) => '/orders/$id/reject';
  static String orderStartPurchasing(String id) =>
      '/orders/$id/start-purchasing';
  static String orderPurchase(String id) => '/orders/$id/purchase';
  static String orderStartDelivery(String id) => '/orders/$id/start-delivery';
  static String orderDelivered(String id) => '/orders/$id/delivered';
  static String orderComplete(String id) => '/orders/$id/complete';
  static String orderCancel(String id) => '/orders/$id/cancel';
  static String orderReview(String id) => '/orders/$id/review';
  static String orderReviews(String id) => '/orders/$id/reviews';

  // ── Media ─────────────────────────────────────────────────────────────
  static const mediaUploadSessions = '/media/upload-sessions';
  static String mediaComplete(String id) => '/media/$id/complete';
  static String mediaViewUrl(String id) => '/media/$id/view-url';

  // ── Reviews / Reputation ─────────────────────────────────────────────
  static String userReviews(String userId) => '/users/$userId/reviews';
  static String userReputation(String userId) => '/users/$userId/reputation';

  // ── Catalogue ─────────────────────────────────────────────────────────
  static const stores = '/stores';
  static const appSettings = '/app-settings';
  static const homeBanners = '/home-banners/active';

  // ── Trips ─────────────────────────────────────────────────────────────
  static String tripPricing(String id) => '/trips/$id/pricing';
}
