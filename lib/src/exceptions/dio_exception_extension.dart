import 'package:dio/dio.dart';

/// Extension on [DioException] for common error checks.
extension DioExceptionX on DioException {
  /// Returns `true` if the exception is due to an internet connection error.
  ///
  /// This includes connection timeouts and receive timeouts, which typically
  /// indicate network connectivity issues.
  bool get isInternetConnectionError {
    return type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout;
  }
}
