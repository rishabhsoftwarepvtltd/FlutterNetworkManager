/// Constants for token storage keys used by [ITokenPersister] implementations.
///
/// These keys are used to store and retrieve tokens from secure storage.
class PersisterKeys {
  /// Key for storing the access token.
  static const token = "token";

  /// Key for storing the refresh token.
  static const refreshToken = "refresh_token";
}
