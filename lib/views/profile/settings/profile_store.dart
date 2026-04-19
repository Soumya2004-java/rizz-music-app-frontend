import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../services/auth_store.dart';

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

  static const ProfileData empty = ProfileData(
    name: 'User',
    username: 'user',
    bio: '',
    membership: 'Free Member',
    favoriteGenre: '',
    favoriteArtist: '',
    location: '',
  );

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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'bio': bio,
      'membership': membership,
      'favoriteGenre': favoriteGenre,
      'favoriteArtist': favoriteArtist,
      'location': location,
    };
  }

  factory ProfileData.fromMap(Map<String, dynamic> map) {
    String read(String key, String fallback) {
      final value = map[key]?.toString().trim() ?? '';
      return value.isEmpty ? fallback : value;
    }

    return ProfileData(
      name: read('name', ProfileData.empty.name),
      username: read('username', ProfileData.empty.username),
      bio: read('bio', ProfileData.empty.bio),
      membership: read('membership', ProfileData.empty.membership),
      favoriteGenre: read('favoriteGenre', ProfileData.empty.favoriteGenre),
      favoriteArtist: read('favoriteArtist', ProfileData.empty.favoriteArtist),
      location: read('location', ProfileData.empty.location),
    );
  }
}

class ProfileStore {
  ProfileStore._();

  static final ValueNotifier<ProfileData> profile = ValueNotifier<ProfileData>(
    ProfileData.empty,
  );

  static bool _initialized = false;

  static void initialize() {
    if (_initialized) return;
    _initialized = true;

    AuthStore.currentUser.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  static void _onAuthChanged() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      profile.value = ProfileData.empty;
      return;
    }
    _loadForUser(user);
  }

  static Future<void> _loadForUser(User user) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = snapshot.data() ?? <String, dynamic>{};

      final emailPrefix = (user.email ?? '').split('@').first.trim();
      final defaultName = user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : (emailPrefix.isNotEmpty ? emailPrefix : 'User');
      final defaultUsername = emailPrefix.isNotEmpty
          ? emailPrefix.replaceAll(RegExp(r'\s+'), '').toLowerCase()
          : 'user';

      profile.value = ProfileData.fromMap({
        ...data,
        'name': (data['name'] ?? defaultName),
        'username': (data['username'] ?? defaultUsername),
      });
    } catch (_) {
      final emailPrefix = (user.email ?? '').split('@').first.trim();
      profile.value = ProfileData(
        name: emailPrefix.isEmpty ? 'User' : emailPrefix,
        username: emailPrefix.isEmpty
            ? 'user'
            : emailPrefix.replaceAll(RegExp(r'\s+'), '').toLowerCase(),
        bio: '',
        membership: 'Free Member',
        favoriteGenre: '',
        favoriteArtist: '',
        location: '',
      );
    }
  }

  static void update(ProfileData data) {
    profile.value = data;
    _persist(data);
  }

  static Future<void> _persist(ProfileData data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      ...data.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
