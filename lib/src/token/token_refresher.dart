abstract class ITokenRefresher {
  ///Renew token and store it with help of [ITokenPersister].
  Future<bool> refreshToken();
}
