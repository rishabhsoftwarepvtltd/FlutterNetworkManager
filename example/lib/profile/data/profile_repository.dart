import 'package:example/profile/data/profile_api.dart';
import 'package:example/profile/domain/profile.dart';

/// Repository for managing profile data.
class ProfileRepository {
  ProfileRepository({required ProfileApi profileApi})
      : _profileApi = profileApi;

  final ProfileApi _profileApi;

  /// Fetches the user's profile from the API.
  Future<Profile> getProfile() async {
    return await _profileApi.getProfile();
  }
}
