import 'package:dio/dio.dart';
import 'package:example/profile/data/profile_api.dart';
import 'package:example/profile/data/profile_repository.dart';
import 'package:example/core/token/token_refresher.dart';
import 'package:example/login/data/authentication_api.dart';
import 'package:example/login/data/authentication_repository.dart';
import 'package:example/login/domain/usecase/login_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:rspl_network_manager/rspl_network_manager.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  getIt.registerSingleton<ITokenPersister>(const KeyChainTokenPersister());

  /// Configure Dio factory
  /// This is the Mock API URL for testing, please check https://fakeapi.platzi.com/ for more detail
  const dioFactory = DioFactory("https://api.escuelajs.co");

  ///Adding token in all request excluding exception list
  final tokenInterceptor = TokenInterceptor(
    tokenPersister: getIt<ITokenPersister>(),
    exceptionList: [AuthenticationUris.login],
  );

  ///Logging webservice parameter based configuration
  final loggerInterceptor = WSLoggerInterceptor(
    requestBody: true,
    requestHeader: true,
    error: true,
    responseHeader: true,
  );

  ///Ask Dio factory to create Dio client object.
  ///Configure interceptor based on your need.
  getIt.registerSingleton<Dio>(
    dioFactory.create()
      ..interceptors.add(ConnectivityInterceptor())
      ..interceptors.add(tokenInterceptor)
      ..interceptors.add(loggerInterceptor),
  );

  getIt.registerSingleton(AuthenticationApi(dioClient: getIt<Dio>()));
  getIt.registerSingleton(
      AuthenticationRepository(authenticationApi: getIt<AuthenticationApi>()));

  getIt.registerFactory<LoginUsecase>(() => LoginUsecase(
      authenticationRepository: getIt<AuthenticationRepository>()));

  //Setup token refresh interceptor
  final dioClient = getIt<Dio>();

  getIt.registerSingleton<ITokenRefresher>(
    TokenRefresher(
      tokenPersister: getIt<ITokenPersister>(),
      dio: dioClient,
    ),
  );

  final tokenRefreshInterceptorWrapper = TokenRefreshInterceptorWrapper(
    dio: dioClient,
    tokenRefresher: getIt<ITokenRefresher>(),
    retryEvaluator: TokenRetryEvaluator(
      tokenRefresher: getIt<ITokenRefresher>(),
      retryCodes: [401, 403],
      exceptionalUris: ["/login"],
    ).evaluate,
    retries: 1,
  );

  getIt.registerLazySingleton<TokenRefreshInterceptorWrapper>(
    () => tokenRefreshInterceptorWrapper,
  );

  dioClient.interceptors.add(tokenRefreshInterceptorWrapper.interceptor);

  //Configure Profile Repository
  getIt.registerSingleton(ProfileApi(dioClient: getIt<Dio>()));
  getIt.registerSingleton(ProfileRepository(profileApi: getIt<ProfileApi>()));
}
