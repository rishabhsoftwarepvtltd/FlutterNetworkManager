import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rspl_network_manager/src/exceptions/dio_exception_extension.dart';

void main() {
  group('DioExceptionX', () {
    test('isInternetConnectionError_whenConnectionTimeout_shouldReturnTrue',
        () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      expect(exception.isInternetConnectionError, isTrue);
    });

    test('isInternetConnectionError_whenReceiveTimeout_shouldReturnTrue', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.receiveTimeout,
      );

      expect(exception.isInternetConnectionError, isTrue);
    });

    test('isInternetConnectionError_whenOtherTypes_shouldReturnFalse', () {
      final types = [
        DioExceptionType.sendTimeout,
        DioExceptionType.badResponse,
        DioExceptionType.cancel,
        DioExceptionType.badCertificate,
        DioExceptionType.connectionError,
        DioExceptionType.unknown,
      ];

      for (final type in types) {
        final exception = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: type,
        );

        expect(
          exception.isInternetConnectionError,
          isFalse,
          reason: 'Should be false for $type',
        );
      }
    });
  });
}
