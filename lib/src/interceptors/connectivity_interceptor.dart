import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

class ConnectivityInterceptor extends Interceptor {
  ///Will automatically initialize [Connectivity] if not provided by caller.
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
