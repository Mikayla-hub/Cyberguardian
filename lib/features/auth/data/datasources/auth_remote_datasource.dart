import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:phishguard_ai/core/constants/api_constants.dart';
import 'package:phishguard_ai/core/network/api_client.dart';
import 'package:phishguard_ai/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
  });
  Future<void> logout();
  Future<UserModel> getCurrentUser();
  Future<bool> refreshToken();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage;

  AuthRemoteDataSourceImpl({
    required ApiClient apiClient,
    required FlutterSecureStorage secureStorage,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage;

  @override
  Future<UserModel> login({required String email, required String password}) async {
    final response = await _apiClient.post(
      '${ApiConstants.authEndpoint}/login',
      data: {'email': email, 'password': password},
    );
    final data = response.data as Map<String, dynamic>;
    await _secureStorage.write(key: 'access_token', value: data['access_token'] as String);
    await _secureStorage.write(key: 'refresh_token', value: data['refresh_token'] as String);
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    final response = await _apiClient.post(
      '${ApiConstants.authEndpoint}/register',
      data: {
        'email': email,
        'password': password,
        'display_name': displayName,
        'role': role,
      },
    );
    final data = response.data as Map<String, dynamic>;
    await _secureStorage.write(key: 'access_token', value: data['access_token'] as String);
    await _secureStorage.write(key: 'refresh_token', value: data['refresh_token'] as String);
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.post('${ApiConstants.authEndpoint}/logout');
    } finally {
      await _secureStorage.deleteAll();
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get(ApiConstants.userProfileEndpoint);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<bool> refreshToken() async {
    final refreshToken = await _secureStorage.read(key: 'refresh_token');
    if (refreshToken == null) return false;
    try {
      final response = await _apiClient.post(
        ApiConstants.refreshTokenEndpoint,
        data: {'refresh_token': refreshToken},
      );
      final data = response.data as Map<String, dynamic>;
      await _secureStorage.write(key: 'access_token', value: data['access_token'] as String);
      await _secureStorage.write(key: 'refresh_token', value: data['refresh_token'] as String);
      return true;
    } catch (_) {
      return false;
    }
  }
}
