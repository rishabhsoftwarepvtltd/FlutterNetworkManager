import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:example/login/data/login_response.dart';
import 'package:flutter/material.dart';
import 'package:rspl_network_manager/rspl_network_manager.dart';

class AuthenticationApi {
  AuthenticationApi({required Dio dioClient}) : _dioClient = dioClient;

  final Dio _dioClient;

  Future<LoginResponse> login(
      {required String username, required String password}) async {
    Map<String, String> body = {"email": username, "password": password};
    try {
      final jsonBody = jsonEncode(body);
      final options = Options(extra: {});
      options.disableRetry = true;
      debugPrint(options.disableRetry.toString());
      final response = await _dioClient.post(
        AuthenticationUris.login,
        data: jsonBody,
        options: options,
      );
      debugPrint("Response status code: ${response.statusCode}");
      return LoginResponse.fromJson(response.data);
    } on DioException catch (dioError, e) {
      if (dioError.isInternetConnectionError) {
        throw NoInternetConnectionException(stackTrace: e);
      } else {
        rethrow;
      }
    }
  }
}

class AuthenticationUris {
  static const login = "/api/v1/auth/login";
}
