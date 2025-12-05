/// Interface for writing authentication tokens to storage.
abstract class ITokenWriter {
  /// Saves the access token and/or refresh token to secure storage.
  ///
  /// Either [token] or [refreshToken] can be null if only one needs to be updated.
  Future<void> save({String? token, String? refreshToken});
  
  /// Removes all stored tokens from secure storage.
  Future<void> remove();
}

/// Interface for reading authentication tokens from storage.
abstract class ITokenReader {
  /// Retrieves the access token from secure storage.
  ///
  /// Returns `null` if no token is stored.
  Future<String?> get token;
  
  /// Retrieves the refresh token from secure storage.
  ///
  /// Returns `null` if no refresh token is stored.
  Future<String?> get refreshToken;
}

/// Combined interface for reading and writing authentication tokens.
///
/// Implementations should use secure storage mechanisms like
/// [KeyChainTokenPersister] which uses [FlutterSecureStorage].
///
/// Example implementation:
/// ```dart
/// class MyTokenPersister implements ITokenPersister {
///   final FlutterSecureStorage _storage;
///
///   @override
///   Future<String?> get token => _storage.read(key: 'token');
///
///   @override
///   Future<void> save({String? token, String? refreshToken}) async {
///     if (token != null) await _storage.write(key: 'token', value: token);
///   }
///
///   // ... implement other methods
/// }
/// ```
abstract class ITokenPersister implements ITokenReader, ITokenWriter {}
