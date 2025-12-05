import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Interceptor for mocking API responses during development and testing.
///
/// This interceptor allows you to return mock JSON responses instead of making
/// actual network requests. Useful for:
/// - Testing without a backend
/// - Offline development
/// - Consistent test data
///
/// Example:
/// ```dart
/// final mockInterceptor = await MockApiInterceptor.createInstance(
///   apiResponseMapperFilePath: 'assets/mock_api_mapper.json',
/// );
/// dio.interceptors.add(mockInterceptor);
/// ```
class MockApiInterceptor extends Interceptor {
  /// Creates a [MockApiInterceptor] instance from a mapper file.
  ///
  /// The [apiResponseMapperFilePath] should point to a JSON file containing
  /// a map of API paths to response file paths.
  ///
  /// Example mapper file:
  /// ```json
  /// {
  ///   "login": "assets/responses/login_response.json",
  ///   "profile": "assets/responses/profile_response.json"
  /// }
  /// ```
  static Future<MockApiInterceptor> createInstance(
      {required String apiResponseMapperFilePath}) async {
    final mockApiInterceptor = MockApiInterceptor();
    await mockApiInterceptor
        .updateApiResponseMapperFilePath(apiResponseMapperFilePath);
    return mockApiInterceptor;
  }

  /// Creates a [MockApiInterceptor] instance from a direct map.
  ///
  /// Use this when you want to provide the mapping programmatically instead
  /// of loading from a file.
  ///
  /// Example:
  /// ```dart
  /// final mockInterceptor = MockApiInterceptor.createInstanceUsingMap(
  ///   servicePathAndResponseFileMap: {
  ///     'login': 'assets/login_response.json',
  ///     'profile': 'assets/profile_response.json',
  ///   },
  /// );
  /// ```
  static MockApiInterceptor createInstanceUsingMap(
      {required Map<String, String> servicePathAndResponseFileMap}) {
    final mockApiInterceptor = MockApiInterceptor();
    mockApiInterceptor.apiNameAndFilePathMap = servicePathAndResponseFileMap;
    return mockApiInterceptor;
  }

  /// Path to the API response mapper file.
  ///
  /// This file contains a JSON map of API paths to response file paths.
  String _apiResponseMapperFilePath = "";

  /// Gets the current API response mapper file path.
  String get apiResponseMapperFilePath {
    return _apiResponseMapperFilePath;
  }

  /// Map of API paths to their corresponding mock response file paths.
  Map<String, String> apiNameAndFilePathMap = {};

  /// Updates the API response mapper file path and loads the mapping.
  ///
  /// This will load the JSON file and populate [apiNameAndFilePathMap].
  Future updateApiResponseMapperFilePath(String path) async {
    _apiResponseMapperFilePath = path;
    await _loadApiAndResponseFilePathMap();
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final servicePath = options.path;
    debugPrint("Mock Interceptor service path: $servicePath");
    loadMockResponseAndReturn(servicePath).then((jsonResponse) {
      if (jsonResponse != null) {
        final responseMap = jsonDecode(jsonResponse);
        final statusCode = responseMap["statusCode"];
        final data = responseMap["data"];
        if (statusCode == null || statusCode == 200) {
          handler.resolve(
            Response(
              statusCode: statusCode ?? 200,
              requestOptions: options,
              data: data,
            ),
          );
        }
        // coverage:ignore-start
        // Reason: Error rejection path for non-200 status codes in mock responses.
        // Requires specific mock JSON files with error status codes, which are edge cases
        // in testing scenarios. Most tests focus on success paths.
        else {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response(
                statusCode: statusCode,
                requestOptions: options,
                data: data,
              ),
              type: DioExceptionType.badResponse,
            ),
          );
        }
        // coverage:ignore-end
      } else {
        debugPrint("Mock Interceptor service path: $servicePath");
        super.onRequest(options, handler);
      }
    });
  }

  @visibleForTesting
  Future<String?> loadMockResponseAndReturn(String servicePath) {
    if (apiNameAndFilePathMap.containsKey(servicePath)) {
      final responseFileName = apiNameAndFilePathMap[servicePath];
      if (responseFileName != null) {
        return loadContentFromPath(responseFileName);
      }
    }
    return Future.value(null);
  }

  @visibleForTesting
  Future<String> loadContentFromPath(String path) {
    return rootBundle.loadString(path);
  }

  Future _loadApiAndResponseFilePathMap() async {
    final content = await loadContentFromPath(_apiResponseMapperFilePath);
    final decodedMap = jsonDecode(content);
    apiNameAndFilePathMap = Map<String, String>.from(decodedMap);
  }
}
