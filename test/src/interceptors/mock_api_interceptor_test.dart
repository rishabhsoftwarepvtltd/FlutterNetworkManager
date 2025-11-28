import 'package:flutter_test/flutter_test.dart';
import 'package:rspl_network_manager/src/dio_factory.dart';
import 'package:rspl_network_manager/src/interceptors/mock_api_interceptor.dart';

import 'sub_mock_api_interceptor.dart';

String apiMapperContent =
    '{"login": "login-response.json", "user": "user-response.json"}';
String loginResponse =
    '{"data":{"message":"Login is successful.","data":[{"access_token":"access-token-abced1234","expires_in":0,"refresh_expires_in":0,"refresh_token":"refresh-token-abced1234","token_type":"string","not-before-policy":0,"session_state":"string","scope":"string"}]}}';

void main() {
  late SubMockApiInterceptor subMockApiInterceptor;
  MockApiInterceptor? mockApiInterceptor;
  setUp(() async {
    subMockApiInterceptor = await SubMockApiInterceptor.createInstance(
      apiResponseMapperFilePath: "mapper.json",
      mapperFileContent: apiMapperContent,
      serviceAndResponseMap: {'login-response.json': loginResponse},
    );
  });
  test(
    "loadMockResponse_whenFileAndServiceMapExists_shouldReturnNonNull",
    () async {
      final dioClient = const DioFactory("").create();
      dioClient.interceptors.add(subMockApiInterceptor);
      final response = await dioClient.get("login");
      expect(response.data, isNotNull);
    },
  );

  group("loadMockResponseAndReturn", () {
    test(
      "mapperDoesNotContainsServicePath_shouldReturnNull",
      () async {
        final serviceResponse =
            await subMockApiInterceptor.loadMockResponseAndReturn("login1");
        expect(serviceResponse, null);
      },
    );
    test(
      "mapperDoesContainsServicePath_shouldReturnSameResponse",
      () async {
        final serviceResponse =
            await subMockApiInterceptor.loadMockResponseAndReturn("login");
        expect(serviceResponse, loginResponse);
      },
    );
  });

  group("createInstanceUsingMap", () {
    setUp(() {
      mockApiInterceptor = MockApiInterceptor.createInstanceUsingMap(
          servicePathAndResponseFileMap: {'login': 'login-response.json'});
    });
    test("whenServicePathExists_shouldReturnFileName", () {
      final responseFileName =
          mockApiInterceptor?.apiNameAndFilePathMap['login'];
      expect(responseFileName, isNotNull);
    });
    test("whenServicePathDoesNotExists_shouldReturnNull", () {
      final responseFileName =
          mockApiInterceptor?.apiNameAndFilePathMap['login1'];
      expect(responseFileName, isNull);
    });
  });
}
