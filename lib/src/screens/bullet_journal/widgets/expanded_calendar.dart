import 'package:flutter/material.dart';

import '../../../blocs/bullet_journal_bloc.dart';
import '../../../models/bullet_entry.dart';
import 'calendar_week_header.dart';
import '../utils/calendar_utils.dart';
import 'diary_tab.dart';

class ExpandedCalendar extends StatelessWidget {
  const ExpandedCalendar({
    super.key,
    required this.calendarDays,
    required this.entriesByDay,
    required this.selectedDateKey,
    required this.currentMonth,
    required this.state,
    required this.onDateSelected,
  });

  final List<DateTime> calendarDays;
  final Map<String, List<BulletEntry>> entriesByDay;
  final String? selectedDateKey;
  final DateTime currentMonth;
  final BulletJournalState state;
  final ValueChanged<String?> onDateSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 요일 헤더
        const CalendarWeekHeader(),
        const Divider(height: 1),
        // 그리드
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.7,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: calendarDays.length,
              itemBuilder: (context, index) {
                final day = calendarDays[index];
                final key = CalendarUtils.dayKey(day);
                final entries = entriesByDay[key] ?? [];
                final isToday = CalendarUtils.isSameDay(day, DateTime.now());
                final isCurrentMonth = day.month == currentMonth.month;

                return GestureDetector(
                  onTap: () {
                    if (entries.isNotEmpty || isCurrentMonth) {
                      onDateSelected(key);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: selectedDateKey == key
                          ? Colors.teal.shade50
                          : Colors.white,
                      border: Border.all(
                        color: selectedDateKey == key
                            ? Colors.teal
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Center(
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isToday
                                    ? Colors.teal.shade700
                                    : Colors.transparent,
                              ),
                              child: Center(
                                child: Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isToday
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: !isCurrentMonth
                                        ? Colors.grey.shade300
                                        : isToday
                                            ? Colors.white
                                            : CalendarUtils.getDayColor(day),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: entries.length > 3 ? 3 : entries.length,
                            itemBuilder: (context, idx) {
                              final entry = entries[idx];
                              final diaryInfo =
                                  CalendarUtils.findDiaryForEntry(state, entry);
                              final hasDiary = diaryInfo?.id != null;

                              return GestureDetector(
                                onTap: hasDiary
                                    ? () {
                                        final diary = state.diaries.firstWhere(
                                          (d) => d.id == diaryInfo!.id,
                                        );
                                        DiaryTab.navigateToDiary(context, diary);
                                      }
                                    : null,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 2),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade100,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Text(
                                    entry.focus,
                                    style: const TextStyle(fontSize: 10),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (entries.length > 3)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              '+${entries.length - 3}',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.teal.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

