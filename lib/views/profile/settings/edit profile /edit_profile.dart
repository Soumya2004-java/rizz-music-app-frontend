import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../background/gradient_mesh_background.dart'
    show GradientMeshBackground;
import '../profile_store.dart';

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

  String _membership = 'Premium Member';

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
    final topPadding = MediaQuery.of(context).padding.top;
    final topSectionGap = topPadding + 8;

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
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: const SizedBox.expand(),
            ),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(20, topSectionGap, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _CircleGlassButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Public Profile',
                  children: [
                    _EditableTile(
                      icon: Icons.person_outline_rounded,
                      label: 'Name',
                      controller: _nameController,
                    ),
                    _EditableTile(
                      icon: Icons.alternate_email_rounded,
                      label: 'Username',
                      controller: _usernameController,
                    ),
                    _EditableTile(
                      icon: Icons.info_outline_rounded,
                      label: 'Bio',
                      controller: _bioController,
                      minLines: 2,
                      maxLines: 4,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Music Preferences',
                  children: [
                    _EditableTile(
                      icon: Icons.graphic_eq_rounded,
                      label: 'Favorite Genre',
                      controller: _favoriteGenreController,
                    ),
                    _EditableTile(
                      icon: Icons.mic_none_rounded,
                      label: 'Favorite Artist',
                      controller: _favoriteArtistController,
                    ),
                    _EditableTile(
                      icon: Icons.place_outlined,
                      label: 'Location',
                      controller: _locationController,
                    ),
                    _DropdownTile(
                      icon: Icons.workspace_premium_rounded,
                      label: 'Membership',
                      value: _membership,
                      values: const [
                        'Premium Member',
                        'Free Member',
                        'Family Plan',
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _membership = value);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _GlassActionButton(
                  label: 'Save Changes',
                  icon: Icons.check_rounded,
                  onTap: _save,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
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
      ),
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    Navigator.of(context).pop();
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.18),
                Colors.white.withValues(alpha: 0.08),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _EditableTile extends StatelessWidget {
  const _EditableTile({
    required this.icon,
    required this.label,
    required this.controller,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final IconData icon;
  final String label;
  final TextEditingController controller;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LeadingIcon(icon: icon),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              minLines: minLines,
              maxLines: maxLines,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownTile extends StatelessWidget {
  const _DropdownTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          _LeadingIcon(icon: icon),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: const Color(0xFF121722),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                borderRadius: BorderRadius.circular(12),
                iconEnabledColor: Colors.white70,
                items: values
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      width: 34,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}

class _GlassActionButton extends StatelessWidget {
  const _GlassActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.16),
                  Colors.white.withValues(alpha: 0.06),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 19),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleGlassButton extends StatelessWidget {
  const _CircleGlassButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
