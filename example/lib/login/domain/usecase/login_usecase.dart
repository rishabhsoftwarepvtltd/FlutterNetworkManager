import 'package:rspl_network_manager/rspl_network_manager.dart';

import '../../../app/get_it_setup.dart';
import '../../data/authentication_repository.dart';
import '../../data/login_response.dart';

class LoginUsecase {
  LoginUsecase({
    required AuthenticationRepository authenticationRepository,
  }) : _authenticationRepository = authenticationRepository;

  final AuthenticationRepository _authenticationRepository;

  Future<LoginResponse> logInUsingUsernameAndPassword({
    required String username,
    required String password,
  }) async {
    final response = await _authenticationRepository.logIn(
      username: username,
      password: password,
    );

    // Save both access token and refresh token
    final tokenPersister = getIt<ITokenPersister>();
    await tokenPersister.save(
      token: response.accessToken,
      refreshToken: response.refreshToken,
    );

    return response;
  }
}
