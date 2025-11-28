class NoInternetConnectionException implements Exception {
  NoInternetConnectionException({this.stackTrace});

  final StackTrace? stackTrace;
}
