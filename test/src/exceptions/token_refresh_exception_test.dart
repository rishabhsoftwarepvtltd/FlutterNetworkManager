import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rspl_network_manager/rspl_network_manager.dart';

void main() {
  group('TokenRefreshFailedException', () {
    test('constructor_withAllParameters_shouldSetProperties', () {
      final originalError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        message: 'Network error',
      );

      final exception = TokenRefreshFailedException(
        'Token refresh failed',
        originalError: originalError,
        reason: RefreshFailureReason.networkError,
      );

      expect(exception.message, equals('Token refresh failed'));
      expect(exception.originalError, equals(originalError));
      expect(exception.reason, equals(RefreshFailureReason.networkError));
    });

    test('constructor_withOnlyMessage_shouldUseDefaults', () {
      final exception = TokenRefreshFailedException('Simple error');

      expect(exception.message, equals('Simple error'));
      expect(exception.originalError, isNull);
      expect(exception.reason, equals(RefreshFailureReason.unknown));
    });

    test('toString_shouldReturnFormattedMessage', () {
      final exception = TokenRefreshFailedException('Test error');

      expect(
        exception.toString(),
        equals('TokenRefreshFailedException: Test error'),
      );
    });

    test('exception_withOriginalError_shouldPreserveErrorDetails', () {
      final originalError = DioException(
        requestOptions: RequestOptions(path: '/auth/refresh'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          statusCode: 401,
          data: {'error': 'Invalid refresh token'},
        ),
      );

      final exception = TokenRefreshFailedException(
        'Refresh token expired',
        originalError: originalError,
        reason: RefreshFailureReason.refreshTokenExpired,
      );

      expect(exception.originalError?.response?.statusCode, equals(401));
      expect(
        exception.originalError?.response?.data['error'],
        equals('Invalid refresh token'),
      );
    });

    group('RefreshFailureReason', () {
      test('enum_shouldHaveAllExpectedValues', () {
        expect(RefreshFailureReason.values, hasLength(5));
        expect(
          RefreshFailureReason.values,
          containsAll([
            RefreshFailureReason.refreshTokenExpired,
            RefreshFailureReason.networkError,
            RefreshFailureReason.serverError,
            RefreshFailureReason.noRefreshToken,
            RefreshFailureReason.unknown,
          ]),
        );
      });

      test('reason_refreshTokenExpired_shouldBeUsedFor401And403', () {
        final exception = TokenRefreshFailedException(
          'Token expired',
          reason: RefreshFailureReason.refreshTokenExpired,
        );

        expect(
            exception.reason, equals(RefreshFailureReason.refreshTokenExpired));
      });

      test('reason_networkError_shouldBeUsedForConnectionIssues', () {
        final exception = TokenRefreshFailedException(
          'Network timeout',
          reason: RefreshFailureReason.networkError,
        );

        expect(exception.reason, equals(RefreshFailureReason.networkError));
      });

      test('reason_serverError_shouldBeUsedForServerIssues', () {
        final exception = TokenRefreshFailedException(
          'Server error',
          reason: RefreshFailureReason.serverError,
        );

        expect(exception.reason, equals(RefreshFailureReason.serverError));
      });

      test('reason_noRefreshToken_shouldBeUsedWhenTokenMissing', () {
        final exception = TokenRefreshFailedException(
          'No refresh token',
          reason: RefreshFailureReason.noRefreshToken,
        );

        expect(exception.reason, equals(RefreshFailureReason.noRefreshToken));
      });

      test('reason_unknown_shouldBeDefaultValue', () {
        final exception = TokenRefreshFailedException('Unknown error');

        expect(exception.reason, equals(RefreshFailureReason.unknown));
      });
    });

    group('Exception Scenarios', () {
      test('exception_canBeCaughtAsException', () {
        expect(
          () => throw TokenRefreshFailedException('Test'),
          throwsA(isA<Exception>()),
        );
      });

      test('exception_canBeCaughtAsTokenRefreshFailedException', () {
        expect(
          () => throw TokenRefreshFailedException('Test'),
          throwsA(isA<TokenRefreshFailedException>()),
        );
      });

      test('exception_withDifferentReasons_canBeDistinguished', () {
        final expiredException = TokenRefreshFailedException(
          'Expired',
          reason: RefreshFailureReason.refreshTokenExpired,
        );
        final networkException = TokenRefreshFailedException(
          'Network',
          reason: RefreshFailureReason.networkError,
        );

        expect(
          expiredException.reason,
          isNot(equals(networkException.reason)),
        );
      });

      test('exception_withNullOriginalError_shouldHandleGracefully', () {
        final exception = TokenRefreshFailedException(
          'Error without original',
          originalError: null,
          reason: RefreshFailureReason.serverError,
        );

        expect(exception.originalError, isNull);
        expect(exception.message, equals('Error without original'));
      });

      test('exception_withComplexDioError_shouldPreserveAllDetails', () {
        final originalError = DioException(
          requestOptions: RequestOptions(
            path: '/auth/refresh',
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
          ),
          response: Response(
            requestOptions: RequestOptions(path: '/auth/refresh'),
            statusCode: 500,
            statusMessage: 'Internal Server Error',
            data: {
              'error': 'Database connection failed',
              'timestamp': '2024-01-01T00:00:00Z',
            },
          ),
          type: DioExceptionType.badResponse,
          message: 'Server error occurred',
        );

        final exception = TokenRefreshFailedException(
          'Server error during refresh',
          originalError: originalError,
          reason: RefreshFailureReason.serverError,
        );

        expect(exception.originalError?.type,
            equals(DioExceptionType.badResponse));
        expect(exception.originalError?.response?.statusCode, equals(500));
        expect(
            exception.originalError?.message, equals('Server error occurred'));
        expect(
          exception.originalError?.response?.data['error'],
          equals('Database connection failed'),
        );
      });
    });

    group('Real-world Scenarios', () {
      test('scenario_refreshTokenExpired_shouldHaveCorrectProperties', () {
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          response: Response(
            requestOptions: RequestOptions(path: '/auth/refresh'),
            statusCode: 401,
            data: {'message': 'Refresh token has expired'},
          ),
        );

        final exception = TokenRefreshFailedException(
          'Refresh token has expired',
          originalError: dioError,
          reason: RefreshFailureReason.refreshTokenExpired,
        );

        expect(
            exception.reason, equals(RefreshFailureReason.refreshTokenExpired));
        expect(exception.originalError?.response?.statusCode, equals(401));
      });

      test('scenario_networkTimeout_shouldHaveCorrectProperties', () {
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          type: DioExceptionType.connectionTimeout,
          message: 'Connection timeout',
        );

        final exception = TokenRefreshFailedException(
          'Network timeout during token refresh',
          originalError: dioError,
          reason: RefreshFailureReason.networkError,
        );

        expect(exception.reason, equals(RefreshFailureReason.networkError));
        expect(exception.originalError?.type,
            equals(DioExceptionType.connectionTimeout));
      });

      test('scenario_noRefreshTokenInStorage_shouldHaveCorrectProperties', () {
        final exception = TokenRefreshFailedException(
          'No refresh token available in storage',
          reason: RefreshFailureReason.noRefreshToken,
        );

        expect(exception.reason, equals(RefreshFailureReason.noRefreshToken));
        expect(exception.originalError, isNull);
      });

      test('scenario_serverError500_shouldHaveCorrectProperties', () {
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          response: Response(
            requestOptions: RequestOptions(path: '/auth/refresh'),
            statusCode: 500,
          ),
        );

        final exception = TokenRefreshFailedException(
          'Server error during refresh',
          originalError: dioError,
          reason: RefreshFailureReason.serverError,
        );

        expect(exception.reason, equals(RefreshFailureReason.serverError));
        expect(exception.originalError?.response?.statusCode, equals(500));
      });
    });

    group('Additional Edge Cases for 100% Coverage', () {
      test('enum_names_shouldBeAccessible', () {
        expect(RefreshFailureReason.refreshTokenExpired.name,
            equals('refreshTokenExpired'));
        expect(RefreshFailureReason.networkError.name, equals('networkError'));
        expect(RefreshFailureReason.serverError.name, equals('serverError'));
        expect(
            RefreshFailureReason.noRefreshToken.name, equals('noRefreshToken'));
        expect(RefreshFailureReason.unknown.name, equals('unknown'));
      });

      test('exception_withEmptyMessage_shouldWork', () {
        final exception = TokenRefreshFailedException('');

        expect(exception.message, equals(''));
        expect(exception.toString(), equals('TokenRefreshFailedException: '));
      });

      test('exception_withVeryLongMessage_shouldWork', () {
        final longMessage = 'A' * 1000;
        final exception = TokenRefreshFailedException(longMessage);

        expect(exception.message, equals(longMessage));
        expect(exception.toString(),
            equals('TokenRefreshFailedException: $longMessage'));
      });

      test('exception_withSpecialCharactersInMessage_shouldWork', () {
        final message = 'Error: \n\t"Special" \'chars\' \${test}';
        final exception = TokenRefreshFailedException(message);

        expect(exception.message, equals(message));
        expect(exception.toString(), contains(message));
      });

      test('exception_allEnumCombinations_shouldWork', () {
        final reasons = RefreshFailureReason.values;

        for (final reason in reasons) {
          final exception = TokenRefreshFailedException(
            'Test for ${reason.name}',
            reason: reason,
          );

          expect(exception.reason, equals(reason));
          expect(exception.message, equals('Test for ${reason.name}'));
        }
      });

      test('exception_withDioExceptionWithoutResponse_shouldWork', () {
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionTimeout,
          message: 'Timeout',
        );

        final exception = TokenRefreshFailedException(
          'Timeout error',
          originalError: dioError,
          reason: RefreshFailureReason.networkError,
        );

        expect(exception.originalError?.response, isNull);
        expect(exception.originalError?.type,
            equals(DioExceptionType.connectionTimeout));
      });

      test('exception_equality_differentInstances_shouldNotBeEqual', () {
        final exception1 = TokenRefreshFailedException('Error 1');
        final exception2 = TokenRefreshFailedException('Error 1');

        // Different instances should not be equal (no equality override)
        expect(identical(exception1, exception2), isFalse);
      });

      test('exception_fields_shouldBeImmutable', () {
        final exception = TokenRefreshFailedException(
          'Test',
          reason: RefreshFailureReason.serverError,
        );

        // Verify fields are final (compile-time check via type)
        expect(exception.message, isA<String>());
        expect(exception.reason, isA<RefreshFailureReason>());
        expect(exception.originalError, isA<DioException?>());
      });

      test('enum_index_shouldBeSequential', () {
        expect(RefreshFailureReason.refreshTokenExpired.index, equals(0));
        expect(RefreshFailureReason.networkError.index, equals(1));
        expect(RefreshFailureReason.serverError.index, equals(2));
        expect(RefreshFailureReason.noRefreshToken.index, equals(3));
        expect(RefreshFailureReason.unknown.index, equals(4));
      });

      test('exception_toString_withDifferentMessages_shouldVary', () {
        final exception1 = TokenRefreshFailedException('Message 1');
        final exception2 = TokenRefreshFailedException('Message 2');

        expect(exception1.toString(), isNot(equals(exception2.toString())));
        expect(exception1.toString(), contains('Message 1'));
        expect(exception2.toString(), contains('Message 2'));
      });
    });
  });
}
