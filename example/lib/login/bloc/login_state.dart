part of 'login_bloc.dart';

enum LoginError { none, noInternet, userNameOrPassIncorrect }

class LoginState extends Equatable {
  const LoginState({
    this.username = const Username.pure(),
    this.password = const Password.pure(),
    this.isValid = false,
    this.status = FormzSubmissionStatus.initial,
    this.error = LoginError.none,
  });

  final Username username;
  final Password password;
  final bool isValid;
  final FormzSubmissionStatus status;
  final LoginError error;

  LoginState copyWith({
    Username? username,
    Password? password,
    bool? isValid,
    FormzSubmissionStatus? status,
    LoginError? error,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  List<Object> get props => [username, password, isValid, status, error];
}
