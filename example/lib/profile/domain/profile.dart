import 'package:json_annotation/json_annotation.dart';

part 'profile.g.dart';

/// User profile model matching the api.escuelajs.co profile endpoint response.
@JsonSerializable()
class Profile {
  Profile({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.avatar,
  });

  final int id;
  final String email;
  final String name;
  final String role;
  final String avatar;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
