import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:incident_report_app/core/constants/constants.dart';
import 'package:incident_report_app/core/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService extends GetxService {
  final _storageService = Get.find<StorageService>();
  late final dio.Dio _dio;
  final String baseUrl = 'http://192.168.188.205:8000/api'; // Adresse IP WiFi de votre ordinateur avec /api
  
  Future<ApiService> init() async {
    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(dio.InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storageService.readSecure(AppConstants.TOKEN_KEY);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _storageService.removeSecure(AppConstants.TOKEN_KEY);
          await _storageService.removeSecure(AppConstants.USER_KEY);
          Get.offAllNamed(Routes.LOGIN);
        }
        return handler.next(error);
      },
    ));

    return this;
  }

  Future<dio.Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dio.Response> post(String path, dynamic data) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final headers = {
    'Authorization': token != null ? 'Bearer $token' : '',
  };

  final options = dio.Options(headers: headers);

  return await _dio.post(
    path,
    data: data,
    options: options,
  );
}


  Future<dio.Response> put(String path, dynamic data) async {
    try {
      return await _dio.put(path, data: data);
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dio.Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dio.Response> uploadFile(String path, File file) async {
    try {
      final formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(file.path),
      });
      return await _dio.post(path, data: formData);
    } on dio.DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> uploadFiles({
    required List<String> imagePaths,
    required String audioPath,
    required String incidentId,
    String? description,
  }) async {
    try {
      final formData = dio.FormData();

      // Ajouter les images
      for (var i = 0; i < imagePaths.length; i++) {
        final file = await dio.MultipartFile.fromFile(
          imagePaths[i],
          filename: 'image_$i.jpg',
        );
        formData.files.add(MapEntry('images', file));
      }

      // Ajouter l'audio
      if (audioPath.isNotEmpty) {
        final audioFile = await dio.MultipartFile.fromFile(
          audioPath,
          filename: 'audio.mp3',
        );
        formData.files.add(MapEntry('audio', audioFile));
      }

      // Ajouter l'ID de l'incident
      formData.fields.add(MapEntry('incident_id', incidentId));

      // Ajouter la description si elle est fournie
      if (description != null) {
        formData.fields.add(MapEntry('description', description));
      }

      final response = await _dio.post(
        '/incidents/upload-files',
        data: formData,
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer ${await _storageService.getToken()}',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to upload files');
      }
    } catch (e) {
      throw Exception('Error uploading files: $e');
    }
  }

  Exception _handleError(dio.DioException error) {
    if (error.type == dio.DioExceptionType.connectionTimeout ||
        error.type == dio.DioExceptionType.receiveTimeout) {
      return Exception('Connection timeout. Please check your internet connection.');
    }
    return Exception(error.message ?? 'An error occurred');
  }
} 