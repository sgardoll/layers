import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'result.dart';

part 'api_client.g.dart';

@riverpod
ApiClient apiClient(Ref ref) {
  return ApiClient();
}

class ApiClient {
  late final Dio _dio;

  ApiClient({String? baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? '',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) fromJson,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      return Result.success(fromJson(response.data));
    } on DioException catch (e) {
      return Result.failure(_extractErrorMessage(e), e);
    } catch (e) {
      return Result.failure('Unexpected error', e);
    }
  }

  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    required T Function(dynamic json) fromJson,
  }) async {
    try {
      final response = await _dio.post<dynamic>(path, data: data);
      return Result.success(fromJson(response.data));
    } on DioException catch (e) {
      return Result.failure(_extractErrorMessage(e), e);
    } catch (e) {
      return Result.failure('Unexpected error', e);
    }
  }

  Future<Result<String>> uploadFile(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? extraFields,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?extraFields,
      });
      final response = await _dio.post<dynamic>(path, data: formData);
      return Result.success(response.data.toString());
    } on DioException catch (e) {
      return Result.failure(_extractErrorMessage(e), e);
    } catch (e) {
      return Result.failure('Unexpected error', e);
    }
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data case {'message': final String message}) {
      return message;
    }
    return e.message ?? 'Network error';
  }
}
