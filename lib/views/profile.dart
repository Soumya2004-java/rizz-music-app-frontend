import 'dart:ui';

import 'package:flutter/material.dart';

import '../background/gradient_mesh_background.dart' show GradientMeshBackground;

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GradientMeshBackground(),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.transparent),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundImage:
                        AssetImage('assets/albums/images3.jpeg'),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Siddhu",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Premium Member",
                            style: TextStyle(
                                fontSize: 14, color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Buttons
                  Row(
                    children: [
                      _actionBtn(Icons.edit, "Edit Profile"),
                      const SizedBox(width: 16),
                      _actionBtn(Icons.settings, "Settings"),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _profileStat("Tracks", "432"),
                      _profileStat("Followers", "12.3K"),
                      _profileStat("Following", "380"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _profileStat(String label, String num) {
    return Column(
      children: [
        Text(
          num,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        )
      ],
    );
  }

  Widget _actionBtn(IconData icon, String text) {
    return Expanded(
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(text, style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
