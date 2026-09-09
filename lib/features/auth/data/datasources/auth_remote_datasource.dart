import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  });

  Future<void> sendSignupOtp(String email);

  Future<String> verifySignupOtp({
    required String email,
    required String code,
  });

  Future<AuthSessionModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String otpToken,
  });

  Future<AuthUserModel> me();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({required this.client});

  final DioClient client;

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    final response = await client.post(
      ApiEndpoints.login,
      data: {'email': email.trim(), 'password': password},
    );
    return AuthSessionModel.fromJson(DioClient.unwrap(response));
  }

  @override
  Future<void> sendSignupOtp(String email) async {
    await client.post(
      ApiEndpoints.signupOtpSend,
      data: {'email': email.trim()},
    );
  }

  @override
  Future<String> verifySignupOtp({
    required String email,
    required String code,
  }) async {
    final response = await client.post(
      ApiEndpoints.signupOtpVerify,
      data: {'email': email.trim(), 'code': code.trim()},
    );
    return DioClient.unwrap(response)['otpToken'] as String? ?? '';
  }

  @override
  Future<AuthSessionModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String otpToken,
  }) async {
    final response = await client.post(
      ApiEndpoints.register,
      data: {
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'password': password,
        'otpToken': otpToken,
        'locale': 'th-TH',
      },
    );
    return AuthSessionModel.fromJson(DioClient.unwrap(response));
  }

  @override
  Future<AuthUserModel> me() async {
    final response = await client.get(ApiEndpoints.me);
    return AuthUserModel.fromJson(DioClient.unwrap(response));
  }
}
