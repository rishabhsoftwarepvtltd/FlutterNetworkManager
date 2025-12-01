import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rspl_network_manager/src/interceptors/token_refresh_interceptor.dart';
import 'package:rspl_network_manager/src/token/token_refresher.dart';

class MockDio extends Mock implements Dio {}

class MockTokenRefresher extends Mock implements ITokenRefresher {}

void main() {
  late MockDio mockDio;
  late MockTokenRefresher mockTokenRefresher;

  setUp(() {
    mockDio = MockDio();
    mockTokenRefresher = MockTokenRefresher();
  });

  group('TokenRefreshInterceptorWrapper', () {
    test('constructor_whenRequiredParametersProvided_shouldCreateInstance', () {
      final wrapper = TokenRefreshInterceptorWrapper(
        dio: mockDio,
        tokenRefresher: mockTokenRefresher,
      );

      expect(wrapper.tokenRefresher, equals(mockTokenRefresher));
      expect(wrapper.interceptor, isNotNull);
    });

    test('constructor_whenCustomRetriesProvided_shouldCreateInstance', () {
      final wrapper = TokenRefreshInterceptorWrapper(
        dio: mockDio,
        tokenRefresher: mockTokenRefresher,
        retries: 3,
      );

      expect(wrapper.interceptor, isNotNull);
    });

    test('constructor_whenCustomRetryEvaluatorProvided_shouldUseCustomEvaluator', () {
      Future<bool> customEvaluator(DioException error, int attempt) async {
        return true;
      }

      final wrapper = TokenRefreshInterceptorWrapper(
        dio: mockDio,
        tokenRefresher: mockTokenRefresher,
        retryEvaluator: customEvaluator,
      );

      expect(wrapper.interceptor, isNotNull);
    });

    test('constructor_whenNoRetryEvaluatorProvided_shouldUseDefaultTokenRetryEvaluator', () {
      final wrapper = TokenRefreshInterceptorWrapper(
        dio: mockDio,
        tokenRefresher: mockTokenRefresher,
      );

      expect(wrapper.interceptor, isNotNull);
    });

    test('interceptor_whenAccessed_shouldReturnRetryInterceptor', () {
      final wrapper = TokenRefreshInterceptorWrapper(
        dio: mockDio,
        tokenRefresher: mockTokenRefresher,
      );

      final interceptor = wrapper.interceptor;

      expect(interceptor, isA<Interceptor>());
    });

    test('tokenRefresher_whenSet_shouldStoreCorrectly', () {
      final wrapper = TokenRefreshInterceptorWrapper(
        dio: mockDio,
        tokenRefresher: mockTokenRefresher,
      );

      expect(wrapper.tokenRefresher, same(mockTokenRefresher));
    });

    test('tokenRefresher_whenUpdated_shouldStoreNewValue', () {
      final wrapper = TokenRefreshInterceptorWrapper(
        dio: mockDio,
        tokenRefresher: mockTokenRefresher,
      );

      final newTokenRefresher = MockTokenRefresher();
      wrapper.tokenRefresher = newTokenRefresher;

      expect(wrapper.tokenRefresher, same(newTokenRefresher));
    });
  });
}
