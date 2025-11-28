import 'package:formz/formz.dart';

enum PasswordValidationError { empty }

class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure() : super.pure('');
  const Password.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String? value) {
    return value?.isNotEmpty == true ? null : PasswordValidationError.empty;
  }

  String? get errorText {
    if (error == null || isPure) {
      return null;
    } else {
      if (error == PasswordValidationError.empty) {
        return "Enter password";
      }
    }
    return null;
  }
}
