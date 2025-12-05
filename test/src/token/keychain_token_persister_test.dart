import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rspl_network_manager/src/token/keychain_token_persister.dart';
import 'package:rspl_network_manager/src/token/persister_keys.dart';

void main() {
  late KeyChainTokenPersister tokenPersister;
  late MockFlutterSecureStorage mockSecureStorage;
  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    tokenPersister = KeyChainTokenPersister(storage: mockSecureStorage);
  });
  group("save:", () {
    test("save_whenOnlyTokenProvided_shouldWriteTokenToStorage", () async {
      String token = "myToken123";
      when(
        () => mockSecureStorage.write(
          key: any(named: "key"),
          value: any(named: "value"),
        ),
      ).thenAnswer((_) => Future.value());
      await tokenPersister.save(token: token);
      verify(() =>
          mockSecureStorage.write(key: PersisterKeys.token, value: token));
      verifyNever(() => mockSecureStorage.write(
          key: PersisterKeys.refreshToken, value: any(named: "value")));
    });
    test("save_whenOnlyRefreshTokenProvided_shouldWriteRefreshTokenToStorage",
        () async {
      String refreshToken = "myToken123";
      when(
        () => mockSecureStorage.write(
            key: PersisterKeys.refreshToken, value: refreshToken),
      ).thenAnswer((_) async {});
      await tokenPersister.save(refreshToken: refreshToken);
      verify(() => mockSecureStorage.write(
          key: PersisterKeys.refreshToken, value: refreshToken));
      verifyNever(() => mockSecureStorage.write(
          key: PersisterKeys.token, value: any(named: "value")));
    });
  });

  group("remove", () {
    test("remove_whenCalled_shouldDeleteBothTokens", () async {
      when(() => mockSecureStorage.delete(key: any(named: "key")))
          .thenAnswer((_) => Future.value());
      await tokenPersister.remove();
      verify(() => mockSecureStorage.delete(key: PersisterKeys.token));
      verify(() => mockSecureStorage.delete(key: PersisterKeys.refreshToken));
    });
  });

  group("token getter", () {
    test("token_whenStorageHasToken_shouldReturnToken", () async {
      const tokenValue = "myToken123";
      when(() => mockSecureStorage.read(key: PersisterKeys.token))
          .thenAnswer((_) async => tokenValue);

      final token = await tokenPersister.token;

      expect(token, tokenValue);
      verify(() => mockSecureStorage.read(key: PersisterKeys.token)).called(1);
    });

    test("token_whenStorageEmpty_shouldReturnNull", () async {
      when(() => mockSecureStorage.read(key: PersisterKeys.token))
          .thenAnswer((_) async => null);

      final token = await tokenPersister.token;

      expect(token, isNull);
    });
  });

  group("refreshToken getter", () {
    test("refreshToken_whenStorageHasRefreshToken_shouldReturnRefreshToken",
        () async {
      const refreshTokenValue = "myRefreshToken123";
      when(() => mockSecureStorage.read(key: PersisterKeys.refreshToken))
          .thenAnswer((_) async => refreshTokenValue);

      final refreshToken = await tokenPersister.refreshToken;

      expect(refreshToken, refreshTokenValue);
      verify(() => mockSecureStorage.read(key: PersisterKeys.refreshToken))
          .called(1);
    });

    test("refreshToken_whenStorageEmpty_shouldReturnNull", () async {
      when(() => mockSecureStorage.read(key: PersisterKeys.refreshToken))
          .thenAnswer((_) async => null);

      final refreshToken = await tokenPersister.refreshToken;

      expect(refreshToken, isNull);
    });
  });
}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
