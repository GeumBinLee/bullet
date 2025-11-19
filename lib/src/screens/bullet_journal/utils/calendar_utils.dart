import 'package:flutter/material.dart';

import '../../../models/bullet_entry.dart';
import '../../../blocs/bullet_journal_bloc.dart';

class CalendarUtils {
  static String dayKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static Color getDayColor(DateTime day) {
    if (day.weekday == 7) return Colors.red.shade700;
    if (day.weekday == 6) return Colors.blue.shade700;
    return Colors.black87;
  }

  static ({String? name, String? id})? findDiaryForEntry(
    BulletJournalState state,
    BulletEntry entry,
  ) {
    if (state.entries.any((e) => e.id == entry.id)) {
      return (name: '기본', id: null);
    }
    for (final diary in state.diaries) {
      if (diary.entries.any((e) => e.id == entry.id)) {
        return (name: diary.name, id: diary.id);
      }
      for (final page in diary.pages) {
        if (page.entries.any((e) => e.id == entry.id)) {
          return (name: diary.name, id: diary.id);
        }
      }
    }
    return null;
  }
}

