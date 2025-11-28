import 'package:bloc/bloc.dart';
import 'package:example/profile/application/profile_event.dart';
import 'package:example/profile/application/profile_state.dart';
import 'package:example/profile/data/profile_repository.dart';
import 'package:flutter/material.dart';

/// BLoC for managing profile state and events.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository,
        super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
  }

  final ProfileRepository _profileRepository;

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profile = await _profileRepository.getProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      debugPrint("Error loading profile: $e");
      emit(ProfileError(e.toString()));
    }
  }
}
