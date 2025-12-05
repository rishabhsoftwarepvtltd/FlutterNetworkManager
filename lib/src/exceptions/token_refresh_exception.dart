import 'package:dio/dio.dart';

/// Exception thrown when automatic token refresh fails.
///
/// This exception is thrown by implementations of [ITokenRefresher] when
/// the token refresh operation fails. It allows users to distinguish between
/// regular authentication errors and failed token refresh attempts.
///
/// Example usage:
/// ```dart
/// try {
///   await dio.get('/api/profile');
/// } on TokenRefreshFailedException catch (e) {
///   // Token refresh failed - force logout
///   print('Refresh failed: ${e.message}');
///   navigateToLogin();
/// } on DioException catch (e) {
///   // Handle other network errors
///   print('Request failed: ${e.message}');
/// }
/// ```
class TokenRefreshFailedException implements Exception {
  /// Creates a token refresh exception with a descriptive message.
  ///
  /// [message] describes why the refresh failed.
  /// [originalError] is the optional underlying error that caused the failure.
  /// [reason] categorizes the failure type for easier handling.
  TokenRefreshFailedException(
    this.message, {
    this.originalError,
    this.reason = RefreshFailureReason.unknown,
  });

  /// Human-readable error message describing the failure.
  final String message;

  /// The original error that caused the refresh to fail, if any.
  final DioException? originalError;

  /// Categorized reason for the failure.
  final RefreshFailureReason reason;

  @override
  String toString() => 'TokenRefreshFailedException: $message';
}

/// Categorizes different types of token refresh failures.
enum RefreshFailureReason {
  /// The refresh token has expired or is invalid.
  refreshTokenExpired,

  /// Network error occurred during refresh.
  networkError,

  /// Server returned an error response.
  serverError,

  /// No refresh token available in storage.
  noRefreshToken,

  /// Unknown or unspecified error.
  unknown,
}
