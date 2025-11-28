import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:example/login/domain/usecase/login_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:rspl_network_manager/rspl_network_manager.dart';

import '../presentation/model/password.dart';
import '../presentation/model/username.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required LoginUsecase loginUsecase,
  })  : _loginUsecase = loginUsecase,
        super(const LoginState()) {
    on<LoginUsernameChanged>(_onUsernameChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
  }

  final LoginUsecase _loginUsecase;

  void _onUsernameChanged(
    LoginUsernameChanged event,
    Emitter<LoginState> emit,
  ) {
    final username = Username.dirty(event.username);
    final isValid = Formz.validate([username, state.password]);

    emit(
      state.copyWith(
        username: username,
        isValid: isValid,
        error: LoginError.none,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    final password = Password.dirty(event.password);
    final isValid = Formz.validate([state.username, password]);

    emit(
      state.copyWith(
        password: password,
        isValid: isValid,
        error: LoginError.none,
        status: FormzSubmissionStatus.initial,
      ),
    );
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.isValid) return;

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    try {
      final response = await _loginUsecase.logInUsingUsernameAndPassword(
        username: state.username.value,
        password: state.password.value,
      );

      if (response.accessToken.isEmpty) {
        emit(
          state.copyWith(
            status: FormzSubmissionStatus.failure,
            error: LoginError.userNameOrPassIncorrect,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: FormzSubmissionStatus.success,
            error: LoginError.none,
          ),
        );
      }
    } on NoInternetConnectionException {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          error: LoginError.noInternet,
        ),
      );
    } on DioException catch (e) {
      // Handle 401 Unauthorized as incorrect credentials
      if (e.response?.statusCode == 401) {
        emit(
          state.copyWith(
            status: FormzSubmissionStatus.failure,
            error: LoginError.userNameOrPassIncorrect,
          ),
        );
      } else {
        // Other DioExceptions
        emit(state.copyWith(status: FormzSubmissionStatus.failure));
      }
    } catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }
}
