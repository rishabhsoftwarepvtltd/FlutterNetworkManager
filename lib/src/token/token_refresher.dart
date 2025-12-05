/// Interface for implementing token refresh logic.
///
/// Implementations should handle the token refresh process and either:
/// - Return `true` if refresh succeeds and new tokens are saved
/// - Return `false` if refresh fails (for backward compatibility)
/// - Throw [TokenRefreshFailedException] for better error handling (recommended)
///
/// Example implementation:
/// ```dart
/// class MyTokenRefresher implements ITokenRefresher {
///   @override
///   Future<bool> refreshToken() async {
///     try {
///       final refreshToken = await tokenPersister.refreshToken;
///       if (refreshToken == null) {
///         throw TokenRefreshFailedException(
///           'No refresh token available',
///           reason: RefreshFailureReason.noRefreshToken,
///         );
///       }
///
///       final response = await dio.post('/auth/refresh',
///         data: {'refreshToken': refreshToken},
///       );
///
///       await tokenPersister.save(
///         token: response.data['accessToken'],
///         refreshToken: response.data['refreshToken'],
///       );
///       return true;
///     } on DioException catch (e) {
///       throw TokenRefreshFailedException(
///         'Token refresh failed',
///         originalError: e,
///         reason: RefreshFailureReason.networkError,
///       );
///     }
///   }
/// }
/// ```
abstract class ITokenRefresher {
  /// Renew token and store it with help of [ITokenPersister].
  ///
  /// Returns `true` if the refresh was successful, `false` otherwise.
  /// May throw [TokenRefreshFailedException] to provide detailed error information.
  Future<bool> refreshToken();
}
