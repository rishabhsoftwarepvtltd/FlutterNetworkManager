/// Exception thrown when there is no internet connection available.
///
/// This exception is typically thrown by [ConnectivityInterceptor] when
/// a network request is attempted without an active internet connection.
class NoInternetConnectionException implements Exception {
  /// Creates a [NoInternetConnectionException] with an optional stack trace.
  NoInternetConnectionException({this.stackTrace});

  /// The stack trace at the point where the exception was thrown.
  final StackTrace? stackTrace;
}
