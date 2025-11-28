import 'dart:async';

import 'package:dio/dio.dart';
import 'package:rspl_network_manager/src/helpers/refresh_mechanism_helper.dart';
import 'token_refresher.dart';

class TokenRetryEvaluator {
  TokenRetryEvaluator({
    required this.tokenRefresher,
    this.retryCodes,
    this.exceptionalUris,
  });

  final ITokenRefresher tokenRefresher;
  final List<int>? retryCodes;

  /// String list of api endpoints which you don't desire to evaluate the
  /// retry mechanism if it got failure response - (401, 403 etc)
  final List<String>? exceptionalUris;

  int currentAttempt = 0;

  /// Returns true only if all bottom clauses are true
  /// 1. The response hasn't been cancelled or got a bad status code.
  /// 2. Refreshing token was successful.
  // ignore: avoid-unused-parameters
  FutureOr<bool> evaluate(DioException error, int attempt) async {
    bool shouldRetryActualService;
    if (error.type == DioExceptionType.badResponse) {
      if (_isExceptionalUri(error)) {
        // if it is one of the exceptional uris,
        // it will not retry the original/actual service call.
        shouldRetryActualService = false;
      } else {
        final statusCode = error.response?.statusCode;
        if (statusCode != null) {
          shouldRetryActualService = await shouldRetry(statusCode);
        } else {
          shouldRetryActualService = true;
        }
      }
    } else {
      shouldRetryActualService = error.type != DioExceptionType.cancel &&
          error.error is! FormatException;
    }
    currentAttempt = attempt;
    return shouldRetryActualService;
  }

  /// Method that will check if the api which has thrown exception/error,
  /// is one of the exceptional uris.
  ///
  /// Returns true if present.
  bool _isExceptionalUri(DioException error) {
    final value = error.requestOptions.path;
    if (exceptionalUris != null) {
      final index = exceptionalUris?.indexWhere((exceptionalUri) =>
              RefreshMechanismHelper.isValueMatchingExpectation(
                expectation: exceptionalUri,
                value: value,
              )) ??
          -1;
      return (index >= 0);
    }
    return false;
  }

  Future<bool> shouldRetry(int statusCode) async {
    if (retryCodes != null && retryCodes!.contains(statusCode)) {
      return tokenRefresher.refreshToken();
    }
    return false;
  }
}
