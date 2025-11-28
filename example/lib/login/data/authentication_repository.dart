import 'dart:async';

import 'package:example/login/data/authentication_api.dart';
import 'package:example/login/data/login_response.dart';
import 'package:rspl_network_manager/rspl_network_manager.dart';

import '../../app/get_it_setup.dart';

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  AuthenticationRepository({required AuthenticationApi authenticationApi})
      : _authenticationApi = authenticationApi;
  final AuthenticationApi _authenticationApi;
  final _controller = StreamController<AuthenticationStatus>();

  Stream<AuthenticationStatus> get status async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield AuthenticationStatus.unauthenticated;
    yield* _controller.stream;
  }

  Future<LoginResponse> logIn({
    required String username,
    required String password,
  }) async {
    final response = await _authenticationApi.login(
      username: username,
      password: password,
    );
    if (response.accessToken.isNotEmpty) {
      _controller.add(AuthenticationStatus.authenticated);
    }
    return response;
  }

  void logOut() async {
    await getIt<ITokenPersister>().remove();
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  void dispose() => _controller.close();
}
