import 'package:rspl_network_manager/src/interceptors/mock_api_interceptor.dart';

class SubMockApiInterceptor extends MockApiInterceptor {
  static Future<SubMockApiInterceptor> createInstance({
    required String apiResponseMapperFilePath,
    required String mapperFileContent,
    required Map<String, String> serviceAndResponseMap,
  }) async {
    final mockApiInterceptor = SubMockApiInterceptor._(
      mapperFileContent: mapperFileContent,
      serviceAndResponseMap: serviceAndResponseMap,
    );
    await mockApiInterceptor
        .updateApiResponseMapperFilePath(apiResponseMapperFilePath);
    return mockApiInterceptor;
  }

  SubMockApiInterceptor._({
    required this.mapperFileContent,
    required this.serviceAndResponseMap,
  });

  final String mapperFileContent;
  final Map<String, String> serviceAndResponseMap;

  @override
  Future<String> loadContentFromPath(String path) {
    if (path == apiResponseMapperFilePath) {
      return Future.value(mapperFileContent);
    } else {
      final response = serviceAndResponseMap[path] ?? "{}";
      return Future.value(response);
    }
  }
}
