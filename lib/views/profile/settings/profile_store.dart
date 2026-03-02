import 'package:flutter/foundation.dart';

@immutable
class ProfileData {
  const ProfileData({
    required this.name,
    required this.username,
    required this.bio,
    required this.membership,
    required this.favoriteGenre,
    required this.favoriteArtist,
    required this.location,
  });

  final String name;
  final String username;
  final String bio;
  final String membership;
  final String favoriteGenre;
  final String favoriteArtist;
  final String location;

  ProfileData copyWith({
    String? name,
    String? username,
    String? bio,
    String? membership,
    String? favoriteGenre,
    String? favoriteArtist,
    String? location,
  }) {
    return ProfileData(
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      membership: membership ?? this.membership,
      favoriteGenre: favoriteGenre ?? this.favoriteGenre,
      favoriteArtist: favoriteArtist ?? this.favoriteArtist,
      location: location ?? this.location,
    );
  }
}

class ProfileStore {
  ProfileStore._();

  static final ValueNotifier<ProfileData> profile = ValueNotifier<ProfileData>(
    const ProfileData(
      name: 'Siddhu',
      username: 'siddhu_24',
      bio: 'Late-night listener and playlist curator.',
      membership: 'Premium Member',
      favoriteGenre: 'Synthpop',
      favoriteArtist: 'Arijit Singh',
      location: 'Kolkata, India',
    ),
  );

  static void update(ProfileData data) {
    profile.value = data;
  }
}
