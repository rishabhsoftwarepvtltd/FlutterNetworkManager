import 'package:dio/dio.dart';

extension DioExceptionX on DioException {
  bool get isInternetConnectionError {
    return type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout;
  }
}
