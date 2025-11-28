import 'package:example/app/get_it_setup.dart';
import 'package:example/route/route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/login_bloc.dart';
import '../../domain/usecase/login_usecase.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(loginUsecase: getIt<LoginUsecase>()),
      child: Builder(builder: (context) {
        return BlocListener<LoginBloc, LoginState>(
          listener: _loginStateListener,
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Login"),
            ),
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 60.0, bottom: 20.0, left: 20.0, right: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Column(
                        children: [
                          _UsernameInput(),
                          SizedBox(height: 20.0),
                          _PasswordInput(),
                          SizedBox(height: 10.0),
                        ],
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      BlocBuilder<LoginBloc, LoginState>(
                        builder: (context, state) {
                          final isLoading = state.status == FormzSubmissionStatus.inProgress;

                          return ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    FocusManager.instance.primaryFocus?.unfocus();
                                    context.read<LoginBloc>().add(const LoginSubmitted());
                                  },
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                                  ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _loginStateListener(BuildContext context, LoginState state) {
    if (state.status == FormzSubmissionStatus.success) {
      GoRouter.of(context).go(RouteNames.profile);
    } else if (state.status == FormzSubmissionStatus.failure) {
      // Handle specific errors
      if (state.error == LoginError.noInternet) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No Internet connection"),
            backgroundColor: Colors.red,
          ),
        );
      } else if (state.error == LoginError.userNameOrPassIncorrect) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Incorrect username or password"),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // Catch-all for any unhandled errors
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login failed. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _UsernameInput extends StatelessWidget {
  const _UsernameInput();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.username != current.username,
      builder: (context, state) {
        return TextField(
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            context.read<LoginBloc>().add(LoginUsernameChanged(value));
          },
          decoration: InputDecoration(
            hintText: 'Email',
            labelText: 'Email',
            errorText: state.username.errorText,
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  const _PasswordInput();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          onChanged: (value) {
            context.read<LoginBloc>().add(LoginPasswordChanged(value));
          },
          decoration: InputDecoration(
            hintText: 'Password',
            labelText: 'Password',
            errorText: state.password.errorText,
          ),
        );
      },
    );
  }
}
