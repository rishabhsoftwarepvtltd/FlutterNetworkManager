import 'package:dio/dio.dart';

const String _kRequestOptionsTokenNotRequiredKey = "token-not-required";

/// Extension on Options to specify if token can be omitted in adding as a part of header-auth.
extension OptionsX on Options {
  bool get tokenNotRequired =>
      (extra?[_kRequestOptionsTokenNotRequiredKey] as bool?) ?? false;

  set tokenNotRequired(bool value) =>
      extra?[_kRequestOptionsTokenNotRequiredKey] = value;
}

/// Extension on RequestOptions to specify if token can be omitted in adding as a part of header-auth.
///
/// It will access the value internally in [TokenInterceptor]
extension RequestOptionsX on RequestOptions {
  bool get tokenNotRequired =>
      (extra[_kRequestOptionsTokenNotRequiredKey] as bool?) ?? false;

  set tokenNotRequired(bool value) =>
      extra[_kRequestOptionsTokenNotRequiredKey] = value;
}
