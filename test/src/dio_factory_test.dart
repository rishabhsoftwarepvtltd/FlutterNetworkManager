import 'package:flutter_test/flutter_test.dart';
import 'package:rspl_network_manager/rspl_network_manager.dart';

void main() {
  test("Base URL set into factory must reflect in client object", () {
    const baseUrl = "http://www.example.com";
    const dioFactory = DioFactory(baseUrl);
    final dioClient = dioFactory.create();
    expect(dioClient.options.baseUrl, baseUrl);
  });
  test("Provided header should reflect in client object", () {
    const tokenValue = "12345";
    const dioFactory = DioFactory("");
    final headers = {'token': tokenValue};
    final dioClient = dioFactory.create(headers: headers);
    final value = dioClient.options.headers["token"];
    expect(value, tokenValue);
  });
}
