import 'package:flutter/material.dart';

import '../../../blocs/bullet_journal_bloc.dart';
import '../../../models/bullet_entry.dart';
import '../utils/calendar_utils.dart';
import 'diary_tab.dart';

class CalendarEntryList extends StatelessWidget {
  const CalendarEntryList({
    super.key,
    required this.entriesByDay,
    required this.selectedDateKey,
    required this.state,
  });

  final Map<String, List<BulletEntry>> entriesByDay;
  final String? selectedDateKey;
  final BulletJournalState state;

  @override
  Widget build(BuildContext context) {
    if (selectedDateKey == null || entriesByDay[selectedDateKey] == null) {
      return const Center(
        child: Text(
          '날짜를 선택하여 일정을 확인하세요',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: entriesByDay[selectedDateKey]!.map((entry) {
              final diaryInfo = CalendarUtils.findDiaryForEntry(state, entry);
              final hasDiary = diaryInfo?.id != null;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(entry.focus),
                  subtitle: Text('${entry.tasks.length}개의 작업'),
                  trailing: hasDiary ? const Icon(Icons.arrow_forward) : null,
                  onTap: hasDiary
                      ? () {
                          final diary = state.diaries.firstWhere(
                            (d) => d.id == diaryInfo!.id,
                          );
                          DiaryTab.navigateToDiary(context, diary);
                        }
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

