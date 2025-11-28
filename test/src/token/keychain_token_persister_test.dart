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
    test(
        "When saving only token, token should interact with write function of storage",
        () async {
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
    test(
        "When saving only refresh token, refresh token should interact with write function of storage",
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
    test("When calling remove, it should interact with delete", () async {
      when(() => mockSecureStorage.delete(key: any(named: "key")))
          .thenAnswer((_) => Future.value());
      await tokenPersister.remove();
      verify(() => mockSecureStorage.delete(key: PersisterKeys.token));
      verify(() => mockSecureStorage.delete(key: PersisterKeys.refreshToken));
    });
  });
}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
