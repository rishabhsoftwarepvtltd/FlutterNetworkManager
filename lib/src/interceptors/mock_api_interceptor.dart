import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MockApiInterceptor extends Interceptor {
  static Future<MockApiInterceptor> createInstance(
      {required String apiResponseMapperFilePath}) async {
    final mockApiInterceptor = MockApiInterceptor();
    await mockApiInterceptor
        .updateApiResponseMapperFilePath(apiResponseMapperFilePath);
    return mockApiInterceptor;
  }

  static MockApiInterceptor createInstanceUsingMap(
      {required Map<String, String> servicePathAndResponseFileMap}) {
    final mockApiInterceptor = MockApiInterceptor();
    mockApiInterceptor.apiNameAndFilePathMap = servicePathAndResponseFileMap;
    return mockApiInterceptor;
  }

  ///This would be a file name.
  ///This file would have map of "api name" and "response json file name".
  String _apiResponseMapperFilePath = "";

  String get apiResponseMapperFilePath {
    return _apiResponseMapperFilePath;
  }

  Map<String, String> apiNameAndFilePathMap = {};

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
        } else {
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
