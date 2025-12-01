import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rspl_network_manager/rspl_network_manager.dart';

import '../token/keychain_token_persister_test.dart';
import 'mock_api_interceptor_test.dart';
import 'sub_mock_api_interceptor.dart';

void main() {
  late SubMockApiInterceptor mockApiInterceptor;
  late MockFlutterSecureStorage mockFlutterSecureStorage;
  setUp(() async {
    mockFlutterSecureStorage = MockFlutterSecureStorage();
    mockApiInterceptor = await SubMockApiInterceptor.createInstance(
      apiResponseMapperFilePath: "mapper.json",
      mapperFileContent: apiMapperContent,
      serviceAndResponseMap: {'login-response.json': loginResponse},
    );
  });
  group("tokenInterceptor", () {
    test(
      "onRequest_whenNonExemptRequest_shouldAddTokenToHeader",
      () async {
        const String tokenValue = "token123#";
        when(() => mockFlutterSecureStorage.read(key: PersisterKeys.token))
            .thenAnswer((invocation) => Future.value(tokenValue));
        final dioClient = const DioFactory("").create();
        dioClient.interceptors.add(
          TokenInterceptor(
            tokenPersister:
                KeyChainTokenPersister(storage: mockFlutterSecureStorage),
            exceptionList: ['login'],
          ),
        );
        dioClient.interceptors.add(mockApiInterceptor);

        final response = await dioClient.get("user");
        final requestHeaders = response.requestOptions.headers;
        final authValue = requestHeaders["authorization"];
        expect(authValue, "Bearer $tokenValue");
      },
    );
    test("onRequest_whenExemptRequest_shouldNotAddTokenToHeader",
        () async {
      final dioClient = const DioFactory("").create();
      dioClient.interceptors.add(
        TokenInterceptor(
          tokenPersister:
              KeyChainTokenPersister(storage: mockFlutterSecureStorage),
          exceptionList: ['login'],
        ),
      );
      dioClient.interceptors.add(mockApiInterceptor);

      final response = await dioClient.get("login");
      final requestHeaders = response.requestOptions.headers;
      final authValue = requestHeaders["authorization"];
      expect(authValue, isNull);
    });
  });
}
