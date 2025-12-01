import 'package:flutter_test/flutter_test.dart';
import 'package:rspl_network_manager/src/exceptions/network_exceptions.dart';

void main() {
  group('NoInternetConnectionException', () {
    test('constructor_whenNoStackTrace_shouldCreateWithNullStackTrace', () {
      final exception = NoInternetConnectionException();

      expect(exception, isA<Exception>());
      expect(exception.stackTrace, isNull);
    });

    test('constructor_whenStackTraceProvided_shouldStoreStackTrace', () {
      final stackTrace = StackTrace.current;
      final exception = NoInternetConnectionException(stackTrace: stackTrace);

      expect(exception, isA<Exception>());
      expect(exception.stackTrace, equals(stackTrace));
    });

    test('type_whenCreated_shouldBeException', () {
      final exception = NoInternetConnectionException();

      expect(exception, isA<Exception>());
    });
  });
}
