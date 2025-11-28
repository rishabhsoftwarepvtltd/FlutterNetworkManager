import 'package:dio/dio.dart';
import 'package:example/profile/domain/profile.dart';
import 'package:flutter/material.dart';
import 'package:rspl_network_manager/rspl_network_manager.dart';

/// API client for fetching user profile data.
class ProfileApi {
  ProfileApi({required Dio dioClient}) : _dioClient = dioClient;

  final Dio _dioClient;

  /// Fetches the authenticated user's profile.
  ///
  /// Requires a valid access token in the Authorization header.
  Future<Profile> getProfile() async {
    try {
      final response = await _dioClient.get(ProfileUris.profile);
      debugPrint("Profile Response status code: ${response.statusCode}");
      return Profile.fromJson(response.data);
    } on DioException catch (dioError, e) {
      if (dioError.isInternetConnectionError) {
        throw NoInternetConnectionException(stackTrace: e);
      } else {
        rethrow;
      }
    }
  }
}

class ProfileUris {
  static const profile = "/api/v1/auth/profile";
}
