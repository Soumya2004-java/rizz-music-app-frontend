import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../background/gradient_mesh_background.dart';
import '../profile_store.dart';
import '../settings_store.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  late final TextEditingController _favoriteGenreController;
  late final TextEditingController _favoriteArtistController;
  late final TextEditingController _locationController;

  List<String> _plans = const ['Free Member', 'Premium Member', 'Family Plan'];
  String _membership = 'Free Member';
  String _photoUrl = '';
  File? _pendingPhoto;
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    final profile = ProfileStore.profile.value;
    _nameController = TextEditingController(text: profile.name);
    _usernameController = TextEditingController(text: profile.username);
    _bioController = TextEditingController(text: profile.bio);
    _favoriteGenreController = TextEditingController(
      text: profile.favoriteGenre,
    );
    _favoriteArtistController = TextEditingController(
      text: profile.favoriteArtist,
    );
    _locationController = TextEditingController(text: profile.location);
    _membership = profile.membership;
    _photoUrl = profile.photoUrl;
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    final config = await SettingsStore.fetchAppConfig();
    if (!mounted) return;
    setState(() {
      _plans = config.membershipPlans;
      if (!_plans.contains(_membership) && _plans.isNotEmpty) {
        _membership = _plans.first;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _favoriteGenreController.dispose();
    _favoriteArtistController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top + 10;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const GradientMeshBackground(),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.24),
                    Colors.black.withValues(alpha: 0.56),
                  ],
                ),
              ),
            ),
          ),
          ListView(
            padding: EdgeInsets.fromLTRB(16, top, 16, 20),
            children: [
              Row(
                children: [
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(child: _photoSection()),
              const SizedBox(height: 16),
              _field('Name', _nameController),
              _field('Username', _usernameController),
              _field('Bio', _bioController, maxLines: 3),
              _field('Favorite Genre', _favoriteGenreController),
              _field('Favorite Artist', _favoriteArtistController),
              _field('Location', _locationController),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _plans.contains(_membership)
                    ? _membership
                    : (_plans.firstOrNull ?? 'Free Member'),
                dropdownColor: const Color(0xFF1D2331),
                style: const TextStyle(color: Colors.white),
                decoration: _decoration('Membership'),
                items: _plans
                    .map(
                      (p) => DropdownMenuItem<String>(value: p, child: Text(p)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _membership = value);
                },
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: _uploadingPhoto ? null : _save,
                icon: _uploadingPhoto
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(_uploadingPhoto ? 'Saving...' : 'Save Changes'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _photoSection() {
    final hasLocal = _pendingPhoto != null;
    final hasRemote = _photoUrl.isNotEmpty;
    return GestureDetector(
      onTap: _uploadingPhoto ? null : _pickPhoto,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            clipBehavior: Clip.antiAlias,
            child: hasLocal
                ? Image.file(_pendingPhoto!, fit: BoxFit.cover)
                : hasRemote
                ? Image.network(
                    _photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _initials(),
                  )
                : _initials(),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFF6F61),
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _initials() {
    final name = ProfileStore.profile.value.name;
    final letter = name.trim().isEmpty ? 'U' : name.trim()[0].toUpperCase();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF7B68), Color(0xFFFFAA5A)],
        ),
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 36,
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.42)),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: _decoration(label),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked == null) return;
    setState(() => _pendingPhoto = File(picked.path));
  }

  Future<String?> _uploadPhoto(File file) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_photos')
        .child('${user.uid}.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> _save() async {
    setState(() => _uploadingPhoto = true);
    try {
      if (_pendingPhoto != null) {
        final url = await _uploadPhoto(_pendingPhoto!);
        if (url != null) _photoUrl = url;
      }
      final current = ProfileStore.profile.value;
      ProfileStore.update(
        current.copyWith(
          name: _nameController.text.trim(),
          username: _usernameController.text.trim(),
          bio: _bioController.text.trim(),
          membership: _membership,
          favoriteGenre: _favoriteGenreController.text.trim(),
          favoriteArtist: _favoriteArtistController.text.trim(),
          location: _locationController.text.trim(),
          photoUrl: _photoUrl,
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved to Firebase.')),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
