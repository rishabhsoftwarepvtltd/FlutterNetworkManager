import 'package:dio/dio.dart';
import 'package:rspl_network_manager/src/extensions/options_extension.dart';

import '../token/token_persister.dart';

/// Interceptor that automatically adds authentication tokens to requests.
///
/// This interceptor retrieves the access token from [ITokenPersister] and
/// adds it to the `Authorization` header as a Bearer token for all requests
/// that require authentication.
///
/// Requests can be exempted from token injection by:
/// 1. Adding the path to [exceptionList]
/// 2. Setting `tokenNotRequired` option on the request
///
/// Example:
/// ```dart
/// final tokenInterceptor = TokenInterceptor(
///   tokenPersister: myTokenPersister,
///   exceptionList: ['/login', '/register'],
/// );
/// dio.interceptors.add(tokenInterceptor);
/// ```
class TokenInterceptor extends Interceptor {
  /// Creates a [TokenInterceptor] instance.
  ///
  /// [tokenPersister] is used to retrieve the access token.
  /// [exceptionList] contains API paths that should not have tokens added.
  TokenInterceptor({
    required this.tokenPersister,
    required this.exceptionList,
  });

  /// Token persister for retrieving the access token.
  final ITokenPersister tokenPersister;
  
  /// List of API paths that should not have authentication tokens added.
  final List<String> exceptionList;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!options.tokenNotRequired) {
      if (_shouldAddToken(options.path)) {
        final token = await tokenPersister.token;
        if (token != null && token.isNotEmpty) {
          options.headers['authorization'] =
              "Bearer ${await tokenPersister.token}";
        }
      }
    }
    super.onRequest(options, handler);
  }

  bool _shouldAddToken(String path) {
    return !exceptionList.contains(path);
  }
}
