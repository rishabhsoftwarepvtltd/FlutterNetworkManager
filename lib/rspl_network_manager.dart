/// A Flutter plugin that simplifies networking with Dio.
///
/// This package provides utilities for building robust HTTP clients with features like:
/// - Configurable logging for debugging network requests
/// - Secure token persistence using flutter_secure_storage
/// - Mock API support for testing and development
/// - Automatic token refresh with retry logic
/// - Connectivity checks before making requests
/// - Proxy configuration support
///
/// ## Basic Usage
///
/// ```dart
/// import 'package:rspl_network_manager/rspl_network_manager.dart';
///
/// // Create a Dio instance
/// final factory = DioFactory('https://api.example.com');
/// final dio = factory.create();
///
/// // Add interceptors
/// dio.interceptors.addAll([
///   LoggerInterceptor(),
///   TokenInterceptor(
///     tokenPersister: KeyChainTokenPersister(),
///     exceptionList: ['/login'],
///   ),
///   ConnectivityInterceptor(),
/// ]);
///
/// // Make requests
/// final response = await dio.get('/users');
/// ```
// coverage:ignore-file
library;

export 'package:rspl_network_manager/src/dio_factory.dart';
export 'package:rspl_network_manager/src/exceptions/dio_exception_extension.dart';
export 'package:rspl_network_manager/src/exceptions/network_exceptions.dart';
export 'package:rspl_network_manager/src/exceptions/token_refresh_exception.dart';
export 'package:rspl_network_manager/src/interceptors/connectivity_interceptor.dart';
export 'package:rspl_network_manager/src/interceptors/logger_interceptor.dart';
export 'package:rspl_network_manager/src/interceptors/mock_api_interceptor.dart';
export 'package:rspl_network_manager/src/interceptors/token_interceptor.dart';
export 'package:rspl_network_manager/src/interceptors/token_refresh_interceptor.dart';
export 'package:rspl_network_manager/src/token/keychain_token_persister.dart';
export 'package:rspl_network_manager/src/token/persister_keys.dart';
export 'package:rspl_network_manager/src/token/token_persister.dart';
export 'package:rspl_network_manager/src/token/token_refresher.dart';
export 'package:rspl_network_manager/src/token/token_retry_evaluator.dart';
export 'package:rspl_network_manager/src/extensions/options_extension.dart';
