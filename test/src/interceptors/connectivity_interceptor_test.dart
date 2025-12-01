import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rspl_network_manager/src/interceptors/connectivity_interceptor.dart';

class MockConnectivity extends Mock implements Connectivity {}

class MockRequestInterceptorHandler extends Mock implements RequestInterceptorHandler {}

void main() {
  late MockConnectivity mockConnectivity;
  late StreamController<List<ConnectivityResult>> connectivityController;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/test'));
    registerFallbackValue(
      DioException(requestOptions: RequestOptions(path: '/test')),
    );
  });

  setUp(() {
    mockConnectivity = MockConnectivity();
    connectivityController = StreamController<List<ConnectivityResult>>.broadcast();

    when(() => mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => connectivityController.stream);
  });

  tearDown(() {
    connectivityController.close();
  });

  group('ConnectivityInterceptor', () {
    test('onRequest_whenConnectivityAvailable_shouldAllowRequest', () async {
      final interceptor = ConnectivityInterceptor(connectivity: mockConnectivity);
      final handler = MockRequestInterceptorHandler();
      final options = RequestOptions(path: '/test');

      // Simulate wifi connection
      connectivityController.add([ConnectivityResult.wifi]);
      await Future.delayed(const Duration(milliseconds: 100));

      var handlerCalled = false;
      when(() => handler.next(any())).thenAnswer((_) {
        handlerCalled = true;
      });

      interceptor.onRequest(options, handler);

      expect(handlerCalled, isTrue);
      verify(() => handler.next(options)).called(1);
    });

    test('onRequest_whenNoConnectivity_shouldRejectRequest', () async {
      final interceptor = ConnectivityInterceptor(connectivity: mockConnectivity);
      final handler = MockRequestInterceptorHandler();
      final options = RequestOptions(path: '/test');

      // Simulate no connection
      connectivityController.add([ConnectivityResult.none]);
      await Future.delayed(const Duration(milliseconds: 100));

      var rejectCalled = false;
      when(() => handler.reject(any())).thenAnswer((invocation) {
        rejectCalled = true;
        final exception = invocation.positionalArguments[0] as DioException;
        expect(exception.type, DioExceptionType.connectionTimeout);
        expect(exception.error, 'no_internet_connectivity');
      });

      interceptor.onRequest(options, handler);

      expect(rejectCalled, isTrue);
      verify(() => handler.reject(any())).called(1);
    });

    test('onRequest_whenConnectivityStatusNull_shouldAllowRequest', () {
      final interceptor = ConnectivityInterceptor(connectivity: mockConnectivity);
      final handler = MockRequestInterceptorHandler();
      final options = RequestOptions(path: '/test');

      var handlerCalled = false;
      when(() => handler.next(any())).thenAnswer((_) {
        handlerCalled = true;
      });

      interceptor.onRequest(options, handler);

      expect(handlerCalled, isTrue);
      verify(() => handler.next(options)).called(1);
    });

    test('onRequest_whenConnectionChanges_shouldUpdateStatus', () async {
      final interceptor = ConnectivityInterceptor(connectivity: mockConnectivity);
      final handler = MockRequestInterceptorHandler();
      final options = RequestOptions(path: '/test');

      // Start with wifi
      connectivityController.add([ConnectivityResult.wifi]);
      await Future.delayed(const Duration(milliseconds: 100));

      when(() => handler.next(any())).thenAnswer((_) {});
      interceptor.onRequest(options, handler);
      verify(() => handler.next(options)).called(1);

      // Change to no connection
      connectivityController.add([ConnectivityResult.none]);
      await Future.delayed(const Duration(milliseconds: 100));

      when(() => handler.reject(any())).thenAnswer((_) {});
      interceptor.onRequest(options, handler);
      verify(() => handler.reject(any())).called(1);
    });

    test('onRequest_whenMobileConnectivity_shouldAllowRequest', () async {
      final interceptor = ConnectivityInterceptor(connectivity: mockConnectivity);
      final handler = MockRequestInterceptorHandler();
      final options = RequestOptions(path: '/test');

      connectivityController.add([ConnectivityResult.mobile]);
      await Future.delayed(const Duration(milliseconds: 100));

      var handlerCalled = false;
      when(() => handler.next(any())).thenAnswer((_) {
        handlerCalled = true;
      });

      interceptor.onRequest(options, handler);

      expect(handlerCalled, isTrue);
    });

    test('onRequest_whenEthernetConnectivity_shouldAllowRequest', () async {
      final interceptor = ConnectivityInterceptor(connectivity: mockConnectivity);
      final handler = MockRequestInterceptorHandler();
      final options = RequestOptions(path: '/test');

      connectivityController.add([ConnectivityResult.ethernet]);
      await Future.delayed(const Duration(milliseconds: 100));

      var handlerCalled = false;
      when(() => handler.next(any())).thenAnswer((_) {
        handlerCalled = true;
      });

      interceptor.onRequest(options, handler);

      expect(handlerCalled, isTrue);
    });
  });
}
