import 'package:flutter_test/flutter_test.dart';
import 'package:rspl_network_manager/src/proxy_config.dart';

void main() {
  group('ProxyConfig', () {
    test('constructor_whenIpAndPortProvided_shouldStoreValues', () {
      final config = ProxyConfig(ip: '192.168.1.1', port: 8080);

      expect(config.ip, equals('192.168.1.1'));
      expect(config.port, equals(8080));
    });

    test('ip_whenSet_shouldReturnCorrectValue', () {
      final config = ProxyConfig(ip: '10.0.0.1', port: 3128);

      expect(config.ip, equals('10.0.0.1'));
    });

    test('port_whenSet_shouldReturnCorrectValue', () {
      final config = ProxyConfig(ip: '127.0.0.1', port: 9999);

      expect(config.port, equals(9999));
    });

    test('ip_whenDifferentFormats_shouldHandleAll', () {
      final configs = [
        ProxyConfig(ip: 'localhost', port: 8080),
        ProxyConfig(ip: '0.0.0.0', port: 8080),
        ProxyConfig(ip: 'proxy.example.com', port: 8080),
      ];

      expect(configs[0].ip, equals('localhost'));
      expect(configs[1].ip, equals('0.0.0.0'));
      expect(configs[2].ip, equals('proxy.example.com'));
    });
  });
}
