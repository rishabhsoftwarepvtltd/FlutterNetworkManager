import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rspl_network_manager/rspl_network_manager.dart';

/// Handles token refresh using the /api/v1/auth/refresh-token endpoint.
class TokenRefresher implements ITokenRefresher {
  TokenRefresher({
    required this.tokenPersister,
    required this.dio,
  });

  final ITokenPersister tokenPersister;
  final Dio dio;

  @override
  Future<bool> refreshToken() async {
    debugPrint("*** Starting refresh token operation");
    try {
      // Get the current refresh token
      final refreshToken = await tokenPersister.refreshToken;

      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint("*** No refresh token available");
        return false;
      }

      // Call the refresh-token endpoint
      final response = await dio.post(
        TokenUris.refreshToken,
        data: {'refreshToken': refreshToken},
        options: Options(
          extra: {
            // Disable retry for refresh token request
            'disableRetry': true,
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        final newAccessToken = data['access_token'] as String?;
        final newRefreshToken = data['refresh_token'] as String?;

        if (newAccessToken != null && newRefreshToken != null) {
          // Save the new tokens using the ITokenPersister interface
          await tokenPersister.save(
            token: newAccessToken,
            refreshToken: newRefreshToken,
          );

          debugPrint("*** Successfully refreshed tokens");
          return true;
        }
      }

      debugPrint("*** Failed to refresh token: Invalid response");
      return false;
    } on DioException catch (error) {
      debugPrint("*** Dio Exception in TokenRefresher : refreshToken()");
      debugPrint(error.toString());
      return false;
    } on Exception catch (error) {
      debugPrint("*** Exception in TokenRefresher : refreshToken()");
      debugPrint(error.toString());
      return false;
    }
  }

  /// Manually expire the access token for testing purposes.
  /// This sets the token to an invalid value to trigger a 401 error.
  Future<void> expireAccessToken() async {
    debugPrint("*** Manually expiring access token for testing");
    final currentRefreshToken = await tokenPersister.refreshToken;
    await tokenPersister.save(
      token: "expired_token_for_testing",
      refreshToken: currentRefreshToken,
    );
  }

  /// Get the current access token.
  Future<String?> getAccessToken() async {
    return await tokenPersister.token;
  }

  /// Get the current refresh token.
  Future<String?> getRefreshToken() async {
    return await tokenPersister.refreshToken;
  }
}

class TokenUris {
  static const refreshToken = "/api/v1/auth/refresh-token";
}
