import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rspl_network_manager/src/extensions/options_extension.dart';

void main() {
  group('OptionsX', () {
    test('tokenNotRequired_whenNotSet_shouldDefaultToFalse', () {
      final options = Options();

      expect(options.tokenNotRequired, isFalse);
    });

    test('tokenNotRequired_whenSetToTrue_shouldReturnTrue', () {
      final options = Options(extra: {})..tokenNotRequired = true;

      expect(options.tokenNotRequired, isTrue);
    });

    test('tokenNotRequired_whenSetToFalse_shouldReturnFalse', () {
      final options = Options(extra: {})..tokenNotRequired = false;

      expect(options.tokenNotRequired, isFalse);
    });

    test('tokenNotRequired_whenSet_shouldPersistInExtra', () {
      final options = Options(extra: {})..tokenNotRequired = true;

      expect(options.extra?['token-not-required'], isTrue);
    });
  });

  group('RequestOptionsX', () {
    test('tokenNotRequired_whenNotSet_shouldDefaultToFalse', () {
      final requestOptions = RequestOptions(path: '/test');

      expect(requestOptions.tokenNotRequired, isFalse);
    });

    test('tokenNotRequired_whenSetToTrue_shouldReturnTrue', () {
      final requestOptions = RequestOptions(path: '/test')..tokenNotRequired = true;

      expect(requestOptions.tokenNotRequired, isTrue);
    });

    test('tokenNotRequired_whenSetToFalse_shouldReturnFalse', () {
      final requestOptions = RequestOptions(path: '/test')..tokenNotRequired = false;

      expect(requestOptions.tokenNotRequired, isFalse);
    });

    test('tokenNotRequired_whenSet_shouldPersistInExtra', () {
      final requestOptions = RequestOptions(path: '/test')..tokenNotRequired = true;

      expect(requestOptions.extra['token-not-required'], isTrue);
    });

    test('tokenNotRequired_whenReadFromOptions_shouldReturnCorrectValue', () {
      final options = Options(extra: {})..tokenNotRequired = true;
      final requestOptions = RequestOptions(
        path: '/test',
        extra: Map<String, dynamic>.from(options.extra ?? {}),
      );

      expect(requestOptions.tokenNotRequired, isTrue);
    });
  });
}
