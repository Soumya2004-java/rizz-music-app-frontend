import 'package:flutter/material.dart';

class LibraryItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const LibraryItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(0.85),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}
