import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

/// Interceptor that checks internet connectivity before making network requests.
///
/// This interceptor monitors the device's connectivity status and rejects
/// requests when there is no internet connection, preventing unnecessary
/// network calls and providing immediate feedback.
///
/// Example:
/// ```dart
/// final connectivityInterceptor = ConnectivityInterceptor();
/// dio.interceptors.add(connectivityInterceptor);
/// ```
///
/// When there's no internet connection, requests will fail with:
/// - Type: [DioExceptionType.connectionTimeout]
/// - Error: "no_internet_connectivity"
class ConnectivityInterceptor extends Interceptor {
  /// Creates a [ConnectivityInterceptor] instance.
  ///
  /// Optionally accepts a [Connectivity] instance for testing purposes.
  /// If not provided, a new [Connectivity] instance will be created automatically.
  ConnectivityInterceptor({Connectivity? connectivity}) {
    _connectivity = connectivity ?? Connectivity();
    _listenConnectionStatus();
  }
  
  late final Connectivity _connectivity;
  late final StreamSubscription<List<ConnectivityResult>> subscription;
  ConnectivityResult? _connectionResult;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_connectionResult != null &&
        _connectionResult == ConnectivityResult.none) {
      handler.reject(
        DioException(
            requestOptions: options,
            type: DioExceptionType.connectionTimeout,
            error: "no_internet_connectivity"),
      );
    } else {
      super.onRequest(options, handler);
    }
  }

  //Monitoring and caching connectivity status to avoid delay in finding status.
  void _listenConnectionStatus() {
    subscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      if (result.isNotEmpty) {
        _connectionResult = result.first;
      }
    });
  }
}
