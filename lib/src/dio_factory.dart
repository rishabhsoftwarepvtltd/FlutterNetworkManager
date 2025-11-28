import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'proxy_config.dart';

/// Factory class for creating and configuring [Dio] HTTP client instances.
///
/// [DioFactory] provides a convenient way to create [Dio] instances with
/// pre-configured base URLs, timeouts, custom headers, and optional proxy settings.
///
/// Example:
/// ```dart
/// final factory = DioFactory('https://api.example.com');
/// final dio = factory.create(
///   headers: {'Custom-Header': 'value'},
///   proxyConfig: ProxyConfig(ip: '127.0.0.1', port: 8080),
/// );
/// ```
class DioFactory {
  const DioFactory(this._baseUrl);

  final String _baseUrl;

  /// Creates a [Dio] instance with default configuration.
  ///
  /// Optionally accepts custom [headers] and [proxyConfig] for proxy setup.
  /// Returns a fully configured [Dio] client ready for HTTP requests.
  Dio create({Map<String, dynamic>? headers, ProxyConfig? proxyConfig}) {
    final baseOptions = _createBaseOptions();
    if (headers != null) {
      baseOptions.headers.addAll(headers);
    }
    final dio = Dio(baseOptions);
    if (proxyConfig != null) {
      _setupProxy(dio, proxyConfig);
    }
    return dio;
  }

  /// Creates a [Dio] instance with custom [BaseOptions].
  ///
  /// Use this method when you need full control over the Dio configuration.
  Dio createWithOptions(BaseOptions options) => Dio(options);

  BaseOptions _createBaseOptions() => BaseOptions(
        // Request base url
        baseUrl: _baseUrl,

        // Timeout in milliseconds for receiving data
        receiveTimeout: const Duration(milliseconds: 15000),

        // Timeout in milliseconds for sending data
        sendTimeout: const Duration(milliseconds: 15000),

        // Timeout in milliseconds for opening url
        connectTimeout: const Duration(milliseconds: 5000),

        // Common headers for each request
        headers: {},
      );

  void _setupProxy(Dio dio, ProxyConfig proxyConfig) {
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final HttpClient client = HttpClient();
      client.findProxy = (uri) {
        return 'PROXY ${proxyConfig.ip}:${proxyConfig.port}';
      };
      return client;
    };
  }
}
