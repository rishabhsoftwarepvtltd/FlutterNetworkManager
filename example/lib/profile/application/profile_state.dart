import 'package:example/profile/domain/profile.dart';

/// States for the Profile BLoC.
abstract class ProfileState {}

/// Initial state before any profile data is loaded.
class ProfileInitial extends ProfileState {}

/// State when profile is being loaded.
class ProfileLoading extends ProfileState {}

/// State when profile is successfully loaded.
class ProfileLoaded extends ProfileState {
  ProfileLoaded(this.profile);

  final Profile profile;
}

/// State when profile loading fails.
class ProfileError extends ProfileState {
  ProfileError(this.message);

  final String message;
}
