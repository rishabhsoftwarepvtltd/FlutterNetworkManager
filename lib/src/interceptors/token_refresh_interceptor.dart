import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import '../token/token_refresher.dart';
import '../token/token_retry_evaluator.dart';

typedef TypeRetryInterceptor = RetryInterceptor;

class TokenRefreshInterceptorWrapper {
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
  ITokenRefresher tokenRefresher;
  late RetryEvaluator _retryEvaluator;
  late final Interceptor _retryInterceptor;

  Interceptor get interceptor {
    return _retryInterceptor;
  }
}
