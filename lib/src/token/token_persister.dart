abstract class ITokenWriter {
  Future<void> save({String? token, String? refreshToken});
  Future<void> remove();
}

abstract class ITokenReader {
  Future<String?> get token;
  Future<String?> get refreshToken;
}

abstract class ITokenPersister implements ITokenReader, ITokenWriter {}
