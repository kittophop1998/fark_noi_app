import 'dart:async';

import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import '../local_storage/token_storage.dart';

/// The one way this app talks to FarkNoiGo.
///
/// Three jobs, and they are here rather than in each datasource because getting
/// any of them slightly different per feature is how a client starts answering
/// the same failure two ways:
///
///  * **the bearer token** — attached to every request from [TokenStorage],
///  * **renewal** — one 401 anywhere refreshes the pair once and replays the
///    request; a second failure ends the session exactly once,
///  * **the envelope** — every response is `{success, message, data}` and every
///    failure `{success:false, code, message:{th,en}}`, so [unwrap] hands a
///    datasource the `data` it actually wanted and [AppException.code] carries
///    the name a screen may branch on.
class DioClient {
  DioClient({
    required TokenStorage tokenStorage,
    this.onSessionExpired,
  }) : _tokens = tokenStorage {
    final options = BaseOptions(
      baseUrl: AppConstants.baseUrl + AppConstants.apiVersion,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      // Statuses are read by the error interceptor below, which needs the
      // envelope of a 4xx as much as of a 200.
      validateStatus: (status) => status != null && status < 400,
    );

    _dio = Dio(options);
    // A bare client for the renewal call itself. Sharing `_dio` would send an
    // expired bearer with the refresh and put its own 401 back through the
    // interceptor that raised it.
    _refreshDio = Dio(options);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          final token = _tokens.accessToken;
          if (token != null && token.isNotEmpty) {
            request.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(request);
        },
        onError: (error, handler) async {
          final retried = await _retryAfterRefresh(error);
          if (retried != null) {
            handler.resolve(retried);
            return;
          }
          handler.next(error);
        },
      ),
    );
  }

  late final Dio _dio;
  late final Dio _refreshDio;
  final TokenStorage _tokens;

  /// Called once when a session cannot be renewed, so the app can send the user
  /// back to the sign-in screen. Set by the DI container.
  final Future<void> Function()? onSessionExpired;

  /// The renewal in flight, so twenty requests failing at once refresh once.
  Future<bool>? _refreshing;

  Dio get dio => _dio;

  // ── Verbs ───────────────────────────────────────────────────────────────

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _send(() => _dio.get<dynamic>(
            path,
            queryParameters: queryParameters,
            options: options,
          ));

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _send(() => _dio.post<dynamic>(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
          ));

  Future<Response<dynamic>> patch(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _send(() => _dio.patch<dynamic>(path, data: data, options: options));

  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _send(() => _dio.put<dynamic>(path, data: data, options: options));

  Future<Response<dynamic>> delete(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _send(() => _dio.delete<dynamic>(path, data: data, options: options));

  /// One `PUT` of raw bytes to a presigned object-storage URL.
  ///
  /// A bare Dio and not [_dio]: the URL is absolute, points off this app's own
  /// host, and must carry none of this client's bearer token or base path —
  /// only the signed headers the upload session handed back.
  Future<void> uploadBytes(
    String url, {
    required List<int> bytes,
    required Map<String, String> headers,
  }) async {
    try {
      await Dio().put<dynamic>(
        url,
        data: Stream.fromIterable([bytes]),
        options: Options(
          headers: {...headers, Headers.contentLengthHeader: bytes.length},
        ),
      );
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  // ── Envelope ────────────────────────────────────────────────────────────

  /// The `data` of a successful envelope, as a map.
  ///
  /// An endpoint that answers with no body — the transitions do — gives an
  /// empty map rather than throwing, because "it worked and said nothing" is a
  /// success and not a parse failure.
  static Map<String, dynamic> unwrap(Response<dynamic> response) {
    final body = response.data;
    if (body is! Map) return const {};
    final data = body['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    return const {};
  }

  /// The `data` of a successful envelope, as a list — for the handful of
  /// endpoints that answer with a bare array rather than an `items` page.
  static List<dynamic> unwrapList(Response<dynamic> response) {
    final body = response.data;
    if (body is! Map) return const [];
    final data = body['data'];
    if (data is List) return data;
    if (data is Map && data['items'] is List) return data['items'] as List;
    return const [];
  }

  // ── Plumbing ────────────────────────────────────────────────────────────

  Future<Response<dynamic>> _send(
    Future<Response<dynamic>> Function() call,
  ) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  /// One renewal, then a replay of the request that provoked it.
  ///
  /// Returns null — meaning "this error stands" — for anything that is not a
  /// renewable 401: a failed sign-in, a refused refresh, a request that has
  /// already been replayed once.
  Future<Response<dynamic>?> _retryAfterRefresh(DioException error) async {
    final path = error.requestOptions.path;
    final isAuthCall = path.startsWith('/auth/');
    final alreadyRetried = error.requestOptions.extra['__retried'] == true;

    if (error.response?.statusCode != 401 ||
        isAuthCall ||
        alreadyRetried ||
        !_tokens.hasSession) {
      return null;
    }

    final renewed = await (_refreshing ??= _refresh().whenComplete(() {
      _refreshing = null;
    }));
    if (!renewed) return null;

    final options = error.requestOptions;
    options.extra = {...options.extra, '__retried': true};
    options.headers['Authorization'] = 'Bearer ${_tokens.accessToken}';
    try {
      return await _dio.fetch<dynamic>(options);
    } on DioException {
      return null;
    }
  }

  Future<bool> _refresh() async {
    final refreshToken = _tokens.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return false;
    try {
      final response = await _refreshDio.post<dynamic>(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );
      final data = unwrap(response);
      final access = data['accessToken'] as String?;
      final refresh = data['refreshToken'] as String?;
      if (access == null || refresh == null) {
        await _endSession();
        return false;
      }
      await _tokens.save(accessToken: access, refreshToken: refresh);
      return true;
    } on DioException {
      await _endSession();
      return false;
    }
  }

  Future<void> _endSession() async {
    await _tokens.clear();
    await onSessionExpired?.call();
  }

  /// A Dio failure said in the app's own vocabulary.
  ///
  /// The sentence comes from the server's catalogue where there is one — it is
  /// already written in Thai and already agrees with what the web app shows for
  /// the same failure — and from here only when the request never arrived.
  AppException _toException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const TimeoutException();
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return const NetworkException();
      case DioExceptionType.cancel:
        return const NetworkException('คำขอถูกยกเลิก');
      case DioExceptionType.badCertificate:
        return const NetworkException('การเชื่อมต่อไม่ปลอดภัย');
      case DioExceptionType.badResponse:
        break;
    }

    final status = e.response?.statusCode;
    final body = e.response?.data;
    final envelope = body is Map ? body : const {};
    final code = envelope['code'] as String?;
    final details = envelope['details'] is Map
        ? Map<String, dynamic>.from(envelope['details'] as Map)
        : null;
    final message = _message(envelope['message']) ?? 'เกิดข้อผิดพลาด';

    if (status == 401) return UnauthorizedException(message, code);
    return ServerException(
      message,
      statusCode: status,
      code: code,
      details: details,
    );
  }

  /// A failure's message is `{th, en}`; a success's is a plain string. Both
  /// shapes reach here because a 4xx envelope and a 2xx one share a key.
  static String? _message(dynamic message) {
    if (message is String && message.isNotEmpty) return message;
    if (message is Map) {
      final th = message['th'];
      if (th is String && th.isNotEmpty) return th;
      final en = message['en'];
      if (en is String && en.isNotEmpty) return en;
    }
    return null;
  }
}
