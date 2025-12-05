import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'persister_keys.dart';

import 'token_persister.dart';

/// Secure token persister using platform-specific keychain/keystore.
///
/// This implementation uses [FlutterSecureStorage] to store tokens securely:
/// - **iOS/macOS**: Keychain
/// - **Android**: EncryptedSharedPreferences
/// - **Web**: Web Crypto API
///
/// Tokens are encrypted at rest and only accessible by your app.
///
/// Example:
/// ```dart
/// final tokenPersister = KeyChainTokenPersister();
///
/// // Save tokens
/// await tokenPersister.save(
///   token: 'access_token_here',
///   refreshToken: 'refresh_token_here',
/// );
///
/// // Read tokens
/// final accessToken = await tokenPersister.token;
/// final refreshToken = await tokenPersister.refreshToken;
///
/// // Remove tokens (e.g., on logout)
/// await tokenPersister.remove();
/// ```
class KeyChainTokenPersister implements ITokenPersister {
  /// Creates a [KeyChainTokenPersister] with optional custom storage.
  ///
  /// By default, uses [FlutterSecureStorage] with encrypted shared preferences
  /// on Android for maximum security.
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
