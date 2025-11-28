import 'package:dio/dio.dart';
import 'package:rspl_network_manager/src/extensions/options_extension.dart';

import '../token/token_persister.dart';

class TokenInterceptor extends Interceptor {
  TokenInterceptor({
    required this.tokenPersister,
    required this.exceptionList,
  });

  final ITokenPersister tokenPersister;
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
