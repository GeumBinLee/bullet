import 'package:flutter/material.dart';

import '../models/bullet_entry.dart';

class MoodBadge extends StatelessWidget {
  const MoodBadge({super.key, required this.mood});

  final BulletMood mood;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _badgeColor(mood).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Text(
        _badgeLabel(mood),
        style: TextStyle(
          color: _badgeColor(mood),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static String _badgeLabel(BulletMood mood) {
    switch (mood) {
      case BulletMood.calm:
        return '고요함';
      case BulletMood.energized:
        return '활기참';
      case BulletMood.reflective:
        return '성찰';
    }
  }

  static Color _badgeColor(BulletMood mood) {
    switch (mood) {
      case BulletMood.calm:
        return Colors.blue;
      case BulletMood.energized:
        return Colors.orange;
      case BulletMood.reflective:
        return Colors.purple;
    }
  }
}

