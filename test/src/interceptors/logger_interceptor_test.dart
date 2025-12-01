import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rspl_network_manager/src/interceptors/logger_interceptor.dart';

class MockRequestInterceptorHandler extends Mock implements RequestInterceptorHandler {}

class MockResponseInterceptorHandler extends Mock implements ResponseInterceptorHandler {}

class MockErrorInterceptorHandler extends Mock implements ErrorInterceptorHandler {}

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/test'));
    registerFallbackValue(
      Response(requestOptions: RequestOptions(path: '/test')),
    );
    registerFallbackValue(
      DioException(requestOptions: RequestOptions(path: '/test')),
    );
  });

  group('WSLoggerInterceptor', () {
    test('constructor_whenDefaultValues_shouldSetDefaults', () {
      final interceptor = WSLoggerInterceptor();

      expect(interceptor.enableConsoleLog, isTrue);
      expect(interceptor.request, isTrue);
      expect(interceptor.requestHeader, isFalse);
      expect(interceptor.requestBody, isFalse);
      expect(interceptor.responseHeader, isFalse);
      expect(interceptor.responseBody, isTrue);
      expect(interceptor.error, isTrue);
      expect(interceptor.maxWidth, equals(90));
      expect(interceptor.compact, isTrue);
    });

    test('constructor_whenCustomValues_shouldSetCustomValues', () {
      final interceptor = WSLoggerInterceptor(
        enableConsoleLog: false,
        request: false,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: false,
        error: false,
        maxWidth: 120,
        compact: false,
      );

      expect(interceptor.enableConsoleLog, isFalse);
      expect(interceptor.request, isFalse);
      expect(interceptor.requestHeader, isTrue);
      expect(interceptor.requestBody, isTrue);
      expect(interceptor.responseHeader, isTrue);
      expect(interceptor.responseBody, isFalse);
      expect(interceptor.error, isFalse);
      expect(interceptor.maxWidth, equals(120));
      expect(interceptor.compact, isFalse);
    });

    test('onRequest_whenRequestLoggingEnabled_shouldLogRequest', () async {
      final interceptor = WSLoggerInterceptor(
        request: true,
        enableConsoleLog: false,
      );
      final handler = MockRequestInterceptorHandler();
      final options = RequestOptions(path: '/test', method: 'GET');

      final logs = <String>[];
      interceptor.newLogStream.listen(logs.add);

      when(() => handler.next(any())).thenAnswer((_) {});

      interceptor.onRequest(options, handler);

      await Future.delayed(const Duration(milliseconds: 100));

      expect(logs.isNotEmpty, isTrue);
      expect(logs.any((log) => log.contains('Request')), isTrue);
      verify(() => handler.next(options)).called(1);
    });

    test('onRequest_whenRequestHeadersEnabled_shouldLogHeaders', () async {
      final interceptor = WSLoggerInterceptor(
        request: true,
        requestHeader: true,
        enableConsoleLog: false,
      );
      final handler = MockRequestInterceptorHandler();
      final options = RequestOptions(
        path: '/test',
        method: 'GET',
        headers: {'Authorization': 'Bearer token'},
      );

      final logs = <String>[];
      interceptor.newLogStream.listen(logs.add);

      when(() => handler.next(any())).thenAnswer((_) {});

      interceptor.onRequest(options, handler);

      await Future.delayed(const Duration(milliseconds: 100));

      expect(logs.any((log) => log.contains('Headers')), isTrue);
    });

    test('onRequest_whenRequestBodyEnabledForPOST_shouldLogBody', () async {
      final interceptor = WSLoggerInterceptor(
        request: true,
        requestBody: true,
        enableConsoleLog: false,
      );
      final handler = MockRequestInterceptorHandler();
      final options = RequestOptions(
        path: '/test',
        method: 'POST',
        data: {'key': 'value'},
      );

      final logs = <String>[];
      interceptor.newLogStream.listen(logs.add);

      when(() => handler.next(any())).thenAnswer((_) {});

      interceptor.onRequest(options, handler);

      await Future.delayed(const Duration(milliseconds: 100));

      expect(logs.any((log) => log.contains('Body')), isTrue);
    });

    test('onResponse_whenResponseLoggingEnabled_shouldLogResponse', () async {
      final interceptor = WSLoggerInterceptor(
        responseBody: true,
        enableConsoleLog: false,
      );
      final handler = MockResponseInterceptorHandler();
      final response = Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 200,
        data: {'result': 'success'},
      );

      final logs = <String>[];
      interceptor.newLogStream.listen(logs.add);

      when(() => handler.next(any())).thenAnswer((_) {});

      interceptor.onResponse(response, handler);

      await Future.delayed(const Duration(milliseconds: 100));

      expect(logs.any((log) => log.contains('Response')), isTrue);
      expect(logs.any((log) => log.contains('200')), isTrue);
      verify(() => handler.next(response)).called(1);
    });

    test('onResponse_whenResponseHeadersEnabled_shouldLogHeaders', () async {
      final interceptor = WSLoggerInterceptor(
        responseHeader: true,
        enableConsoleLog: false,
      );
      final handler = MockResponseInterceptorHandler();
      final response = Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 200,
        headers: Headers.fromMap({
          'content-type': ['application/json'],
        }),
      );

      final logs = <String>[];
      interceptor.newLogStream.listen(logs.add);

      when(() => handler.next(any())).thenAnswer((_) {});

      interceptor.onResponse(response, handler);

      await Future.delayed(const Duration(milliseconds: 100));

      expect(logs.any((log) => log.contains('Headers')), isTrue);
    });

    test('onError_whenErrorLoggingEnabled_shouldLogError', () async {
      final interceptor = WSLoggerInterceptor(
        error: true,
        enableConsoleLog: false,
      );
      final handler = MockErrorInterceptorHandler();
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
        message: 'Connection timeout',
      );

      final logs = <String>[];
      interceptor.newLogStream.listen(logs.add);

      when(() => handler.next(any())).thenAnswer((_) {});

      interceptor.onError(error, handler);

      await Future.delayed(const Duration(milliseconds: 100));

      expect(logs.any((log) => log.contains('DioException')), isTrue);
      verify(() => handler.next(error)).called(1);
    });

    test('onError_whenBadResponseError_shouldLogDetails', () async {
      final interceptor = WSLoggerInterceptor(
        error: true,
        enableConsoleLog: false,
      );
      final handler = MockErrorInterceptorHandler();
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 404,
          statusMessage: 'Not Found',
          data: {'error': 'Resource not found'},
        ),
      );

      final logs = <String>[];
      interceptor.newLogStream.listen(logs.add);

      when(() => handler.next(any())).thenAnswer((_) {});

      interceptor.onError(error, handler);

      await Future.delayed(const Duration(milliseconds: 100));

      expect(logs.any((log) => log.contains('404')), isTrue);
      expect(logs.any((log) => log.contains('Not Found')), isTrue);
    });

    test('onRequest_whenConsoleLoggingDisabled_shouldNotThrow', () async {
      final interceptor = WSLoggerInterceptor(
        enableConsoleLog: false,
      );
      final handler = MockRequestInterceptorHandler();
      final options = RequestOptions(path: '/test');

      when(() => handler.next(any())).thenAnswer((_) {});

      interceptor.onRequest(options, handler);

      // Should not throw or cause issues
      expect(() => interceptor.onRequest(options, handler), returnsNormally);
    });

    test('onRequest_whenFormDataProvided_shouldHandleFormData', () async {
      final interceptor = WSLoggerInterceptor(
        requestBody: true,
        enableConsoleLog: false,
      );
      final handler = MockRequestInterceptorHandler();
      final formData = FormData.fromMap({
        'field1': 'value1',
        'field2': 'value2',
      });
      final options = RequestOptions(
        path: '/test',
        method: 'POST',
        data: formData,
      );

      final logs = <String>[];
      interceptor.newLogStream.listen(logs.add);

      when(() => handler.next(any())).thenAnswer((_) {});

      interceptor.onRequest(options, handler);

      await Future.delayed(const Duration(milliseconds: 100));

      expect(logs.any((log) => log.contains('Form data')), isTrue);
    });

    test('onResponse_whenListResponseData_shouldHandleList', () async {
      final interceptor = WSLoggerInterceptor(
        responseBody: true,
        enableConsoleLog: false,
      );
      final handler = MockResponseInterceptorHandler();
      final response = Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 200,
        data: [
          {'id': 1, 'name': 'Item 1'},
          {'id': 2, 'name': 'Item 2'},
        ],
      );

      final logs = <String>[];
      interceptor.newLogStream.listen(logs.add);

      when(() => handler.next(any())).thenAnswer((_) {});

      interceptor.onResponse(response, handler);

      await Future.delayed(const Duration(milliseconds: 100));

      expect(logs.isNotEmpty, isTrue);
    });
  });
}
