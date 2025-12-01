import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rspl_network_manager/rspl_network_manager.dart';
import 'package:rspl_network_manager/src/proxy_config.dart';

void main() {
  test("create_whenBaseUrlProvided_shouldReflectInClientObject", () {
    const baseUrl = "http://www.example.com";
    const dioFactory = DioFactory(baseUrl);
    final dioClient = dioFactory.create();
    expect(dioClient.options.baseUrl, baseUrl);
  });
  
  test("create_whenHeadersProvided_shouldReflectInClientObject", () {
    const tokenValue = "12345";
    const dioFactory = DioFactory("");
    final headers = {'token': tokenValue};
    final dioClient = dioFactory.create(headers: headers);
    final value = dioClient.options.headers["token"];
    expect(value, tokenValue);
  });

  test("createWithOptions_whenCustomOptionsProvided_shouldCreateDioWithCustomOptions", () {
    const dioFactory = DioFactory("http://example.com");
    final customOptions = BaseOptions(
      baseUrl: "http://custom.com",
      connectTimeout: const Duration(seconds: 10),
    );
    final dioClient = dioFactory.createWithOptions(customOptions);
    expect(dioClient.options.baseUrl, "http://custom.com");
    expect(dioClient.options.connectTimeout, const Duration(seconds: 10));
  });

  test("create_whenProxyConfigProvided_shouldSetupProxy", () {
    const dioFactory = DioFactory("http://example.com");
    final proxyConfig = ProxyConfig(ip: "127.0.0.1", port: 8080);
    final dioClient = dioFactory.create(proxyConfig: proxyConfig);
    expect(dioClient, isNotNull);
    expect(dioClient.options.baseUrl, "http://example.com");
  });

  test("create_whenNoParametersProvided_shouldSetDefaultTimeouts", () {
    const dioFactory = DioFactory("http://example.com");
    final dioClient = dioFactory.create();
    expect(dioClient.options.connectTimeout, const Duration(milliseconds: 5000));
    expect(dioClient.options.receiveTimeout, const Duration(milliseconds: 15000));
    expect(dioClient.options.sendTimeout, const Duration(milliseconds: 15000));
  });

  test("create_whenBothHeadersAndProxyConfigProvided_shouldApplyBoth", () {
    const dioFactory = DioFactory("http://example.com");
    final headers = {'Authorization': 'Bearer token'};
    final proxyConfig = ProxyConfig(ip: "192.168.1.1", port: 3128);
    final dioClient = dioFactory.create(
      headers: headers,
      proxyConfig: proxyConfig,
    );
    expect(dioClient.options.headers['Authorization'], 'Bearer token');
  });
}
