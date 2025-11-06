import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CityService {
  static final CityService _instance = CityService._internal();
  late Dio _dio;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  factory CityService() {
    return _instance;
  }

  CityService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:5000/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  // Ambil semua data kota
  Future<Map<String, dynamic>> getCities() async {
    try {
      final response = await _dio.get('/cities');
      return {
        'success': true,
        'data': response.data['data'],
        'message': response.data['message'],
      };
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Tambah kota baru
  Future<Map<String, dynamic>> addCity({
    required String name,
    required String description,
    String? imageUrl,
  }) async {
    try {
      final response = await _dio.post(
        '/cities',
        data: {
          'name': name,
          'description': description,
          if (imageUrl != null) 'imageUrl': imageUrl,
        },
      );
      return {
        'success': true,
        'data': response.data['data'],
        'message': response.data['message'],
      };
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Update kota
  Future<Map<String, dynamic>> updateCity({
    required String id,
    required String name,
    required String description,
    String? imageUrl,
  }) async {
    try {
      final response = await _dio.put(
        '/cities/$id',
        data: {
          'name': name,
          'description': description,
          if (imageUrl != null) 'imageUrl': imageUrl,
        },
      );
      return {
        'success': true,
        'data': response.data['data'],
        'message': response.data['message'],
      };
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Hapus kota
  Future<Map<String, dynamic>> deleteCity(String id) async {
    try {
      final token = await _getToken();
      final response = await _dio.delete(
        '/cities/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      print('Response dari server: ${response.data}');
      return {'success': true, 'message': response.data['message']};
    } on DioException catch (e) {
      print('Error saat menghapus: ${e.message}');
      print('Response error: ${e.response?.data}');
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
    }

    return {'success': false, 'message': message};
  }
}
