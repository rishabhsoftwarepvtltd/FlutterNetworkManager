import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rspl_network_manager/rspl_network_manager.dart';

class MockTokenRefresher extends Mock implements ITokenRefresher {}

void main() {
  late MockTokenRefresher mockTokenRefresher;

  setUp(() {
    mockTokenRefresher = MockTokenRefresher();
  });

  group('TokenRetryEvaluator', () {
    test('evaluate_whenStatusCodeMatchesAndRefreshSucceeds_shouldReturnTrue', () async {
      final evaluator = TokenRetryEvaluator(
        tokenRefresher: mockTokenRefresher,
        retryCodes: [401, 403],
      );

      when(() => mockTokenRefresher.refreshToken()).thenAnswer((_) async => true);

      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
      );

      final result = await evaluator.evaluate(exception, 1);

      expect(result, isTrue);
      verify(() => mockTokenRefresher.refreshToken()).called(1);
    });

    test('evaluate_whenStatusCodeMatchesButRefreshFails_shouldReturnFalse', () async {
      final evaluator = TokenRetryEvaluator(
        tokenRefresher: mockTokenRefresher,
        retryCodes: [401],
      );

      when(() => mockTokenRefresher.refreshToken()).thenAnswer((_) async => false);

      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
      );

      final result = await evaluator.evaluate(exception, 1);

      expect(result, isFalse);
    });

    test('evaluate_whenStatusCodeDoesNotMatch_shouldReturnFalse', () async {
      final evaluator = TokenRetryEvaluator(
        tokenRefresher: mockTokenRefresher,
        retryCodes: [401],
      );

      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 404,
        ),
      );

      final result = await evaluator.evaluate(exception, 1);

      expect(result, isFalse);
      verifyNever(() => mockTokenRefresher.refreshToken());
    });

    test('evaluate_whenExceptionalUri_shouldReturnFalse', () async {
      final evaluator = TokenRetryEvaluator(
        tokenRefresher: mockTokenRefresher,
        retryCodes: [401],
        exceptionalUris: ['/auth/login', '/auth/register'],
      );

      final exception = DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 401,
        ),
      );

      final result = await evaluator.evaluate(exception, 1);

      expect(result, isFalse);
      verifyNever(() => mockTokenRefresher.refreshToken());
    });

    test('evaluate_whenNonBadResponseError_shouldReturnTrue', () async {
      final evaluator = TokenRetryEvaluator(
        tokenRefresher: mockTokenRefresher,
      );

      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      final result = await evaluator.evaluate(exception, 1);

      expect(result, isTrue);
    });

    test('evaluate_whenCancelError_shouldReturnFalse', () async {
      final evaluator = TokenRetryEvaluator(
        tokenRefresher: mockTokenRefresher,
      );

      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.cancel,
      );

      final result = await evaluator.evaluate(exception, 1);

      expect(result, isFalse);
    });

    test('evaluate_whenFormatException_shouldReturnFalse', () async {
      final evaluator = TokenRetryEvaluator(
        tokenRefresher: mockTokenRefresher,
      );

      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
        error: const FormatException('Invalid format'),
      );

      final result = await evaluator.evaluate(exception, 1);

      expect(result, isFalse);
    });

    test('evaluate_whenNullStatusCode_shouldReturnTrue', () async {
      final evaluator = TokenRetryEvaluator(
        tokenRefresher: mockTokenRefresher,
        retryCodes: [401],
      );

      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: null,
        ),
      );

      final result = await evaluator.evaluate(exception, 1);

      expect(result, isTrue);
    });

    test('currentAttempt_whenEvaluated_shouldTrackAttemptNumber', () async {
      final evaluator = TokenRetryEvaluator(
        tokenRefresher: mockTokenRefresher,
      );

      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      await evaluator.evaluate(exception, 3);

      expect(evaluator.currentAttempt, equals(3));
    });

    test('evaluate_whenWildcardExceptionalUri_shouldReturnFalse', () async {
      final evaluator = TokenRetryEvaluator(
        tokenRefresher: mockTokenRefresher,
        retryCodes: [401],
        exceptionalUris: ['/auth/*'],
      );

      when(() => mockTokenRefresher.refreshToken()).thenAnswer((_) async => false);

      final exception = DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 401,
        ),
      );

      final result = await evaluator.evaluate(exception, 1);

      expect(result, isFalse);
    });

    test('evaluate_whenRefresherThrowsException_shouldPropagateException', () async {
      final evaluator = TokenRetryEvaluator(
        tokenRefresher: mockTokenRefresher,
        retryCodes: [401],
      );

      // Mock the refresher to throw an exception
      when(() => mockTokenRefresher.refreshToken()).thenThrow(
        Exception('Token refresh failed'),
      );

      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
      );

      // Verify that the exception is propagated
      expect(
        () => evaluator.evaluate(exception, 1),
        throwsA(isA<Exception>()),
      );
    });

    test('evaluate_whenRefresherThrowsTokenRefreshFailedException_shouldPropagate', () async {
      final evaluator = TokenRetryEvaluator(
        tokenRefresher: mockTokenRefresher,
        retryCodes: [401],
      );

      final refreshException = TokenRefreshFailedException(
        'Refresh token expired',
        reason: RefreshFailureReason.refreshTokenExpired,
      );

      when(() => mockTokenRefresher.refreshToken()).thenThrow(refreshException);

      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
      );

      expect(
        () => evaluator.evaluate(exception, 1),
        throwsA(isA<TokenRefreshFailedException>()),
      );
    });

    test('evaluate_whenRefresherThrowsDioException_shouldPropagate', () async {
      final evaluator = TokenRetryEvaluator(
        tokenRefresher: mockTokenRefresher,
        retryCodes: [401],
      );

      final dioException = DioException(
        requestOptions: RequestOptions(path: '/auth/refresh'),
        message: 'Network error',
      );

      when(() => mockTokenRefresher.refreshToken()).thenThrow(dioException);

      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
      );

      expect(
        () => evaluator.evaluate(exception, 1),
        throwsA(isA<DioException>()),
      );
    });

    test('evaluate_whenRefresherThrowsAndNotRetryCode_shouldNotCallRefresher', () async {
      final evaluator = TokenRetryEvaluator(
        tokenRefresher: mockTokenRefresher,
        retryCodes: [401],
      );

      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 404,
        ),
      );

      final result = await evaluator.evaluate(exception, 1);

      expect(result, isFalse);
      verifyNever(() => mockTokenRefresher.refreshToken());
    });

    test('evaluate_whenRefresherThrowsOnExceptionalUri_shouldNotCallRefresher', () async {
      final evaluator = TokenRetryEvaluator(
        tokenRefresher: mockTokenRefresher,
        retryCodes: [401],
        exceptionalUris: ['/auth/login'],
      );

      when(() => mockTokenRefresher.refreshToken()).thenThrow(
        Exception('Should not be called'),
      );

      final exception = DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 401,
        ),
      );

      final result = await evaluator.evaluate(exception, 1);

      expect(result, isFalse);
      verifyNever(() => mockTokenRefresher.refreshToken());
    });

    test('evaluate_whenRefresherThrowsMultipleTimes_shouldPropagateEachTime', () async {
      final evaluator = TokenRetryEvaluator(
        tokenRefresher: mockTokenRefresher,
        retryCodes: [401],
      );

      when(() => mockTokenRefresher.refreshToken()).thenThrow(
        Exception('Persistent error'),
      );

      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
      );

      // First attempt
      expect(
        () => evaluator.evaluate(exception, 1),
        throwsA(isA<Exception>()),
      );

      // Second attempt
      expect(
        () => evaluator.evaluate(exception, 2),
        throwsA(isA<Exception>()),
      );

      verify(() => mockTokenRefresher.refreshToken()).called(2);
    });

    test('evaluate_whenRefresherSucceedsAfterPreviousException_shouldReturnTrue', () async {
      final evaluator = TokenRetryEvaluator(
        tokenRefresher: mockTokenRefresher,
        retryCodes: [401],
      );

      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
      );

      // First call throws
      when(() => mockTokenRefresher.refreshToken()).thenThrow(Exception('First attempt failed'));

      // First attempt should throw
      expect(
        () => evaluator.evaluate(exception, 1),
        throwsA(isA<Exception>()),
      );

      // Second call succeeds
      when(() => mockTokenRefresher.refreshToken()).thenAnswer((_) async => true);

      // Second attempt should succeed
      final result = await evaluator.evaluate(exception, 2);
      expect(result, isTrue);
    });
  });
}
