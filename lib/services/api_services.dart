import 'package:dio/dio.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late Dio _dio;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        // PILIH SALAH SATU sesuai device testing:

        // Untuk emulator Android:
        // baseUrl: 'http://10.0.2.2:5000/api',

        // Untuk emulator iOS atau web:
        baseUrl: 'http://localhost:5000/api',

        // Untuk device fisik (ganti dengan IP komputer kamu):
        // baseUrl: 'http://192.168.X.X:5000/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptor untuk logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('🚀 REQUEST: ${options.method} ${options.path}');
          print('📦 Data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ RESPONSE: ${response.statusCode}');
          print('📥 Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('❌ ERROR: ${error.message}');
          print('📛 Response: ${error.response?.data}');
          return handler.next(error);
        },
      ),
    );
  }

  // Register User
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {'username': username, 'email': email, 'password': password},
      );

      return {
        'success': true,
        'message': response.data['message'],
        'data': response.data['data'],
      };
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Login User
  Future<Map<String, dynamic>> login({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'username': username, 'email': email, 'password': password},
      );

      // Debug print raw response
      print('🔍 DEBUG - Raw API Response: ${response.data}');

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          error: 'Response data is null',
        );
      }

      final responseData = response.data['data'];
      if (responseData == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          error: 'Response data[data] is null',
        );
      }

      // Log response data details
      print('🔍 DEBUG - Response Data Structure: ${responseData.runtimeType}');
      print('🔍 DEBUG - Response Data Keys: ${responseData.keys.toList()}');
      print('🔍 DEBUG - Response Data: $responseData');

      // Specifically check role
      final role = responseData['role'];
      print('🔍 DEBUG - Role Value: $role');
      print('🔍 DEBUG - Role Type: ${role.runtimeType}');
      print('🔍 DEBUG - Role String Comparison: ${role.toString() == 'admin'}');

      return {
        'success': true,
        'message': response.data['message'] ?? 'Login successful',
        'data': {
          ...responseData,
          'role': role?.toString(), // Ensure role is string
        },
      };
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Error Handler
  Map<String, dynamic> _handleError(DioException error) {
    String message = 'Terjadi kesalahan';

    if (error.response != null) {
      message = error.response?.data['message'] ?? message;
    } else if (error.type == DioExceptionType.connectionTimeout) {
      message = 'Koneksi timeout. Cek koneksi internet!';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      message = 'Timeout menerima data dari server!';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'Tidak dapat terhubung ke server. Pastikan backend running!';
    } else {
      message = error.message ?? message;
    }

    return {'success': false, 'message': message};
  }
}
