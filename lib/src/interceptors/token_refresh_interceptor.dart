import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import '../token/token_refresher.dart';
import '../token/token_retry_evaluator.dart';

/// Type alias for [RetryInterceptor] from dio_smart_retry package.
typedef TypeRetryInterceptor = RetryInterceptor;

/// Wrapper for automatic token refresh and request retry mechanism.
///
/// This interceptor automatically detects authentication failures (401/403),
/// attempts to refresh the access token using [ITokenRefresher], and retries
/// the original request with the new token.
///
/// **How it works:**
/// 1. Request fails with 401/403 status code
/// 2. Interceptor calls [ITokenRefresher.refreshToken()]
/// 3. If refresh succeeds, original request is retried with new token
/// 4. If refresh fails, exception propagates to caller
///
/// **Exception Handling:**
/// - If [ITokenRefresher.refreshToken()] throws [TokenRefreshFailedException],
///   it propagates to the caller for handling
/// - Users can catch this exception to perform actions like forcing logout
///
/// Example:
/// ```dart
/// final refreshInterceptor = TokenRefreshInterceptorWrapper(
///   dio: dio,
///   tokenRefresher: myTokenRefresher,
///   retries: 1,
/// );
/// dio.interceptors.add(refreshInterceptor.interceptor);
/// ```
class TokenRefreshInterceptorWrapper {
  /// Creates a [TokenRefreshInterceptorWrapper] instance.
  ///
  /// [dio] is the Dio instance to use for retry logic.
  /// [tokenRefresher] handles the token refresh logic.
  /// [retries] specifies how many times to retry after token refresh (default: 1).
  /// [retryEvaluator] is an optional custom evaluator for retry logic.
  TokenRefreshInterceptorWrapper({
    required Dio dio,
    required this.tokenRefresher,
    int retries = 1,
    RetryEvaluator? retryEvaluator,
  }) {
    _retryEvaluator = retryEvaluator ??
        TokenRetryEvaluator(tokenRefresher: tokenRefresher).evaluate;
    _retryInterceptor = RetryInterceptor(
      dio: dio,
      retries: retries,
      retryEvaluator: _retryEvaluator,
    );
  }

  /// The token refresher implementation.
  ITokenRefresher tokenRefresher;

  late RetryEvaluator _retryEvaluator;
  late final Interceptor _retryInterceptor;

  /// Gets the underlying retry interceptor to add to Dio.
  Interceptor get interceptor {
    return _retryInterceptor;
  }
}
