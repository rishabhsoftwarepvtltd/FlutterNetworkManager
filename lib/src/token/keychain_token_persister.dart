import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'persister_keys.dart';

import 'token_persister.dart';

class KeyChainTokenPersister implements ITokenPersister {
  const KeyChainTokenPersister({
    FlutterSecureStorage storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  }) : _storage = storage;
  final FlutterSecureStorage _storage;

  @override
  Future<String?> get token => _storage.read(key: PersisterKeys.token);

  @override
  Future<String?> get refreshToken =>
      _storage.read(key: PersisterKeys.refreshToken);

  @override
  Future<void> save({String? token, String? refreshToken}) async {
    if (token != null && token.isNotEmpty) {
      await _storage.write(key: PersisterKeys.token, value: token);
    }

    if (refreshToken != null && refreshToken.isNotEmpty) {
      return _storage.write(
          key: PersisterKeys.refreshToken, value: refreshToken);
    }
  }

  @override
  Future<void> remove() async {
    await _storage.delete(key: PersisterKeys.token);
    await _storage.delete(key: PersisterKeys.refreshToken);
  }
}
